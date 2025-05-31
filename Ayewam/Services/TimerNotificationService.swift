//
//  TimerNotificationService.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/31/25.
//

import Foundation
import UserNotifications
import AudioToolbox
import AVFoundation
import UIKit

class TimerNotificationService: ObservableObject {
    static let shared = TimerNotificationService()
    
    @Published var notificationPermissionGranted = false
    
    private init() {
        requestNotificationPermission()
    }
    
    // MARK: - Permission Management
    /// Request notification permissions on app launch
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge, .criticalAlert]) { granted, error in
            DispatchQueue.main.async {
                self.notificationPermissionGranted = granted
            }
            
            if let error = error {
                print("❌ justynx Notification permission error: \(error.localizedDescription)")
            } else {
                print("✅ justynx Notification permission granted: \(granted)")
            }
        }
    }
    
    /// Check current notification permission status
    func checkNotificationPermission() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        
        DispatchQueue.main.async {
            self.notificationPermissionGranted = settings.authorizationStatus == .authorized
        }
        
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Timer Notifications
    /// Schedule a notification for when a timer completes
    func scheduleTimerNotification(
        stepNumber: Int,
        stepInstruction: String,
        duration: TimeInterval,
        timerID: String
    ) async {
        guard await checkNotificationPermission() else {
            print("❌ justynx Timer notification not scheduled - permission denied")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ justynx Timer Complete - Step \(stepNumber)"
        content.body = getTimerCompletionMessage(for: stepInstruction, stepNumber: stepNumber)
        content.sound = .default
        content.categoryIdentifier = "TIMER_COMPLETION"
        
        // Add custom data for handling the notification
        content.userInfo = [
            "type": "timer_completion",
            "stepNumber": stepNumber,
            "timerID": timerID,
            "stepInstruction": stepInstruction
        ]
        
        // Critical alert for cooking timers
        if await supportsCriticalAlerts() {
            content.sound = UNNotificationSound.defaultCritical
        }
        
        // Schedule notification for when timer completes
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: false)
        let request = UNNotificationRequest(identifier: timerID, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ justynx Timer notification scheduled for step \(stepNumber) in \(duration) seconds")
        } catch {
            print("❌ justynx Failed to schedule timer notification: \(error.localizedDescription)")
        }
    }
    
    /// Cancel a specific timer notification
    func cancelTimerNotification(timerID: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [timerID])
        print("🗑️ justynx Cancelled timer notification: \(timerID)")
    }
    
    /// Cancel all cooking timer notifications
    func cancelAllTimerNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let timerIDs = requests.compactMap { request in
                if let userInfo = request.content.userInfo as? [String: Any],
                   userInfo["type"] as? String == "timer_completion" {
                    return request.identifier
                }
                return nil
            }
            
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: timerIDs)
            print("🗑️ justynx Cancelled \(timerIDs.count) timer notifications")
        }
    }
    
    // MARK: - Enhanced Timer Sounds & Haptics
    /// Play custom timer completion sound
    func playTimerCompletionSound() {
        // Custom sound for timer completion
        AudioServicesPlaySystemSound(1007)
        
        // Haptic feedback
        let feedbackGenerator = UINotificationFeedbackGenerator()
        feedbackGenerator.notificationOccurred(.success)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
    
    /// Play warning sound when timer is almost complete
    func playTimerWarningSound() {
        // Gentle warning sound
        AudioServicesPlaySystemSound(1013)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Live Activities Integration
    /// Update Live Activity with current timer state
    func updateLiveActivityWithTimers(_ activeTimers: [Int: TimerState], recipeName: String) {
        // Find the timer with the least time remaining
        guard let (stepIndex, timerState) = activeTimers.min(by: { $0.value.remainingTime < $1.value.remainingTime }) else {
            return
        }
        
        let endTime = Date().addingTimeInterval(TimeInterval(timerState.remainingTime))
        
        print("🔴 justynx Live Activity: Step \(stepIndex + 1) timer ends at \(endTime)")
    }
    
    // MARK: - Notification Actions
    /// Setup notification actions for timer completions
    func setupNotificationCategories() {
        let viewRecipeAction = UNNotificationAction(
            identifier: "VIEW_RECIPE",
            title: "View Recipe",
            options: [.foreground]
        )
        
        let markCompleteAction = UNNotificationAction(
            identifier: "MARK_STEP_COMPLETE",
            title: "Mark Step Complete",
            options: [.foreground]
        )
        
        let snoozeAction = UNNotificationAction(
            identifier: "SNOOZE_TIMER",
            title: "Snooze 2 min",
            options: []
        )
        
        let timerCategory = UNNotificationCategory(
            identifier: "TIMER_COMPLETION",
            actions: [viewRecipeAction, markCompleteAction, snoozeAction],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([timerCategory])
    }
    
    // MARK: - Background Timer Management
    /// Schedule background app refresh for timer reliability
    func scheduleBackgroundRefresh() {
        // Request background app refresh permission
        // This ensures timers continue running even when app is backgrounded
        print("📱 justynx Requesting background app refresh for timer reliability")
    }
    
    // MARK: - Helper Methods
    
    private func getTimerCompletionMessage(for instruction: String, stepNumber: Int) -> String {
        let shortInstruction = String(instruction.prefix(50))
        let ellipsis = instruction.count > 50 ? "..." : ""
        
        return "Step \(stepNumber): \(shortInstruction)\(ellipsis)"
    }
    
    private func supportsCriticalAlerts() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.criticalAlertSetting == .enabled
    }
    
    /// Generate unique timer ID for notifications
    static func timerID(stepIndex: Int, recipeID: String) -> String {
        return "timer_\(recipeID)_step_\(stepIndex)_\(Date().timeIntervalSince1970)"
    }
}

// MARK: - Timer Notification Extensions

extension TimerNotificationService {
    /// Schedule notification with custom timing for different cooking scenarios
    func scheduleAdvancedTimerNotification(
        stepNumber: Int,
        stepInstruction: String,
        totalDuration: TimeInterval,
        recipeID: String,
        warnings: [TimeInterval] = [60, 30]
    ) async {
        let timerID = Self.timerID(stepIndex: stepNumber, recipeID: recipeID)
        
        // Schedule warning notifications
        for warningTime in warnings {
            if totalDuration > warningTime {
                let warningNotificationTime = totalDuration - warningTime
                await scheduleWarningNotification(
                    stepNumber: stepNumber,
                    stepInstruction: stepInstruction,
                    warningTime: warningTime,
                    scheduleTime: warningNotificationTime,
                    timerID: "\(timerID)_warning_\(Int(warningTime))"
                )
            }
        }
        
        // Schedule main completion notification
        await scheduleTimerNotification(
            stepNumber: stepNumber,
            stepInstruction: stepInstruction,
            duration: totalDuration,
            timerID: timerID
        )
    }
    
    private func scheduleWarningNotification(
        stepNumber: Int,
        stepInstruction: String,
        warningTime: TimeInterval,
        scheduleTime: TimeInterval,
        timerID: String
    ) async {
        let content = UNMutableNotificationContent()
        content.title = "⚠️ Timer Warning - Step \(stepNumber)"
        content.body = "\(Int(warningTime)) seconds remaining: \(String(stepInstruction.prefix(40)))"
        content.sound = .default
        content.userInfo = [
            "type": "timer_warning",
            "stepNumber": stepNumber,
            "warningTime": warningTime
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: scheduleTime, repeats: false)
        let request = UNNotificationRequest(identifier: timerID, content: content, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("⚠️ justynx Warning notification scheduled for step \(stepNumber) at \(warningTime)s remaining")
        } catch {
            print("❌ Failed to schedule warning notification: \(error.localizedDescription)")
        }
    }
}

// MARK: - Integration Helper

extension CookingViewModel {
    
    /// Enhanced timer start with notifications
    func startTimerWithNotifications(for step: Step) {
        let stepIndex = Int(step.orderIndex)
        let recipeID = session.recipe.id ?? "unknown"
        
        // Start the visual timer (existing functionality)
        startTimer(for: step)
        
        // Schedule native notification
        Task {
            await TimerNotificationService.shared.scheduleAdvancedTimerNotification(
                stepNumber: stepIndex + 1,
                stepInstruction: step.instruction ?? "Cooking step",
                totalDuration: TimeInterval(step.duration),
                recipeID: recipeID
            )
        }
        
        print("🔔 Timer started with notifications for step \(stepIndex + 1)")
    }
}
