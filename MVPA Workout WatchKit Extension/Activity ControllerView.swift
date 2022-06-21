//
//  Activity ControllerView.swift
//  MVPA Workout WatchKit Extension
//
//  Created by Alex Herrin on 11/8/21.
//

import Foundation
import SwiftUI
import HealthKit
import WatchKit
import UserNotifications

struct Constants {
    static let activityDurationSec = 60.0
    static let targetPercentageAboveTargetBPM = 0.5
    static let samplesToReachGoal = Int(activityDurationSec / 5 / 2)
    static let lowerBoundPercentage = 0.5
}

class ActivitySampleProcessor: NSObject {
    let workoutManager = WorkoutManager()
    var hrMax : Int = 100
    var bpmValues: [Int] = []
    var percentageOfGoalComplete: Double = 0

    var targetBPM: Int { Int(Double(hrMax) * Constants.lowerBoundPercentage) }
    var currentPercentageAboveTargetBPM: Double = 0
    var aboveTarget = false

    // Sound and notifications
    let device = WKInterfaceDevice()
    let center = UNUserNotificationCenter.current()

    var dingTimer = Timer()
    private var dingCounter = 0
    var activityColor = Color.darkGrey


    func recalculatePercentage(bpm: Int) {
        self.bpmValues.append(bpm)
        let samplesAboveTarget: Int = self.bpmValues.reduce(0) {
            partialResult, bpm in
            let sampleIsAboveTarget = (Int(bpm) >= targetBPM ? 1 : 0)
            return partialResult + sampleIsAboveTarget
        }

        // for the ring
        self.percentageOfGoalComplete = Double(samplesAboveTarget) / Double(Constants.samplesToReachGoal)
        print(Double(samplesAboveTarget))
        print(Double(Constants.samplesToReachGoal))
        print(percentageOfGoalComplete)
        print("Goal complate: \(Double(percentageOfGoalComplete * 100))%")

        // for activity success
        print("samplesAboveTarget: \(samplesAboveTarget), total \(self.bpmValues.count)")
        self.currentPercentageAboveTargetBPM = Double(samplesAboveTarget) / Double(self.bpmValues.count)

        print("currentPercentageAboveTargetBPM: \(Int(currentPercentageAboveTargetBPM * 100))%")
    }

    func processSample() {
        let bpm = Int(workoutManager.heartRate.rounded())

        print("------------------ process sample -----------------------")
        let hrMaxPercent = Int(Double(bpm) / Double(hrMax) * 100)
        print("bpm: \(bpm), hrMaxPercent: \(hrMaxPercent)%")
        recalculatePercentage(bpm: bpm)

        print("aboveTarget \(aboveTarget) targetBPM \(targetBPM)")

        if !aboveTarget && bpm >= targetBPM {
            aboveTarget = true
            device.play(.start)
            center.add(UNNotificationRequest(identifier: "ding",
                                             content: UNNotificationContent(),
                                             trigger: nil))
            activityColor = .green

            // init timer

            dingTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self] _ in
                self?.dingCounter += 1
                if self?.dingCounter == 10 {
                    self?.device.play(.start)
                    self?.dingCounter = 0
                }
            })
        } else if (bpm <= targetBPM) {
            aboveTarget = false
            activityColor = .darkGrey

            // reset timer
            dingTimer.invalidate()
            dingCounter = 0
        }

        print("done with sample")
    }
}

struct ActivityControllerView: View {
    @Binding var workoutDuration: Int
    @Binding var hrMax: Int
    var targetBPM: Int { Int(Double(hrMax) * Constants.lowerBoundPercentage) }
    
    @State var activityEngaged = false
    @State var activityColor = Color.darkGrey
    @State var finalColor = Color.darkGrey
    @State var labelText = "Start"
    @State var aboveTarget = false
    @State var soundEnabled = false
    @State var circleDiameter: CGFloat = 150

    @State var percentageOfGoalComplete: Double = 0

    @StateObject private var phoneConnector = PhoneConnector()

    @State var dingTimer = Timer()
    @State private var dingCounter = 0

    let processor = ActivitySampleProcessor()
    var workoutManager : WorkoutManager { self.processor.workoutManager }
    
    //    var model = ConnectivityProvider()
    
    func setUp() -> Void {
        print("request sound permissions")
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound]) { granted, error in
            soundEnabled = granted
        }
        
        print("request workout manager permissions")
        workoutManager.delegate = self.processor
        workoutManager.requestAuthorization()
    }
    
    var body: some View {
        VStack {
            if activityEngaged {
                ActivityRunning(color: $activityColor, diameter: $circleDiameter)
                
            } else {
                ActivityStopped(delegate: .constant(self),
                                color: $finalColor,
                                bottomLabelText: $labelText,
                                hrMax: $hrMax)
            }
        }.onAppear {
            setUp()
        }
    }

    func startActivity() -> Void {
        print("targetBPM \(targetBPM)")

        // init activity values
        self.processor.bpmValues = []
        self.processor.activityColor = .darkGrey
        
        activityEngaged = workoutManager.startWorkout(workoutType: .other)
        if (activityEngaged) {
            // start timer for activity compleation
            let activityEndTime = DispatchTime.now() + Constants.activityDurationSec
            DispatchQueue.main.asyncAfter(deadline: activityEndTime, execute: endActivity)
            print("activityStarted")
        
        } else {
            print("failed to start activity")
        }
    }
    
    func endActivity() {
        workoutManager.endWorkout()
                
        if percentageOfGoalComplete >= 1 {
            self.processor.device.play(.success)
            finalColor = .green
        } else {
            self.processor.device.play(.failure)
            finalColor = .darkGrey
        }
    
        labelText = "\(Int(self.processor.currentPercentageAboveTargetBPM * 100))%"
        activityEngaged = false
//        phoneConnector.sendWorkoutData(bpm: 25, averageBpm: 25, hrMaxPercentage: 30)
        print("activity ended acv")
    }
    
    func updateColor(value: Int, dst: UnsafeMutablePointer<Color>) {
        dst.pointee = value >= targetBPM ? .green : .darkGrey
    }
    
}

struct ActivityStopped : View {
    let pressDuration = 2.0
//    var model = ConnectivityProvider()

    @Binding var delegate: ActivityControllerView
    @Binding var color: Color
    @Binding var bottomLabelText: String
    @Binding var hrMax: Int

    
    var body: some View {
        VStack {
            HStack {
                Text(bottomLabelText)
                    .frame(width: 100, height: 100)
                    .background(color)
                    .clipShape(Circle())
                    .scaleEffect(1.5)
                    .onTapGesture {
                        if (bottomLabelText == "Start") {
                            delegate.startActivity()
                        }
                    }
                    .onLongPressGesture(
                        minimumDuration: pressDuration,
                        perform: delegate.startActivity
//                      perform: TargetSelectionView()
                    )
                    .onTapGesture(count: 5) {
                        hrMax = 0
//                        testing 
                    }
            }
        }
    }
}

struct ActivityRunning: View {
    @Binding var color: Color
    @Binding var diameter: CGFloat
    
    var body: some View {
        VStack {
            HStack {
                ZStack {
                    Circle()
                        .fill(color)
                        .frame(width: diameter, height: diameter)
                    Circle()
                        .stroke(Color.white, lineWidth: 7)
                        .frame(width: diameter, height: diameter)
                }
            }
        }
    }
}

