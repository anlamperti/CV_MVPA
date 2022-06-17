//
//  WorkoutView.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/10/21.
//

import SwiftUI
import HealthKit
import WatchConnectivity

struct WorkoutView: View {
    var dateSelection: Date
    
    let healthStore = HKHealthStore()
    let workouts: [HKWorkout]
    
    init(dateSelection: Date) {
        self.dateSelection = dateSelection
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.activitySummaryType()
        ]

        // Request authorization for those quantity types.
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { (success, error) in
            if (!success) {
                print("failed to get authorization \(String(describing: error))")
            }
        }
        
        self.workouts = WorkoutView.loadWorkouts(date: dateSelection)
    }
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body : some View {
        VStack {
            if (!workouts.isEmpty) {
                List(workouts, id: \.self) { workout in
                    WorkoutItemView(workout: workout)
                }
            } else {
                Text("Nothing to see here")
            }
            
        }.navigationBarTitle(Text(dateSelection.formatted(.dateTime.month().day())))
    }
    
    struct WorkoutItemView: View {
        var workout: HKWorkout
        
        var hrAverage: Int
//        var hrMax: Int16
        
        init(workout: HKWorkout) {
            self.workout = workout
            let samples = WorkoutView.WorkoutItemView.loadHeartRateData(workout: workout)
            
            let heartRateUnit = HKUnit(from: "count/min")
            let bpmSamples = samples.map { $0.quantity.doubleValue(for: heartRateUnit) }
            hrAverage = Int(bpmSamples.reduce(0.0, +) / Double(bpmSamples.count).rounded())
            
//            hrMax: Int16 = TextFieldAlert.$score
        }
    
        var body : some View {
            NavigationLink(destination: WorkoutDetailsView(workout: workout)) {
                HStack {
                    Text(workout.startDate.formatted(.dateTime.hour().minute())).bold()
                    HStack(alignment: .center) {
                        Text("Avg: \(hrAverage)")
//                        Text("HRMax: \(hrMax)")
                    }
                }
            }
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

    
    static func loadWorkouts(date: Date) -> [HKWorkout]{
        // Get all workouts with the "Other" activity type.
        let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)

        // Get all workouts that only came from this app.
        let sourcePredicate = HKQuery.predicateForObjects(from: .default())
        
        // Get all workouts that happened today.
        let startDate = Calendar.current.startOfDay(for: date)
        let endDate = startDate.advanced(by: 60*60*24)
        let datePredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)

        //Combine the predicates into a single predicate.
        let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
        [workoutPredicate, sourcePredicate, datePredicate])

        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                              ascending: false)
        
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
}
