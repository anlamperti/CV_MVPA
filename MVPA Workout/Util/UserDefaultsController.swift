//
//  UserDefaultsController.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 3/20/22.
//

import Foundation

class UserDefaultsController {

    private struct Keys {
        static let LAST_ASSIGNED_DATE = "lastAssignedDate"
        static let NEXT_USER_ID = "nextUserId"
    }

    static func loadLastAssignedDate() -> Date {
        let zero = Date(timeIntervalSince1970: TimeInterval(0))
        return UserDefaults.standard.object(forKey: Keys.LAST_ASSIGNED_DATE) as? Date ?? zero
    }

    static func saveLastAssignedDate(date: Date) {
        UserDefaults.standard.set(date, forKey: Keys.LAST_ASSIGNED_DATE)
    }
    
    static func loadNextUserId() -> Int {
        return UserDefaults.standard.integer(forKey: Keys.NEXT_USER_ID)
    }

    static func saveNextUserId(hrMax: Int) {
        UserDefaults.standard.set(hrMax, forKey: Keys.NEXT_USER_ID)
        
    }
    
}
