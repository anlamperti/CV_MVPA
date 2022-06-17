//
//  ContentView.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/8/21.
//

import SwiftUI
import WatchConnectivity

struct DataSelectionView: View {
    @State private var date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                       .accentColor(.blue)
                       .datePickerStyle(.graphical)
                    NavigationLink(destination: WorkoutView(dateSelection: date)) {
                        Button("Select Date", action: {})
                    }
                }
            }
            .navigationBarTitle("Date of Activity")
        }

    }

}
