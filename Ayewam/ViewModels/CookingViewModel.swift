//
//  CookingViewModel.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import Combine
import SwiftUI
import UserNotifications
import AVFoundation
import ActivityKit

class CookingViewModel: ObservableObject {
    @Published var session: CookingSession
    @Published var showFullScreenMode: Bool = false
    @Published var showStepCompletion: Bool = false
    @Published var showIngredients: Bool = false
    @Published var isLiveActivityEnabled: Bool = false
    private var activity: Activity<CookingActivityAttributes>?
    
    // Screen wake lock for cooking
    private var idleTimerDisabled = false
    
    // Keep track of active timers
    @Published var activeTimers: [Int: TimerState] = [:]
    
    private var cancellables = Set<AnyCancellable>()
    private var timerCancellables: [Int: AnyCancellable] = [:]
    
    init(recipe: Recipe) {
        self.session = CookingSession(recipe: recipe)
        
        // Listen for session completion
        session.$completedSteps
            .sink { [weak self] completed in
                guard let self = self else { return }
                if completed.count == self.session.totalSteps {
                    self.handleRecipeCompletion()
                }
            }
            .store(in: &cancellables)
        
        // Request notification permissions
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not enabled")
            return
        }
        
        let attributes = CookingActivityAttributes(
            recipeName: session.recipe.name ?? "Recipe",
            recipeImage: session.recipe.imageName
        )
        
        let initialContent = ActivityContent(
            state: CookingActivityAttributes.ContentState(
                recipeName: session.recipe.name ?? "Recipe",
                currentStep: session.currentStepIndex + 1,
                totalSteps: session.totalSteps,
                timerEndTime: nil,
                timerStepName: nil
            ),
            staleDate: nil
        )
        
        do {
            activity = try Activity.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil
            )
            isLiveActivityEnabled = true
            print("Live Activity started successfully")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func endLiveActivity() {
        guard let activity = activity else { return }
        
        let finalState = CookingActivityAttributes.ContentState(
            recipeName: session.recipe.name ?? "Recipe",
            currentStep: session.totalSteps,
            totalSteps: session.totalSteps,
            timerEndTime: nil,
            timerStepName: nil
        )
        
        let finalContent = ActivityContent(
            state: finalState,
            staleDate: nil
        )
        
        Task {
            await activity.end(finalContent, dismissalPolicy: .immediate)
            
            // Update UI properties on the main thread
            await MainActor.run {
                isLiveActivityEnabled = false
            }
        }
    }
    
    private func getActiveTimerEndTime() -> Date? {
        guard let currentStep = session.currentStep,
              let timerState = activeTimers[Int(currentStep.orderIndex)],
              timerState.isRunning else {
            return nil
        }
        
        return Date().addingTimeInterval(TimeInterval(timerState.remainingTime))
    }
    
    func nextStep() {
        let result = session.moveToNextStep()
        if !result {
            showStepCompletion = true
        }
        
        objectWillChange.send()
        
        if isLiveActivityEnabled {
            updateLiveActivity()
        }
    }
    
    func previousStep() {
        _ = session.moveToPreviousStep()
        
        objectWillChange.send()
        
        if isLiveActivityEnabled {
            updateLiveActivity()
        }
    }
    
    func toggleIngredients() {
        showIngredients.toggle()
    }
    
    private func handleRecipeCompletion() {
        withAnimation {
            showStepCompletion = true
        }
    }
    
    // MARK: - Enhanced Timer Management with Notifications
    
    /// Start timer with native iOS notifications and enhanced feedback
    func startTimer(for step: Step) {
        guard step.duration > 0 else { return }
        let stepIndex = Int(step.orderIndex)
        
        // Cancel any existing timer for this step
        cancelTimerWithNotifications(for: stepIndex)
        
        // Create timer state
        let timerState = TimerState(
            duration: Int(step.duration),
            startTime: Date(),
            isRunning: true
        )
        
        activeTimers[stepIndex] = timerState
        
        // Start visual timer (existing functionality)
        let timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.updateTimer(for: stepIndex, at: date)
            }
        
        timerCancellables[stepIndex] = timer
        
        // Schedule native notifications
        Task {
            await TimerNotificationService.shared.scheduleAdvancedTimerNotification(
                stepNumber: stepIndex + 1,
                stepInstruction: step.instruction ?? "Cooking step",
                totalDuration: TimeInterval(step.duration),
                recipeID: session.recipe.id ?? "recipe_\(Date().timeIntervalSince1970)"
            )
        }
        
        // Update Live Activity
        if isLiveActivityEnabled {
            updateLiveActivity()
        }
        
        // Play start sound
        TimerNotificationService.shared.playTimerWarningSound()
        
        print("🔔 Enhanced timer started for step \(stepIndex + 1) (\(step.duration)s)")
    }
    
    /// Cancel timer with notification cleanup
    func cancelTimer(for stepIndex: Int) {
        cancelTimerWithNotifications(for: stepIndex)
    }
    
    /// Enhanced timer cancellation with notification cleanup
    func cancelTimerWithNotifications(for stepIndex: Int) {
        // Remove visual timer
        activeTimers.removeValue(forKey: stepIndex)
        timerCancellables.removeValue(forKey: stepIndex)?.cancel()
        
        // Cancel notifications
        let recipeID = session.recipe.id ?? "recipe_\(Date().timeIntervalSince1970)"
        let timerID = TimerNotificationService.timerID(stepIndex: stepIndex, recipeID: recipeID)
        TimerNotificationService.shared.cancelTimerNotification(timerID: timerID)
        
        // Cancel warning notifications too
        TimerNotificationService.shared.cancelTimerNotification(timerID: "\(timerID)_warning_60")
        TimerNotificationService.shared.cancelTimerNotification(timerID: "\(timerID)_warning_30")
        
        print("🗑️ Enhanced timer cancelled for step \(stepIndex + 1)")
    }
    
    /// Cancel all timers with notification cleanup
    func cancelAllTimers() {
        // Cancel all visual timers
        for (stepIndex, _) in timerCancellables {
            cancelTimerWithNotifications(for: stepIndex)
        }
        
        // Cleanup any remaining notifications
        TimerNotificationService.shared.cancelAllTimerNotifications()
        
        activeTimers.removeAll()
        timerCancellables.removeAll()
        
        print("🗑️ All enhanced timers cancelled")
    }
    
    /// Enhanced timer update with warning notifications
    private func updateTimer(for stepIndex: Int, at date: Date) {
        guard var timerState = activeTimers[stepIndex], timerState.isRunning else { return }
        
        let elapsedTime = Int(date.timeIntervalSince(timerState.startTime))
        let remainingTime = max(0, timerState.duration - elapsedTime)
        
        timerState.remainingTime = remainingTime
        activeTimers[stepIndex] = timerState
        
        // Check for warning thresholds (play sound in-app for immediate feedback)
        if remainingTime == 60 || remainingTime == 30 {
            TimerNotificationService.shared.playTimerWarningSound()
            print("⚠️ Timer warning: \(remainingTime)s remaining for step \(stepIndex + 1)")
        }
        
        if remainingTime <= 0 {
            timerCompleted(for: stepIndex)
        }
    }
    
    /// Enhanced timer completion with rich feedback
    private func timerCompleted(for stepIndex: Int) {
        // Cancel the timer
        cancelTimerWithNotifications(for: stepIndex)
        
        // Enhanced completion feedback
        TimerNotificationService.shared.playTimerCompletionSound()
        
        // Show in-app completion notification if app is active
        showTimerCompletionNotification(for: stepIndex)
        
        // Update Live Activity
        if isLiveActivityEnabled {
            updateLiveActivity()
        }
        
        print("✅ justynx Timer completed for step \(stepIndex + 1) with feedback")
    }
    
    /// Show in-app timer completion notification
    private func showTimerCompletionNotification(for stepIndex: Int) {
        // Find the step
        guard let step = session.sortedSteps.first(where: { Int($0.orderIndex) == stepIndex }) else {
            return
        }
        
        // Create local notification content for in-app display
        let content = UNMutableNotificationContent()
        content.title = "⏰ Timer Complete!"
        content.body = "Step \(stepIndex + 1): \(step.instruction ?? "Cooking step")"
        content.sound = .default
        
        // Show immediately (for in-app notification)
        let request = UNNotificationRequest(
            identifier: "timer_complete_\(stepIndex)_\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Failed to show in-app timer notification: \(error)")
            }
        }
    }
    
    /// Update Live Activity with current timer information
    func updateLiveActivity() {
        guard let activity = activity else { return }
        
        // Get the most urgent timer (least time remaining)
        let activeTimersList = getActiveTimersList()
        let urgentTimer = activeTimersList.min(by: { $0.state.remainingTime < $1.state.remainingTime })
        
        let timerEndTime = urgentTimer.map { timer in
            Date().addingTimeInterval(TimeInterval(timer.state.remainingTime))
        }
        
        let updatedState = CookingActivityAttributes.ContentState(
            recipeName: session.recipe.name ?? "Recipe",
            currentStep: session.currentStepIndex + 1,
            totalSteps: session.totalSteps,
            timerEndTime: timerEndTime,
            timerStepName: urgentTimer != nil ? "Step \(urgentTimer!.stepIndex + 1)" : nil
        )
        
        let updatedContent = ActivityContent(
            state: updatedState,
            staleDate: nil
        )
        
        Task {
            await activity.update(updatedContent)
            print("🔴 Live Activity updated with timer info")
        }
    }
    
    func getActiveTimersList() -> [(stepIndex: Int, state: TimerState)] {
        return activeTimers.map { (stepIndex: $0.key, state: $0.value) }
            .sorted { $0.stepIndex < $1.stepIndex }
    }
    
    // MARK: - Enhanced Session Management
    
    /// Enhanced cooking session start
    func startCooking() {
        session.start()
        enableScreenWakeLock()
        showFullScreenMode = true
        
        // Setup notification categories
        TimerNotificationService.shared.setupNotificationCategories()
        
        // Start Live Activity if enabled
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            startLiveActivity()
        }
        
        print("🔥 Enhanced cooking session started")
    }
    
    /// Enhanced cooking session end
    func endCooking() {
        session.end()
        disableScreenWakeLock()
        showFullScreenMode = false
        
        // Cancel all timers and notifications
        cancelAllTimers()
        
        // End Live Activity
        if isLiveActivityEnabled {
            endLiveActivity()
        }
        
        // Track cooking session end
        trackCookingSessionEnd()
        
        print("🏁 Enhanced cooking session ended")
    }
    
    // MARK: - Screen Wake Lock
    
    private func enableScreenWakeLock() {
        UIApplication.shared.isIdleTimerDisabled = true
        idleTimerDisabled = true
    }
    
    private func disableScreenWakeLock() {
        UIApplication.shared.isIdleTimerDisabled = false
        idleTimerDisabled = false
    }
}
