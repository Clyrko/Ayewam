//
//  EnhancedTimerComponents.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/31/25.
//

import SwiftUI

// MARK: - Main Enhanced Timer View
struct EnhancedTimerView: View {
    let duration: Int
    let timerState: TimerState?
    let onStart: () -> Void
    let onCancel: () -> Void
    
    @State private var pulseScale: CGFloat = 1.0
    @State private var warningPulse: Bool = false
    
    private var isRunning: Bool {
        timerState?.isRunning == true
    }
    
    private var progress: Double {
        guard let timerState = timerState, timerState.duration > 0 else { return 0 }
        return Double(timerState.duration - timerState.remainingTime) / Double(timerState.duration)
    }
    
    private var isWarning: Bool {
        guard let timerState = timerState else { return false }
        return timerState.remainingTime <= 60 && timerState.remainingTime > 0
    }
    
    private var isCompleted: Bool {
        guard let timerState = timerState else { return false }
        return timerState.remainingTime <= 0
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Main circular timer
            circularTimer
            
            // Timer controls
            timerControls
        }
        .onAppear {
            startAnimations()
        }
        .onChange(of: isWarning) { _, warning in
            if warning {
                startWarningAnimation()
            }
        }
        .onChange(of: isCompleted) { _, completed in
            if completed {
                triggerCompletionFeedback()
            }
        }
    }
    
    // MARK: - Circular Timer
    private var circularTimer: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [
                            Color("TimerActive").opacity(0.1),
                            Color("TimerActive").opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 12
                )
                .frame(width: 160, height: 160)
            
            // Progress ring
            if isRunning {
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        LinearGradient(
                            colors: progressColors,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(
                            lineWidth: 12,
                            lineCap: .round
                        )
                    )
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1.0), value: progress)
            }
            
            // Timer content
            timerContent
            
            // Warning pulse effect
            if isWarning && isRunning {
                Circle()
                    .stroke(Color.red.opacity(0.4), lineWidth: 3)
                    .frame(width: 180, height: 180)
                    .scaleEffect(warningPulse ? 1.1 : 1.0)
                    .opacity(warningPulse ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false), value: warningPulse)
            }
            
            // Completion celebration effect
            if isCompleted {
                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(Color.green.opacity(0.6))
                        .frame(width: 8, height: 8)
                        .offset(
                            x: cos(Double(index) * .pi / 3) * 100,
                            y: sin(Double(index) * .pi / 3) * 100
                        )
                        .scaleEffect(pulseScale)
                        .animation(
                            .easeOut(duration: 1.5)
                            .delay(Double(index) * 0.1),
                            value: pulseScale
                        )
                }
            }
        }
        .scaleEffect(isRunning ? pulseScale : 1.0)
    }
    
    private var timerContent: some View {
        VStack(spacing: 8) {
            if isCompleted {
                // Completion state
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(.green)
                        .scaleEffect(pulseScale)
                    
                    Text("Time's Up!")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.green)
                }
            } else if let timerState = timerState, isRunning {
                // Running state
                VStack(spacing: 4) {
                    Text(timerState.formattedTimeRemaining)
                        .font(.system(size: 28, weight: .bold, design: .monospaced))
                        .foregroundColor(isWarning ? .red : Color("TimerActive"))
                        .scaleEffect(isWarning ? (warningPulse ? 1.1 : 1.0) : 1.0)
                    
                    Text("remaining")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
            } else {
                // Ready to start state
                VStack(spacing: 4) {
                    Image(systemName: "timer")
                        .font(.system(size: 28))
                        .foregroundColor(Color("TimerActive"))
                    
                    Text(formatDuration(duration))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Ready to start")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
            }
        }
    }
    
    // MARK: - Timer Controls
    private var timerControls: some View {
        HStack(spacing: 16) {
            if isRunning {
                // Stop button
                Button(action: onCancel) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 16))
                        
                        Text("Stop Timer")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.red)
                            .shadow(color: Color.red.opacity(0.3), radius: 6, x: 0, y: 3)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                
            } else if isCompleted {
                // Reset button
                Button(action: onCancel) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                        
                        Text("Reset")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.gray)
                            .shadow(color: Color.gray.opacity(0.3), radius: 6, x: 0, y: 3)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                
            } else {
                // Start button
                Button(action: onStart) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16))
                        
                        Text("Start Timer")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("TimerActive"), Color("CookingProgress")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color("TimerActive").opacity(0.4), radius: 6, x: 0, y: 3)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
    
    // MARK: - Helper Properties
    private var progressColors: [Color] {
        if isCompleted {
            return [Color.green, Color("StepComplete")]
        } else if isWarning {
            return [Color.red, Color.orange]
        } else {
            return [Color("TimerActive"), Color("CookingProgress")]
        }
    }
    
    // MARK: - Animation Methods
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            pulseScale = 1.05
        }
    }
    
    private func startWarningAnimation() {
        withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: false)) {
            warningPulse = true
        }
    }
    
    private func triggerCompletionFeedback() {
        // Visual feedback
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
            pulseScale = 1.3
        }
        
        HapticFeedbackManager.shared.timerCompleted()
        
        // Reset pulse after celebration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 0.5)) {
                pulseScale = 1.0
            }
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        
        if minutes > 0 && remainingSeconds > 0 {
            return "\(minutes)m \(remainingSeconds)s"
        } else if minutes > 0 {
            return "\(minutes) min"
        } else {
            return "\(remainingSeconds)s"
        }
    }
}

// MARK: - Compact Timer Chip (for multiple timers)
struct CompactTimerChip: View {
    let stepNumber: Int
    let timerState: TimerState
    let onCancel: () -> Void
    
    @State private var pulseEffect = false
    
    private var isWarning: Bool {
        timerState.remainingTime <= 60 && timerState.remainingTime > 0
    }
    
    var body: some View {
        HStack(spacing: 10) {
            // Step indicator
            ZStack {
                Circle()
                    .fill(isWarning ? Color.red : Color("TimerActive"))
                    .frame(width: 28, height: 28)
                
                Text("\(stepNumber)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.white)
            }
            .scaleEffect(isWarning ? (pulseEffect ? 1.1 : 1.0) : 1.0)
            .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: pulseEffect)
            
            // Timer info
            VStack(alignment: .leading, spacing: 2) {
                Text("Step \(stepNumber)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(timerState.formattedTimeRemaining)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(isWarning ? .red : Color("TimerActive"))
            }
            
            Spacer()
            
            // Cancel button
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isWarning ? Color.red.opacity(0.3) : Color("TimerActive").opacity(0.2),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .onAppear {
            if isWarning {
                pulseEffect = true
            }
        }
        .onChange(of: isWarning) { _, warning in
            pulseEffect = warning
        }
    }
}

// MARK: - Multiple Timers Container
struct MultipleTimersView: View {
    let activeTimers: [(stepIndex: Int, state: TimerState)]
    let onCancelTimer: (Int) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "timer.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color("TimerActive"))
                
                Text("Active Timers")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(activeTimers.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color("TimerActive"))
                    )
            }
            
            if activeTimers.isEmpty {
                HStack {
                    Image(systemName: "timer.slash")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                    
                    Text("No active timers")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.vertical, 8)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(activeTimers, id: \.stepIndex) { timer in
                        CompactTimerChip(
                            stepNumber: timer.stepIndex + 1,
                            timerState: timer.state,
                            onCancel: {
                                onCancelTimer(timer.stepIndex)
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("TimerActive").opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview("Enhanced Timer") {
    ScrollView {
        VStack(spacing: 30) {
            // Timer ready to start
            EnhancedTimerView(
                duration: 300,
                timerState: nil,
                onStart: {},
                onCancel: {}
            )
            
            // Timer running
            EnhancedTimerView(
                duration: 300,
                timerState: TimerState(duration: 300, startTime: Date().addingTimeInterval(-60)),
                onStart: {},
                onCancel: {}
            )
            
            // Multiple timers
            MultipleTimersView(
                activeTimers: [
                    (stepIndex: 1, state: TimerState(duration: 180, startTime: Date().addingTimeInterval(-60))),
                    (stepIndex: 3, state: TimerState(duration: 300, startTime: Date().addingTimeInterval(-240)))
                ],
                onCancelTimer: { _ in }
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
