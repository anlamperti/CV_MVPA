//
//  ContentView.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/8/21.
//

import SwiftUI
import WatchConnectivity
import SwiftUI


let viewModel = ViewModel(connectivityProvider: ConnectivityProvider())
let contentView = DateSelectionView(viewModel: viewModel)

class ConnectivityProvider: NSObject, WCSessionDelegate {
    
    private let session: WCSession
    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
    }
    func send(message: [String:Any]) -> Void {
        session.sendMessage(message, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // code
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // code
    }
}
final class ViewModel: ObservableObject {

    private(set) var connectivityProvider: ConnectivityProvider
    var textFieldValue: String = ""
    
    init(connectivityProvider: ConnectivityProvider) {
        self.connectivityProvider = connectivityProvider
    }
    
    func sendMessage() -> Void {
        let txt = textFieldValue
        let message = ["message":txt]
        connectivityProvider.send(message: message)
    }
}

struct DateSelectionView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var date = Date()
    let dateRange: ClosedRange<Date> = {
        let calender = Calendar.current
        let startComponents = DateComponents(year: 2021, month: 1, day: 1)
        let endComponents = DateComponents(year: 2021, month:12,day:31, hour:23, minute:59, second:59)
        return calender.date(from:startComponents)!...calender.date(from:endComponents)!
    }()
    var body: some View {
        VStack {
            TextField("Message Content", text: $viewModel.textFieldValue)
                       
                       Button(action: {
                           self.viewModel.sendMessage()
                       }) {
                           Text("Send Message")
                       }
                   }
    
            DatePicker(
                "Date",
                selection: $date,
                in: dateRange,
                displayedComponents: [.date, .hourAndMinute]
                )
                .accentColor(/*@START_MENU_TOKEN@*/.blue/*@END_MENU_TOKEN@*/)
                .datePickerStyle(.graphical)
    }
}

