//
//  MyExtensions.swift
//  MVPA Workout WatchKit Extension
//
//  Created by Alex Herrin on 11/8/21.
//

import Foundation
import SwiftUI

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
    
    public static let darkGrey = Color(hex: 0x333333)
}

extension Array {
    func stablePartition(by condition: (Element) -> Bool) -> ([Element], [Element]) {
        var matching = [Element]()
        var nonMatching = [Element]()
        for element in self {
            if condition(element) {
                matching.append(element)
            } else {
                nonMatching.append(element)
            }
        }
        return (matching, nonMatching)
    }
}
