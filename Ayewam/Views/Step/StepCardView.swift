//
//  StepCardView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import SwiftUI

struct StepCardView: View {
    let step: Step
    let stepNumber: Int
    let totalSteps: Int
    let isActive: Bool
    let isCompleted: Bool
    let timerState: TimerState?
    let onTimerStart: () -> Void
    let onTimerCancel: () -> Void
    let onMarkComplete: () -> Void
    
    @State private var showTip: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with step number and completion status
            HStack {
                StepBadge(number: stepNumber, total: totalSteps)
                
                Spacer()
                
                if isCompleted {
                    Label("Completed", systemImage: "checkmark.circle.fill")
                        .font(.subheadline)
                        .foregroundColor(.green)
                } else if isActive {
                    Text("Current Step")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 12)
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.horizontal, 16)
            
            // Step content
            VStack(alignment: .leading, spacing: 16) {
                // Instruction text
                Text(step.instruction ?? "")
                    .font(.body)
                    .padding(.top, 16)
                
                // Step image if available
                if let imageName = step.imageName, !imageName.isEmpty {
                    AsyncImageView.asset(
                        imageName,
                        contentMode: .fill,
                        cornerRadius: 12
                    )
                    .frame(height: 180)
                }
                
                // Timer control
                if step.duration > 0 {
                    timerView
                }
                
                // Mark complete button (only for active non-completed step)
                if isActive && !isCompleted {
                    Button(action: onMarkComplete) {
                        HStack {
                            Image(systemName: "checkmark")
                            Text("Mark Step Complete")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .padding(.top, 8)
                }
                
                // Cooking tip (if applicable)
                if let tip = getCookingTip() {
                    DisclosureGroup(
                        isExpanded: $showTip,
                        content: {
                            Text(tip)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.vertical, 8)
                        },
                        label: {
                            Label("Cooking Tip", systemImage: "lightbulb.fill")
                                .font(.subheadline)
                                .foregroundColor(.orange)
                        }
                    )
                    .padding(.top, 12)
                }
            }
            .padding([.horizontal, .bottom], 16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isActive ? Color(.systemBackground) : Color(.secondarySystemBackground))
                .shadow(color: isActive ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    isActive ? Color.blue : isCompleted ? Color.green.opacity(0.5) : Color.clear,
                    lineWidth: 2
                )
        )
    }
    
    private var timerView: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
                
                Text("Timer: \(formatTime(seconds: step.duration))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
            }
            
            if let timerState = timerState {
                // Timer is running
                VStack(spacing: 8) {
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            // Progress
                            Rectangle()
                                .fill(Color.orange)
                                .frame(width: geometry.size.width * CGFloat(timerState.progress), height: 8)
                        }
                        .cornerRadius(4)
                    }
                    .frame(height: 8)
                    
                    // Time remaining text
                    HStack {
                        Text(timerState.formattedTimeRemaining)
                            .font(.system(size: 24, weight: .medium, design: .monospaced))
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        Button(action: onTimerCancel) {
                            Text("Cancel")
                                .font(.subheadline)
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red, lineWidth: 1)
                                )
                        }
                    }
                }
                .padding(.top, 4)
            } else {
                // Timer is not running
                Button(action: onTimerStart) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Timer")
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .cornerRadius(10)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func formatTime(seconds: Int32) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if remainingSeconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes) min \(remainingSeconds) sec"
        }
    }
    
    // This would normally pull from a database of cooking tips
    private func getCookingTip() -> String? {
        // Simple example based on step content
        if let instruction = step.instruction?.lowercased() {
            if instruction.contains("onion") {
                return "For Ghanaian dishes, onions are often sliced rather than diced to provide texture to the dish."
            } else if instruction.contains("tomato") {
                return "Ghanaian dishes often use very ripe tomatoes for the best flavor. If using canned, look for ones without added ingredients."
            } else if instruction.contains("palm oil") {
                return "Palm oil gives many Ghanaian dishes their distinctive red color and rich flavor. Use it sparingly as it's quite potent."
            } else if instruction.contains("stir") {
                return "Many Ghanaian dishes require frequent stirring to prevent sticking, especially those with starches like banku or fufu."
            } else if instruction.contains("spice") || instruction.contains("pepper") {
                return "Ghanaian cuisine tends to be spicy. Adjust the amount of pepper to your taste preference."
            } else if instruction.contains("ginger") || instruction.contains("garlic") {
                return "Fresh ginger and garlic are key to authentic Ghanaian flavor. Pre-minced versions won't provide the same depth of flavor."
            }
        }
        return nil
    }
}

// Supporting badge component
struct StepBadge: View {
    let number: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text("Step \(number)")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.vertical, 6)
                .padding(.horizontal, 12)
                .background(Color.blue)
                .cornerRadius(16)
            
            Text("of \(total)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
