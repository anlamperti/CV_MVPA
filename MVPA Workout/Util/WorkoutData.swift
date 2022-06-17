//
//  WorkoutData.swift
//  MVPA Workout
//
//  Created by Alex Herrin on 11/10/21.
//

import Foundation

public struct BpmMeasurement {
    let value: Int
    let date: Date
}

extension BpmMeasurement: Hashable {
    public static func == (lhs: BpmMeasurement, rhs: BpmMeasurement) -> Bool {
        return lhs.value == rhs.value && lhs.date == rhs.date
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(date)
    }
}

public struct Workout {
    let bpmData: [BpmMeasurement]
    let averageBpm, hrMaxPercentage: Int
    let date: Date
}

extension Workout: Hashable {
   public static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.date == rhs.date &&
        lhs.averageBpm == rhs.averageBpm &&
        lhs.hrMaxPercentage == rhs.hrMaxPercentage &&
        lhs.bpmData.elementsEqual(rhs.bpmData)
    }

   public func hash(into hasher: inout Hasher) {
        hasher.combine(bpmData)
        hasher.combine(averageBpm)
        hasher.combine(date)
    }
}
