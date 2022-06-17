//
//  HealthKitController.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 3/20/22.
//

import SwiftUI
import HealthKit

class HealthKitController: ObservableObject {
    let healthStore = HKHealthStore()
    @Published var authorized: Bool = false
    
    init() {
        requestAuthorization()
    }
    
    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity type to write to the health store.
        let typesToShare: Set = [
            HKQuantityType.workoutType(),
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!,
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
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) {
            (success, error) in
            //Handle error.
            if (!success || error != nil) {
                print("failed to get authorization \(String(describing: error))")
            }
            DispatchQueue.main.async { self.authorized = success }
        }
    }
    
}
