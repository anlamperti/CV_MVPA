//
//  UserDefaultsController.swift
//  MVPA Workout WatchKit Extension
//
//  Created by Alex Herrin on 11/8/21.
//

import Foundation

class UserDefaultsController {

    struct Keys {
        static let hrMax = "hrMax"
        static let AvgHr = "AvgHr"
        static let workoutDuration = "workoutDuration"
        
    }

    static func loadHRMax() -> Int {
        return UserDefaults.standard.integer(forKey: Keys.hrMax)
    }

    static func saveHRMax(hrMax: Int) {
        UserDefaults.standard.set(hrMax, forKey: Keys.hrMax)
    }
    static func saveAvgHr(AvgHr: Int) {
        UserDefaults.standard.set(AvgHr, forKey: Keys.AvgHr)
        
    }
    static func saveWorkoutDuration(workoutDuration: Int) {
        UserDefaults.standard.set(workoutDuration, forKey: Keys.workoutDuration)
    }
    static func loadWorkoutDuration() -> Int {
        return UserDefaults.standard.integer(forKey: Keys.workoutDuration)
    }
    
}



