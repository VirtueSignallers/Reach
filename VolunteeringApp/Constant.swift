//
//  Constant.swift
//  VolunteeringApp
//
//  Created by Valerie Chen on 7/8/16.
//  Copyright © 2016 Devshi Mehrotra. All rights reserved.
//

import UIKit
import Foundation

class Constant: NSObject {

    static let themeColor = UIColor(red: 0.68, green: 0.05, blue: 0.36, alpha: 1.0)

    static func distanceToMilesAway(distance: CLLocationDistance) -> String {
        let miles = distance / 1609.34
        let roundedMiles = Int(round(miles))
        if roundedMiles > 1 {
            return "\(String(roundedMiles)) mi"
        } else {
            return "<1 mi"
        }
    }
    
    static func newDistanceToMilesAway(distance: Int) -> String {
        if distance > 1 {
            return "\(String(distance)) mi"
        }
        else {
            return "<1 mi"
        }
    }
    
    static func extractInt(achievement: String) -> Int {
        let strInt = achievement.componentsSeparatedByString(" ").first!
        return Int(strInt)!
    }
    
    static func extractBool(achievement: String) -> Bool {
        let strBool = achievement.componentsSeparatedByString(" ").last!
        if strBool == "t" {
            return true
        }
        return false
    }
    
    static let achievements = ["You completed your first event", "You completed 5 events", "You completed 10 events", "You completed 15 events", "You completed 20 events", "You completed 50 events", "You have logged 5 hours of volunteering", "You have logged 20 hours of volunteering", "You have logged 50 hours of volunteering", "You have logged 100 hours of volunteering", "You have logged 150 hours of volunteering", "You have logged 200 hours of volunteering" ]
}
