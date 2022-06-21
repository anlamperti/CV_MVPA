//
//  ContentView.swift
//  MVPA Workout WatchKit Extension
//
//  Created by Alex Herrin on 11/8/21.
//

import SwiftUI

struct TargetSelectionView: View {
    @Binding var hrMax: Int
    @Binding var tab: String
    @Binding var workoutDuration: Int
    @State var hrMaxSelection: Int = 100
    @State var durationSelection: Int = 10

    let pickerData: [Int] = Array(stride(from: 60, to: 200 + 1, by: 1))

    var body: some View {
        VStack {
            Picker(selection: $durationSelection, label: Text("Workout Duration")) {
                Text("10 minutes").tag(1)
                Text("15 minutes").tag(2)
                Text("30 minutes").tag(3)
                
            }
            Picker(selection: $hrMaxSelection, label: Text("HRMax")) {
                ForEach(pickerData, id: \.self) { num in
                    Text("\(num)").tag(num)
                }
            }
            Button("Set", action: {
                UserDefaultsController.saveWorkoutDuration(workoutDuration: durationSelection)
                workoutDuration = durationSelection;
                UserDefaultsController.saveHRMax(hrMax: hrMaxSelection)
                hrMax = hrMaxSelection
                tab = "Two"
            })
        }.onDisappear() {
            print("HRMax: \(hrMax)")
            print("Duration: \($durationSelection.wrappedValue) minutes")
        }.scaledToFit()
    }
    
}
