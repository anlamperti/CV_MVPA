//
//  PeopleDetailsView.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/20/21.
//

import Foundation
import SwiftUI
import WatchConnectivity

struct PeopleDetailsView: View {

    @Binding var parrent: PeopleView
    @State var user: User
    @State var textField: TextFieldAlert
    @State var hrMax: Int
    let title: String
    @State var score: Int
    let persistence = Persistence()
//    @State var newValue: Int
    
//    init (newValue: Int?, score: Int?, hrMax: Int?) {
////        updateHrMax()
////        _newValue = State(value: $score)
//        _score = State(initialValue: newValue)
//        _newValue = State(initialValue: score)
//        _hrMax = State(initialValue: newValue)
//    }
//    func updateHrMax() {
//        let newValue = $score.wrappedValue
//        hrMax = newValue
//        print("hrMax: \(hrMax ?? 0) newValue: \(newValue)")
//
//    }
//    @Environment(\.managedObjectContext) var managedObjectContext
//    @FetchRequest(entity: HRMax.entity(), sortDescriptors: []) var items: FetchedResults<HRMax>
    
    var body: some View {
        GeometryReader { (deviceSize: GeometryProxy) in
            
            VStack {
            if (!user.activitiesArray.isEmpty) {
                List(user.activitiesArray, id: \.self) { activity in
                    NavigationLink(destination: Text("TBD")) {
                        HStack {
                            Text(activity.date.formatted(.dateTime.hour().minute()))
                                .bold()
                            HStack(alignment: .center) {
                                Text("Avg: \(activity.averageBpm)")
//                                Text("HRMax: \(hrMax)")
                            }
                        }
                    }
                }
            } else {
                List {
                    Text("No workouts assigned")
                }
            }
        }
        .toolbar {
            HStack {
                Button(action: {
                    parrent.tabSelection = 2
                }) {
                    Image(systemName: "waveform.path.badge.plus")
                }
                NavigationLink ("HRMax", destination: TextFieldAlert(score: score, hrMax: hrMax, user: user))
//                            print("Button Pressed")
                    }
                   
                }

        .navigationBarTitle(Text("User \(user.id)"))
        .onAppear() {
            if let fetchedUser = persistence.getUser(userId: Int(user.id)) {
                user = fetchedUser
                }
            }
        }
    }
}

    
