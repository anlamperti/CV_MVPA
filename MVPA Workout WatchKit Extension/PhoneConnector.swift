//
//  PhoneConnector.swift
//  MVPA Workout WatchKit Extension
//
//  Created by Alex Herrin on 11/8/21.
//

import SwiftUI
import WatchConnectivity
import UIKit

class ConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {


    var session: WCSession
    @Published var messageText = ""

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
    }
        
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        connect()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
           DispatchQueue.main.async {
               self.messageText = message["message"] as? String ?? "Unknown"
           }
       }
    
    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }
       
        session.activate()
    }

    func send(message: [String:Any]) -> Void {
        session.sendMessage(message, replyHandler: nil) { (error) in
            print(error.localizedDescription)
        }
    }

}


final class PhoneConnector: ObservableObject {
    
    @StateObject private var workoutManager = WorkoutManager()
    private(set) var provider: ConnectivityProvider
    
    init() {
        self.provider = ConnectivityProvider()
        provider.connect()
    }
    
    func sendWorkoutData(bpm: Int, averageBpm: Int, hrMaxPercentage: Int) {
        let data: [String:Int] = [
            "bpm": bpm,
            "averageBpm": averageBpm,
            "hrmPercentage": hrMaxPercentage
        ]
        provider.send(message: data) 
    }
}
