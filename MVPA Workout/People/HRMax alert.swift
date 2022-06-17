//
//  HRMax alert.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 4/4/22.
//

import Foundation
import SwiftUI
import notify
import UIKit
import CoreData

struct TextFieldAlert: View {
    

    @State var score: Int
    @State var hrMax: Int
    private let persistence = Persistence()
    @State private var isPresented: Bool = false
    @State var user: User

    @Environment(\.managedObjectContext) var managedObjectContext
    
    static var moc: NSManagedObjectContext = {
        return Persistence.persistentContainer.viewContext
    }()
    
    var body: some View {
        GeometryReader { reader in
            VStack(alignment: .center) {
                Form {
                    Section {
                        Text(" Enter HRMax for User \(user.id)")
                        TextField("HRMax", value: $score, format: .number)
                    }
                    Section {
                        Button("Enter", role: .none) {
                            isPresented = true
                            print("\($score.wrappedValue)")
                        }.alert("Set HRMax to \($score.wrappedValue) for User \(user.id)", isPresented: $isPresented) {
                                Button("No", role: .cancel) {}
                                Button ("Yes", action: {
//                                    if managedObjectContext.hasChanges {
//                                        do {
//                                            try managedObjectContext.save(
//                                                let hrMax = $score.wrappedValue;)
//                                        } catch {
//                                        // handle the Core Data error
//                                    }
//                                }
                            })
                        }
                    }
                }
            }
            .foregroundColor(.white)
        }
    }
}
    
struct UpdateHrMax {
    
    @State var newValue: Int?
    @State var score: Int?
    @State var hrMax: Int? {
        didSet {
            print ("didSet was called")
        }
    }
    init (newValue: Int?, score: Int?, hrMax: Int?) {
        updateHrMax()
//        _newValue = State(value: $score)
        _score = State(initialValue: newValue)
        _newValue = State(initialValue: score)
        _hrMax = State(initialValue: newValue)
    }
    func updateHrMax () {
        let score = $score.wrappedValue
        hrMax = score
    }
}

