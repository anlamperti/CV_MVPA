//
//  BPM+CoreDataProperties.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/21/21.
//
//

import Foundation
import CoreData


extension BPM {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BPM> {
        return NSFetchRequest<BPM>(entityName: "BPM")
    }

    @NSManaged public var date: Date
    @NSManaged public var value: Int16
    @NSManaged public var activity: Activity
    
}

extension BPM : Identifiable {

}


