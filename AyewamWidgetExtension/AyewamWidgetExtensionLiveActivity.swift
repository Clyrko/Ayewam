//
//  AyewamWidgetExtensionLiveActivity.swift
//  AyewamWidgetExtension
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import ActivityKit
import WidgetKit
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

struct AyewamWidgetExtensionLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CookingActivityAttributes.self) { context in
            // Lock screen/banner UI
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Recipe name
                    Text(context.state.recipeName)
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // Step progress
                    Text("Step \(context.state.currentStep) of \(context.state.totalSteps)")
                        .font(.subheadline)
                }
                
                // Progress bar
                ProgressView(value: Float(context.state.currentStep), total: Float(context.state.totalSteps))
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(.green)
                
                // Timer info (if active)
                if let timerEndTime = context.state.timerEndTime, let stepName = context.state.timerStepName {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.orange)
                        
                        Text(stepName)
                            .font(.caption)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text(timerEndTime, style: .timer)
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 4)
                }
            }
            .padding()
            .activityBackgroundTint(Color.gray.opacity(0.2))
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "fork.knife")
                            .foregroundColor(.green)
                        
                        Text(context.state.recipeName)
                            .font(.headline)
                            .lineLimit(1)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Step \(context.state.currentStep) of \(context.state.totalSteps)")
                        .font(.caption)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    if let timerEndTime = context.state.timerEndTime {
                        HStack {
                            Image(systemName: "timer")
                                .foregroundColor(.orange)
                            
                            Text(timerEndTime, style: .timer)
                                .font(.system(.body, design: .monospaced))
                                .foregroundColor(.orange)
                        }
                    } else {
                        // Progress indicator
                        VStack {
                            ProgressView(value: Float(context.state.currentStep), total: Float(context.state.totalSteps))
                                .progressViewStyle(LinearProgressViewStyle())
                                .tint(.green)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    if let stepName = context.state.timerStepName {
                        Text(stepName)
                            .font(.caption)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                    } else {
                        Text("Cooking in progress")
                            .font(.caption)
                    }
                }
            } compactLeading: {
                Image(systemName: "fork.knife")
                    .foregroundColor(.green)
            } compactTrailing: {
                if let timerEndTime = context.state.timerEndTime {
                    Text(timerEndTime, style: .timer)
                        .font(.system(.footnote, design: .monospaced))
                        .foregroundColor(.orange)
                        .frame(width: 50)
                } else {
                    Text("\(context.state.currentStep)/\(context.state.totalSteps)")
                        .font(.footnote)
                }
            } minimal: {
                if context.state.timerEndTime != nil {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                } else {
                    Image(systemName: "fork.knife")
                        .foregroundColor(.green)
                }
            }
            .widgetURL(URL(string: "ayewam://recipe"))
            .keylineTint(Color.green)
        }
    }
}

// Preview data for the Live Activity
extension CookingActivityAttributes {
    static var preview: CookingActivityAttributes {
        CookingActivityAttributes(
            recipeName: "Jollof Rice",
            recipeImage: "jollof_rice"
        )
    }
}

extension CookingActivityAttributes.ContentState {
    static var initial: CookingActivityAttributes.ContentState {
        CookingActivityAttributes.ContentState(
            recipeName: "Jollof Rice",
            currentStep: 1,
            totalSteps: 7,
            timerEndTime: nil,
            timerStepName: nil
        )
    }
    
    static var cooking: CookingActivityAttributes.ContentState {
        CookingActivityAttributes.ContentState(
            recipeName: "Jollof Rice",
            currentStep: 3,
            totalSteps: 7,
            timerEndTime: Date().addingTimeInterval(420),
            timerStepName: "Add tomato paste and stir for 2-3 minutes until it darkens slightly."
        )
    }
}

#Preview("Notification", as: .content, using: CookingActivityAttributes.preview) {
   AyewamWidgetExtensionLiveActivity()
} contentStates: {
    CookingActivityAttributes.ContentState.initial
    CookingActivityAttributes.ContentState.cooking
}

#Preview("Dynamic Island (compact)", as: .dynamicIsland(.compact), using: CookingActivityAttributes.preview) {
    AyewamWidgetExtensionLiveActivity()
} contentStates: {
    CookingActivityAttributes.ContentState.cooking
}

#Preview("Dynamic Island (expanded)", as: .dynamicIsland(.expanded), using: CookingActivityAttributes.preview) {
    AyewamWidgetExtensionLiveActivity()
} contentStates: {
    CookingActivityAttributes.ContentState.cooking
}

#Preview("Dynamic Island (minimal)", as: .dynamicIsland(.minimal), using: CookingActivityAttributes.preview) {
    AyewamWidgetExtensionLiveActivity()
} contentStates: {
    CookingActivityAttributes.ContentState.cooking
}
