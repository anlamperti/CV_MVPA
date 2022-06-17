//
//  UnassignedDataView.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/29/21.
//


import WatchConnectivity
import SwiftUI
import UIKit
import HealthKit
import CoreData
import HomeKit

struct UnassignedDataView: View {
    let healthStore = HKHealthStore()
    
    let persistence = Persistence()
    var users: [User]
    let heartRateUnit = HKUnit(from: "count/min")
    
    @State private var lastAssignedDate = Date()
    @State private var assignableWorkout: HKWorkout? = nil
    @State private var workouts: [HKWorkout] = []
    
    init() {
        // get the users list
        self.users = persistence.getAllUsers()
    }
    
    var body : some View {
        NavigationView {
            VStack {

                List {
//                    Text("Last assigned \(lastAssignedDate.formatted(.dateTime.year().month().day().hour().minute()))")
                    Section(header: Text("Ready to assign")) {
                        if (assignableWorkout != nil) {
                            WorkoutItemView(delegate: self, workout: assignableWorkout!, users: users)
                        } else {
                            Text("No workouts to assign")
                        }
                    }
                    Section(header: Text("Other")) {
                        if (!workouts.isEmpty) {
                            ForEach(workouts, id: \.self) { workout in
                                WorkoutItemView(delegate: self, workout: workout, users: users)
                                    .disabled(true)
                            }
                        } else {
                            Text("No other workouts")
                        }
                    }
                }
                .navigationBarTitle(Text("Unassigned Workouts"))
                .refreshable { reloadWorkouts() }
                .onAppear { reloadWorkouts() }
                
            }
        }
        
    }
    
    public func reloadWorkouts() {
        lastAssignedDate = UserDefaultsController.loadLastAssignedDate()
        
        // reload workouts
        var loadedWorkouts = UnassignedDataView.loadWorkouts(lastAssignedDate: lastAssignedDate)
        assignableWorkout = !loadedWorkouts.isEmpty ? loadedWorkouts.remove(at: 0) : nil
        workouts = loadedWorkouts
    }
    
    public mutating func reloadUsers() {
        users = persistence.getAllUsers()
    }
    
    public mutating func assignWorkout(workout: HKWorkout, user: User) {
        // TODO: calculate
//        let hrMax = $score
        let bpmMeasurments: [BpmMeasurement] = []
        
        // get bpm data for workout
        let samples = UnassignedDataView.loadHeartRateData(workout: workout)
        let bpmSamples = samples.map { $0.quantity.doubleValue(for: heartRateUnit) }
        let hrAverage = Int(bpmSamples.reduce(0.0, +) / Double(bpmSamples.count).rounded())
        
        // date data
        persistence.addActivity(
            user: user,
            date: workout.startDate,
//            hrMax: hrMaxpercentage,
            averageBpm: hrAverage,
            bpmData: bpmMeasurments)
        UserDefaultsController.saveLastAssignedDate(date: workout.endDate)
       
        // update view
        reloadWorkouts()
    }
    
    static func loadWorkouts(lastAssignedDate: Date) -> [HKWorkout]{
        // workouts with the "Other" activity type.
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)
        // workouts that only came from this app.
        let sourcePredicate = HKQuery.predicateForObjects(from: .default())
        // workouts that happened between lastAssignedDate and now.
        let startDate = lastAssignedDate.advanced(by: 1)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: Date())
        // combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(
            andPredicateWithSubpredicates: [
                workoutPredicate,
                sourcePredicate,
                datePredicate
            ]
        )

        let sortDescriptor = NSSortDescriptor(
            key: HKSampleSortIdentifierEndDate,
            ascending: true
        )
        
        let group = DispatchGroup()
        group.enter()
        var workouts: [HKWorkout] = []

        let query = HKSampleQuery(
            sampleType: .workoutType(),
            predicate: compound,
            limit: 0,
            sortDescriptors: [sortDescriptor]) { (query, samples, error) in
                guard let samples = samples as? [HKWorkout], error == nil
                else {
                    print("Failed to load workouts \(String(describing: error))")
                    return
                }
                workouts = samples
                group.leave()
        }
        
        HKHealthStore().execute(query)
        group.wait()
        return workouts
    }
    
    static func loadHeartRateData(workout: HKWorkout) -> [HKQuantitySample] {
        guard let heartRateType = HKObjectType.quantityType(
            forIdentifier: HKQuantityTypeIdentifier.heartRate)
        else {
            fatalError("*** Unable to create a Heart rate type ***")
        }
        
        let workoutPredicate = HKQuery.predicateForObjects(from: workout)
        let startDateSort = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)
        
        let group = DispatchGroup()
        group.enter()
        var heartRateSamples: [HKQuantitySample] = []

        let query = HKSampleQuery(
            sampleType: heartRateType,
            predicate: workoutPredicate,
            limit: 0,
            sortDescriptors: [startDateSort]) { (query, samples, error) in
                guard let samples = samples as? [HKQuantitySample], error == nil
                else {
                    print("Failed to load heartRateSamples")
                    return
                }
                heartRateSamples = samples
                group.leave()
        }
        
        HKHealthStore().execute(query)
        group.wait()
        return heartRateSamples
    }
}

struct WorkoutItemView: View {
    var delegate: UnassignedDataView
    var users: [User]
    var workout: HKWorkout
    
    init(delegate: UnassignedDataView, workout: HKWorkout, users: [User]) {
        self.delegate = delegate
        self.users = users
        self.workout = workout
    }

    var body : some View {
        NavigationLink(destination: AssigneePickerView(
            delegate: delegate,
            workout: workout
        )) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    Text("\(workout.startDate.formatted(.dateTime.year().month().day()))").bold()
                    Text("\(workout.startDate.formatted(.dateTime.hour().minute())) - \(workout.endDate.formatted(.dateTime.hour().minute()))")
                }
                Spacer()
                Text(formatDuration(duration: workout.duration))
            }
        }
    }
    
    func formatDuration(duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.day, .hour, .minute, .second]
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1

        return formatter.string(from: duration)!
    }
}

