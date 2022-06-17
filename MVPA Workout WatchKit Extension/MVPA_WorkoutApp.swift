//
//  MVPA_WorkoutApp.swift
//  MVPA Workout WatchKit Extension
//
//  Created by Alex Herrin on 11/8/21.
//

import SwiftUI
import WatchConnectivity
import Foundation
import MapKit
import WatchKit

@main
struct MVPA_WorkoutApp: App {
    @State var hrMax: Int = UserDefaultsController.loadHRMax()
    @State var workoutDuration: Int = UserDefaultsController.loadWorkoutDuration()
    @State private var selectedTab = "One"
    var workoutManager = WorkoutManager()
    
    public func lockscreen() {
        if workoutManager.running == true {
            WKInterfaceDevice.current().enableWaterLock()
            print ("screen locked")
        }
    }
            
    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                TargetSelectionView(hrMax: $hrMax, tab: $selectedTab, workoutDuration: $workoutDuration)
                    .tag("One")
                ActivityControllerView(workoutDuration: $workoutDuration, hrMax: $hrMax)
                    .tag("Two")
                }
    //            NavigationView {
    //                if (hrMax == 0) {
    //                    TargetSelectionView(hrMax: $hrMax)
    //                } else {
    //                    ActivityControllerView(hrMax: $hrMax)
    //                }
    //            }
        }
        
        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
    
}
