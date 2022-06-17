//
//  PeopleView.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/20/21.
//
import SwiftUI
import Foundation
import WatchConnectivity

struct PeopleView: View {
    @Binding var tabSelection: Int
    
    private let persistence = Persistence()
    @State private var hiddenUsers: [User] = []
    @State private var visibleUsers: [User] = []
    @State private var showHiddenUsers = false
    @State var showingDeleteAlert = false
    @State var userToDelete: User? = nil
    @State var hrMax: Int = 0
    
    @State var score: Int = 0
    
    func loadUsers() {
        let users = persistence.getAllUsers()
        (hiddenUsers, visibleUsers) = users.stablePartition { $0.hidden }
    }
    
    func addUser() {
        persistence.addUser()
        loadUsers()
    }
    
    func toggleUserVisibibity(_ user: User) {
        user.hidden = !user.hidden
        persistence.saveContext()
        print("toggle: \(user.hidden)")
        loadUsers()
    }
    
    func showDeleteAlert(user: User) {
        showingDeleteAlert = true
        userToDelete = user
    }
      
    var body: some View {
        NavigationView {
            List {
                if (showHiddenUsers) {
                    PersonSection(users: visibleUsers, title: "Visible", hrMax: hrMax, score: score, parrent: .constant(self))
                    PersonSection(users: hiddenUsers, title: "Hidden", hrMax: hrMax, score: score, parrent: .constant(self))
                } else {
                    PersonList(users: visibleUsers, title:"", parrent: .constant(self), hrMax: hrMax, score: score)
                }
            }.alert(isPresented: $showingDeleteAlert) {
                Alert(
                    title: Text("Are you sure?"),
                    message: Text("User \(userToDelete!.id) will be gone forever"),
                    primaryButton: .destructive(Text("Delete")) {
                        persistence.deleteUser(user: userToDelete!)
                        loadUsers()
                    },
                    secondaryButton: .cancel()
                )
            }
            .navigationBarTitle("People")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showHiddenUsers.toggle() }) {
                        Image(systemName: showHiddenUsers ? "eye.slash" : "eye")
                    }
                }
                ToolbarItem {
                    Button(action: addUser) {
                        Image(systemName: "person.badge.plus")
                    }
                }
            }
        }.onAppear {
            loadUsers()
        }
        
    }
    
}

struct PersonList: View {
    var users: [User]
    var title: String
    @Binding var parrent: PeopleView
    @State var hrMax: Int
//    @State var isShowingAlert: Bool
    @State var score: Int
    
    var body: some View {
        if (!users.isEmpty) {
            ForEach (users, id: \.self) { user in
                PersonItem(user: user, title: title, hrMax: hrMax, score: score , parrent: $parrent)
            }
        } else {
            Text("Nothing to see here")
        }
    }
}

struct PersonSection: View {
    var users: [User]
    var title: String
    @State var hrMax: Int
    @State var score: Int
    @Binding var parrent: PeopleView
//    @State var selectedUser: TextFieldAlert
    var body: some View {
        Section(header: Text(title)) {
            PersonList(users: users, title: title, parrent: $parrent, hrMax: hrMax, score: score)
        }
    }
}

struct PersonItem: View {
    @State var user: User
    var title: String
    @State var hrMax: Int
    @State var score: Int
    @Binding var parrent: PeopleView

    var body: some View {
        HStack {
            NavigationLink(destination: PeopleDetailsView(parrent: $parrent, user: user,  textField: TextFieldAlert(score: score, hrMax: hrMax, user: user), hrMax: hrMax, title: title, score: score)) {
                Text("User \(user.id)")
                if (user.hasActivities()) {
                    Image(systemName: "chart.bar")
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundColor(.green)
                }
            }
            .disabled(user.hidden)
        }.swipeActions(allowsFullSwipe: false) {
            Button {
                parrent.toggleUserVisibibity(user)
            } label: {
                Label("Show", systemImage: user.hidden ? "eye" : "eye.slash")
            }
            .tint(user.hidden ? .blue : .gray)

            Button {
                parrent.showDeleteAlert(user: user)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .tint(.red)
        }
        
    }
}

    
 
