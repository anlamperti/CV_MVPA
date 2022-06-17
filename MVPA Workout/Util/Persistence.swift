//
//  Persistence.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/19/21.
//

import CoreData
import SwiftUI
import WatchConnectivity

class Persistence {
    
    @Environment(\.managedObjectContext) var managedObjectContext

    static var persistentContainer: NSPersistentContainer = {
      let container = NSPersistentContainer(name: "Activity")
      container.loadPersistentStores { _, error in
        if let error = error as NSError? {
          // You should add your own error handling code here.
          fatalError("Unresolved error \(error), \(error.userInfo)")
        }
      }
      return container
    }()
    
    static var moc: NSManagedObjectContext = {
        return Persistence.persistentContainer.viewContext
    }()
    
    let moc = Persistence.moc
    
    func saveContext() {
        if moc.hasChanges {
        do {
          try moc.save()
        } catch {
          // The context couldn't be saved.
          // You should add your own error handling here.
          let nserror = error as NSError
          fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
      }
    }
    
    func getActivities(userId: String) -> [Activity] {
        let predicate = NSPredicate(format: "userId == %@", userId)
        return getActivities(predidate: predicate)
    }
    
    func getActivities(date: String) -> [Activity] {
        let predicate = NSPredicate(format: "date == %@", date)
        return getActivities(predidate: predicate)
    }
    
    func getVisibleUsers() -> [User] {
        let predicate = NSPredicate(format: "hidden == %@", NSNumber(value: false))
        return getUsers(predicate: predicate)
    }
    
    func getAllUsers() -> [User] { return getUsers(predicate: nil) }
    
    func getUser(userId: Int) -> User? {
        let predicate = NSPredicate(format: "id == %@", NSNumber(value: userId))
        return getUsers(predicate: predicate).first
    }
//    func setHRMax(userId: Int) -> User? {
//        let predicate = NSPredicate(format: "HRMax == %@", NSNumber(value: Int))
//    }
    
    private func getUsers(predicate: NSPredicate?) -> [User] {
        let activityFetch: NSFetchRequest<User> = User.fetchRequest()
        if let predicate = predicate {
            activityFetch.predicate = predicate
        }
        do {
            return try moc.fetch(activityFetch)
        } catch {
            fatalError("Failed to fetch users: \(error)")
        }
    }

    private func getActivities(predidate: NSPredicate) -> [Activity] {
        let activityFetch: NSFetchRequest<Activity> = Activity.fetchRequest()
        activityFetch.predicate = predidate
        do {
            return try moc.fetch(activityFetch)
        } catch {
            fatalError("Failed to fetch users: \(error)")
        }
    }
    
    func addActivity(
        user: User,
        date: Date,
//        hrMax: Int,
        averageBpm: Int,
        bpmData: [BpmMeasurement])
    {
        let newActivity = Activity(context: moc)

        newActivity.user = user
//        newActivity.hrMax = Int16(hrMax)
        newActivity.averageBpm = Int16(averageBpm)
        newActivity.date = date
        newActivity.hidden = false
        
        let _: [BPM] = bpmData.map {
            let bpm = BPM(context: moc)
            bpm.date = $0.date
            bpm.value = Int16($0.value)
            bpm.activity = newActivity
            return bpm
        }
        
        saveContext()
    }
    
    func addUser() {
        let nextUserId = UserDefaultsController.loadNextUserId()
        addUser(id: nextUserId)
        UserDefaultsController.saveNextUserId(hrMax: nextUserId + 1)
    }
    
    private func addUser(id: Int) {
        let newUser = User(context: moc)
        newUser.id = Int16(id)
        newUser.hidden = false
        saveContext()
    }
    
    func hideUser(user: User) {
        user.hidden = true
        saveContext()
    }
    
    func deleteUser(user: User) {
        moc.delete(user)
        saveContext()
    }
    
}

