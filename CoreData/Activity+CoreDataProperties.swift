//
//  Activity+CoreDataProperties.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/21/21.
//
//

import Foundation
import CoreData
import HealthKit


extension Activity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Activity> {
        return NSFetchRequest<Activity>(entityName: "Activity")
    }

    @NSManaged public var averageBpm: Int16
    @NSManaged public var date: Date
    @NSManaged public var hidden: Bool
//    @NSManaged public var hrMax: Int16
    @NSManaged private var bpmData: NSOrderedSet?
    @NSManaged public var user: User

    // cast NSOrderedSet to [RelationshipType]
    public var bpmDataArray: [BPM] {
        let set = bpmData?.set as? Set<BPM> ?? []
        return set.sorted {
            $0.date < $1.date
        }
    }
}

// MARK: Generated accessors for bpmData
extension Activity {

    @objc(insertObject:inBpmDataAtIndex:)
    @NSManaged public func insertIntoBpmData(_ value: BPM, at idx: Int)

    @objc(removeObjectFromBpmDataAtIndex:)
    @NSManaged public func removeFromBpmData(at idx: Int)

    @objc(insertBpmData:atIndexes:)
    @NSManaged public func insertIntoBpmData(_ values: [BPM], at indexes: NSIndexSet)

    @objc(removeBpmDataAtIndexes:)
    @NSManaged public func removeFromBpmData(at indexes: NSIndexSet)

    @objc(replaceObjectInBpmDataAtIndex:withObject:)
    @NSManaged public func replaceBpmData(at idx: Int, with value: BPM)

    @objc(replaceBpmDataAtIndexes:withBpmData:)
    @NSManaged public func replaceBpmData(at indexes: NSIndexSet, with values: [BPM])

    @objc(addBpmDataObject:)
    @NSManaged public func addToBpmData(_ value: BPM)

    @objc(removeBpmDataObject:)
    @NSManaged public func removeFromBpmData(_ value: BPM)
    


    @objc(addBpmData:)
    @NSManaged public func addToBpmData(_ values: NSOrderedSet)

    @objc(removeBpmData:)
    @NSManaged public func removeFromBpmData(_ values: NSOrderedSet)
    
}

extension Activity : Identifiable {

}
