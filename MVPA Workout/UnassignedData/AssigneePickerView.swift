//
//  AssigneePickerView.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 3/20/22.
//

import SwiftUI
import HealthKit

struct AssigneePickerView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var persistence = Persistence()
    
    @State var delegate: UnassignedDataView
    let workout: HKWorkout
    
    @State var showConfirmation = false
    @State var users: [User]
    @State var selectedIndex = 0
    
    init (delegate: UnassignedDataView, workout: HKWorkout) {
        self._delegate = State(initialValue: delegate)
        self.workout = workout
        
        let usersList = delegate.users
        _users = State(initialValue: usersList)
        _selectedIndex = State(initialValue: 0)
    }
      
    var body: some View {
        VStack {
            if (!users.isEmpty) {
                List (users.indices, id: \.self) { index in
                    HStack {
                        Text("User \(users[index].id)")
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedIndex = index
                        showConfirmation = true
                    }
                    .confirmationDialog(
                        "Assign to User \(users[selectedIndex].id)",
                        isPresented: $showConfirmation,
                        titleVisibility: .visible
                    ){
                        Button("Yes") { assignUser(user: users[selectedIndex]) }
                    }
                }
            } else {
                List {
                    Text("No Users")
                }
            }
        }
        .onAppear() { reloadUsers() }
        .navigationBarTitle("Users")
        .toolbar {
            ToolbarItem {
                Button(action: {
                    persistence.addUser()
                    reloadUsers()
                }) {
                    Image(systemName: "person.badge.plus")
                }
            }
        }
    }
    
    func reloadUsers() {
        users = persistence.getAllUsers()
    }
    
    func assignUser(user: User) {
        delegate.assignWorkout(workout: workout, user: user)
        self.presentationMode.wrappedValue.dismiss()
    }
}
