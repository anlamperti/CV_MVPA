//
//  User+CoreDataProperties.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/21/21.
//
//

import Foundation
import CoreData


extension User {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }
    @NSManaged public var hidden: Bool
    @NSManaged public var id: Int16
    @NSManaged private var activities: NSOrderedSet?
    @NSManaged private var hrMax: Int
    
    // cast NSOrderedSet to [RelationshipType]
    public var activitiesArray: [Activity] {
        let set = activities?.set as? Set<Activity> ?? []
        return set.sorted {
            $0.date < $1.date
        }
    }
    
    public func hasActivities() -> Bool {
        return !activitiesArray.isEmpty
    }
}

// MARK: Generated accessors for activities
extension User {

    @objc(insertObject:inActivitiesAtIndex:)
    @NSManaged public func insertIntoActivities(_ value: Activity, at idx: Int)

    @objc(removeObjectFromActivitiesAtIndex:)
    @NSManaged public func removeFromActivities(at idx: Int)

    @objc(insertActivities:atIndexes:)
    @NSManaged public func insertIntoActivities(_ values: [Activity], at indexes: NSIndexSet)

    @objc(removeActivitiesAtIndexes:)
    @NSManaged public func removeFromActivities(at indexes: NSIndexSet)

    @objc(replaceObjectInActivitiesAtIndex:withObject:)
    @NSManaged public func replaceActivities(at idx: Int, with value: Activity)

    @objc(replaceActivitiesAtIndexes:withActivities:)
    @NSManaged public func replaceActivities(at indexes: NSIndexSet, with values: [Activity])

    @objc(addActivitiesObject:)
    @NSManaged public func addToActivities(_ value: Activity)

    @objc(removeActivitiesObject:)
    @NSManaged public func removeFromActivities(_ value: Activity)
    
//    @objc(addHRMaxObject:)
//    @NSManaged public func addToHRMaxData(_ value: HRMax)
    
    @objc(addActivities:)
    @NSManaged public func addToActivities(_ values: NSOrderedSet)

    @objc(removeActivities:)
    @NSManaged public func removeFromActivities(_ values: NSOrderedSet)
    
//    @objc(addHRMax:)
//    @NSManaged public func addToHRMaxData(_ values: NSOrderedSet)
    
}

extension User : Identifiable {

}
