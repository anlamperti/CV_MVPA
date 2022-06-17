//
//  MVPA_WorkoutApp.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/8/21.
//

import SwiftUI
import CoreData

@main
struct MVPA_WorkoutApp: App {
    
    
    @StateObject var hkController = HealthKitController()
    @State private var tabSelection = 1
    let persistence = Persistence()
    
    var body: some Scene {
        WindowGroup {
            if (hkController.authorized) {
                TabView(selection: $tabSelection) {
                    DataSelectionView()
                        .tabItem {
                            Image(systemName: "calendar")
                            Text("Data")
                        }
                        .tag(0)

                    PeopleView(tabSelection: $tabSelection)
                        .tabItem {
                            Image(systemName: "person.2")
                            Text("Users")
                        }
                        .tag(1)

                    UnassignedDataView()
                        .tabItem {
                            Image(systemName: "gearshape")
                            Text("Unassigned")
                        }
                        .tag(2)
                }
            } else {
                Text("HealthKit Authorization Failed").onAppear {
                    print("here")
                }
            }
            
        }
    
    }
}
