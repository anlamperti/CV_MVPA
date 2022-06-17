//
//  WorkoutDetailsView.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/10/21.
//

import SwiftUI
import HealthKit
import WatchConnectivity

struct WorkoutDetailsView: View {
  var workout: HKWorkout
  
  var body: some View {
    VStack {
        Text("\(workout.startDate.formatted(.dateTime.month().day().hour().minute()))")
        BpmChart(workout: workout)
    }.padding()
  }
}
