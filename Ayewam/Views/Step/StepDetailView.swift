//
//  StepDetailView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import SwiftUI

struct StepDetailView: View {
    let step: Step
    let isActive: Bool
    let isCompleted: Bool
    let timerState: TimerState?
    let onTimerStart: () -> Void
    let onTimerCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Step header
            HStack {
                Text("Step \(step.orderIndex + 1)")
                    .font(.headline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                        .font(.title3)
                }
            }
            
            // Step instruction
            Text(step.instruction ?? "")
                .font(.body)
                .padding(.vertical, 4)
            
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
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isActive ? Color(.systemBackground) : Color(.secondarySystemBackground))
                .shadow(color: isActive ? Color.black.opacity(0.1) : Color.clear, radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isActive ? Color.blue : Color.clear, lineWidth: 2)
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
                            .font(.system(size: 20, weight: .medium, design: .monospaced))
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
}

#Preview {
    // Create a mock step for preview
    let context = PersistenceController.preview.container.viewContext
    let step = Step(context: context)
    step.instruction = "Chop the onions into small pieces and set aside."
    step.orderIndex = 0
    step.duration = 180 // 3 minutes
    
    return StepDetailView(
        step: step,
        isActive: true,
        isCompleted: false,
        timerState: nil,
        onTimerStart: {},
        onTimerCancel: {}
    )
    .previewLayout(.sizeThatFits)
    .padding()
}
