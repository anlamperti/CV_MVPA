//
//  HRMax+CoreDataProperties.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 4/4/22.
//
//
//import Foundation
//import CoreData
//
//extension HRMax {
//    
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<HRMax> {
//        return NSFetchRequest<HRMax>(entityName: "HRMax")
//    }
//    @NSManaged public var user: User
//    @NSManaged public var score: Int16
//    
//}
//
//extension HRMax : Identifiable {
//
//}

//public struct PersistenceController {
//    
//    // A singleton for our entire app to use
//    static let shared = PersistenceController()
//
//    // Storage for Core Data
//    let container: NSPersistentContainer
//
//    // A test configuration for SwiftUI previews
//    static var preview: PersistenceController = {
//        let controller = PersistenceController(inMemory: true)
//
//        for _ in 0..<10 {
//            let hrMax = HRMax(context: controller.container.viewContext)
//        }
//        return controller
//    }()
//
//    // An initializer to load Core Data, optionally able
//    // to use an in-memory store.
//    init(inMemory: Bool = false) {
//        // If you didn't name your model Main you'll need
//        // to change this name below.
//        container = NSPersistentContainer(name: "Main")
//
//        if inMemory {
//            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
//        }
//
//        container.loadPersistentStores { description, error in
//            if let error = error {
//                fatalError("Error: \(error.localizedDescription)")
//            }
//        }
//    }
//    func save() {
//        let context = container.viewContext
//
//        if context.hasChanges {
//            do {
//                try context.save()
//            } catch {
//                // Show some error here
//            }
//        }
//    }
//}
//
