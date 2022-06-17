//
//  WorkoutManager.swift
//  MVPA Workout WatchKit Extension
//
//  Created by Alex Herrin on 11/8/21.
//

import SwiftUI
import HealthKit
import WatchConnectivity


class WorkoutManager: NSObject, ObservableObject {
    
    var delegate: ActivityControllerView?
//    var selectedWorkout: HKWorkoutActivityType? {
//        didSet {
//            guard let selectedWorkout = selectedWorkout else { return }
//            startWorkout(workoutType: selectedWorkout)
//        }
//    }
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
//            HKQuantityType.quantityType(forIdentifier: .appleExerciseTime)!
        ]

        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .distanceCycling)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            //Handle error.
            if (!success) {
                print("failed to get authorization")
            }
        }
    }
    
    // Start the workout.
    func startWorkout(workoutType: HKWorkoutActivityType) -> Bool {
        guard delegate != nil else {
            print("Workoutmanager.delegate == nil")
            return false
        }
        
        // workout configuration
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = workoutType
        configuration.locationType = .indoor

        // Create the session and obtain the workout builder.
        
        session = try? HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        builder = session?.associatedWorkoutBuilder()
        guard session != nil && builder != nil else {
            print("failed to create session or builder")
            return false
        }
        
        // Setup session and builder.
        session?.delegate = self
        builder?.delegate = self

        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(
            healthStore: healthStore,
            workoutConfiguration: configuration
        )
                
        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        
        // make async beginCollection call syncronus
        let group = DispatchGroup()
        group.enter()
        var succeeded = false
        builder?.beginCollection(withStart: startDate) { (success, error) in
            succeeded = success
            group.leave()
        }
        group.wait()
        
        return succeeded
    }
    

    // MARK: - Session State Control

    // The app's workout state.
    @Published var running = false

    func togglePause() {
        if running == true {
            self.pause()
        } else {
            resume()
        }
    }

    func pause() {
        session?.pause()
    }

    func resume() {
        session?.resume()
    }

    func endWorkout() {
        session?.end()
        showingSummaryView = true
        print("activity ended wm")
        
    }

    // MARK: - Workout Metrics
    @Published var averageHeartRate: Double = 0
    @Published var heartRate: Double = 0
    @Published var activeEnergy: Double = 0
    @Published var distance: Double = 0
    @Published var workout: HKWorkout?

    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                self.averageHeartRate = statistics.averageQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                
                self.delegate?.processSample()
                
                print("after delegate call")
                
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let energyUnit = HKUnit.kilocalorie()
                self.activeEnergy = statistics.sumQuantity()?.doubleValue(for: energyUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning), HKQuantityType.quantityType(forIdentifier: .distanceCycling):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
                
            default:
                return
            }
        }
        
        print("outside async")
    }

    func resetWorkout() {
//        selectedWorkout = nil
        builder = nil
        workout = nil
        session = nil
        activeEnergy = 0
        averageHeartRate = 0
        heartRate = 0
        distance = 0
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
//                    DispatchQueue.main.async {
                        self.workout = workout
//                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}

