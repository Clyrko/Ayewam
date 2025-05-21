//
//  CookingActivityAttributes.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import ActivityKit
import SwiftUI

struct CookingActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var recipeName: String
        var currentStep: Int
        var totalSteps: Int
        var timerEndTime: Date?
        var timerStepName: String?
    }
    
    var recipeName: String
    var recipeImage: String?
}
