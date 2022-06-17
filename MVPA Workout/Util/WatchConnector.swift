//
//  WatchConnector.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/8/21.
//

import SwiftUI
import WatchConnectivity
import Foundation
import MapKit
import HealthKit

class ConnectivityProvider: NSObject, WCSessionDelegate, ObservableObject {
    
    @Published var message = ""
    var persistence = Persistence()

    private let session: WCSession
    public var isReachable: Bool {
        get {
            return session.isReachable
        }
    }

    init(session: WCSession = .default) {
        self.session = session
        super.init()
        self.session.delegate = self
        session.activate()
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        connect()
//        print("activationDidCompleteWith")
//        print(activationState.rawValue)
    // persistence.addActivity(userId: T##String, date: <#T##Date#>, hrMaxPercentage: <#T##Int#>, averageBpm: <#T##Int#>, bpmData: <#T##[BpmMeasurement]#>)
    }
    public func sessionDidBecomeInactive(_ session: WCSession) {
        // code
    }
    
    public func sessionDidDeactivate(_ session: WCSession) {
//        connect()
    }
    
    func connect() {
        guard WCSession.isSupported() else {
            print("WCSession is not supported")
            return
        }

        session.activate()
    }
        
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
           print(message)
    }

}


final class WatchConnector: ObservableObject {

    private(set) var provider: ConnectivityProvider

    init() {
        provider = ConnectivityProvider()
        provider.connect()
    }

    func sendMessage(txt: String) -> Void {
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // code
        // persistence.addActivity(userId: T##String, date: <#T##Date#>, hrMaxPercentage: <#T##Int#>, averageBpm: <#T##Int#>, bpmData: <#T##[BpmMeasurement]#>)
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // code
    }

    func sessionDidDeactivate(_ session: WCSession) {
       //code

    }
}
