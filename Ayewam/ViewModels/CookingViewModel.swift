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
        
        let initialState = CookingActivityAttributes.ContentState(
            recipeName: session.recipe.name ?? "Recipe",
            currentStep: session.currentStepIndex + 1,
            totalSteps: session.totalSteps,
            timerEndTime: nil,
            timerStepName: nil
        )
        
        do {
            activity = try Activity.request(
                attributes: attributes,
                contentState: initialState,
                pushType: nil
            )
            isLiveActivityEnabled = true
            print("Live Activity started successfully")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func updateLiveActivity() {
        guard let activity = activity else { return }
        
        let state = CookingActivityAttributes.ContentState(
            recipeName: session.recipe.name ?? "Recipe",
            currentStep: session.currentStepIndex + 1,
            totalSteps: session.totalSteps,
            timerEndTime: getActiveTimerEndTime(),
            timerStepName: session.currentStep?.instruction
        )
        
        Task {
            await activity.update(using: state)
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
        
        Task {
            await activity.end(using: finalState, dismissalPolicy: .immediate)
            
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
    
    func startCooking() {
        session.start()
        enableScreenWakeLock()
        showFullScreenMode = true
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            startLiveActivity()
        }
    }
    
    func endCooking() {
        session.end()
        disableScreenWakeLock()
        showFullScreenMode = false
        cancelAllTimers()
        if isLiveActivityEnabled {
            endLiveActivity()
        }
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
    
    // MARK: - Timer Management
    
    func startTimer(for step: Step) {
        guard step.duration > 0 else { return }
        let stepIndex = Int(step.orderIndex)
        
        cancelTimer(for: stepIndex)
        
        let timerState = TimerState(
            duration: Int(step.duration),
            startTime: Date(),
            isRunning: true
        )
        
        activeTimers[stepIndex] = timerState
        
        let timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                self?.updateTimer(for: stepIndex, at: date)
            }
        
        timerCancellables[stepIndex] = timer
        
        if isLiveActivityEnabled {
            updateLiveActivity()
        }
    }
    
    private func updateTimer(for stepIndex: Int, at date: Date) {
        guard var timerState = activeTimers[stepIndex], timerState.isRunning else { return }
        
        let elapsedTime = Int(date.timeIntervalSince(timerState.startTime))
        let remainingTime = max(0, timerState.duration - elapsedTime)
        
        timerState.remainingTime = remainingTime
        activeTimers[stepIndex] = timerState
        
        if remainingTime <= 0 {
            timerCompleted(for: stepIndex)
        }
    }
    
    private func timerCompleted(for stepIndex: Int) {
        cancelTimer(for: stepIndex)
        playTimerCompletionFeedback()
        showTimerCompletionNotification(for: stepIndex)
        
        if isLiveActivityEnabled {
            updateLiveActivity()
        }
    }

    func cancelTimer(for stepIndex: Int) {
        activeTimers.removeValue(forKey: stepIndex)
        timerCancellables.removeValue(forKey: stepIndex)?.cancel()
    }
    
    func cancelAllTimers() {
        for (stepIndex, _) in timerCancellables {
            cancelTimer(for: stepIndex)
        }
        activeTimers.removeAll()
        timerCancellables.removeAll()
    }

    private func playTimerCompletionFeedback() {
        // Play sound
        AudioServicesPlaySystemSound(1007)
        
        // Vibration
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func showTimerCompletionNotification(for stepIndex: Int) {
        // Show local notification if app is in background
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        
        if let step = session.sortedSteps.first(where: { Int($0.orderIndex) == stepIndex }) {
            content.body = "Time's up for: \(step.instruction ?? "your cooking step")"
        } else {
            content.body = "Your cooking timer is complete!"
        }
        
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "timer-\(stepIndex)",
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    func getActiveTimersList() -> [(stepIndex: Int, state: TimerState)] {
        return activeTimers.map { (stepIndex: $0.key, state: $0.value) }
            .sorted { $0.stepIndex < $1.stepIndex }
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
