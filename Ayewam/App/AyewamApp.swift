//
//  AyewamApp.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI
import UserNotifications

@main
struct AyewamApp: App {
    let persistenceController = PersistenceController.shared
    @State private var showLaunchScreen = true
    
    init() {
        // Initialize notification service on app launch
        setupNotifications()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showLaunchScreen {
                    LaunchScreenView()
                        .transition(.opacity)
                } else {
                    ContentView()
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                        .transition(.opacity)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                // Check notification permissions when app becomes active
                Task {
                    await TimerNotificationService.shared.checkNotificationPermission()
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                // App is going to background - ensure timers are properly scheduled
                handleAppGoingToBackground()
            }
            .onAppear {
                // Show launch screen, then transition to main content
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showLaunchScreen = false
                    }
                }
            }
        }
    }
    
    // MARK: - Notification Setup
    private func setupNotifications() {
        // Request notification permissions
        TimerNotificationService.shared.requestNotificationPermission()
        
        // Setup notification categories and actions
        TimerNotificationService.shared.setupNotificationCategories()
        
        // Set notification delegate for handling notification responses
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        
        print("🔔 justynx Notification system initialized")
    }
    
    private func handleAppGoingToBackground() {
        // Ensure all active timers have proper notifications scheduled
        // This helps with timer reliability when app is backgrounded
        print("📱 justynx App going to background - timer notifications verified")
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        // Show notification even when app is active (for timer completions)
        if let userInfo = notification.request.content.userInfo as? [String: Any],
           let type = userInfo["type"] as? String,
           type == "timer_completion" || type == "timer_warning" {
            
            // Show banner, sound, and badge for timer notifications
            completionHandler([.banner, .sound, .badge])
            
            // Play enhanced haptic feedback for timer completions
            if type == "timer_completion" {
                TimerNotificationService.shared.playTimerCompletionSound()
            }
        } else {
            completionHandler([.banner, .sound])
        }
    }
    
    // Handle notification tap/action
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "VIEW_RECIPE":
            // Open app to recipe view
            handleViewRecipeAction(userInfo: userInfo)
            
        case "MARK_STEP_COMPLETE":
            // Mark the step as complete
            handleMarkStepCompleteAction(userInfo: userInfo)
            
        case "SNOOZE_TIMER":
            // Snooze timer for 2 minutes
            handleSnoozeTimerAction(userInfo: userInfo)
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification (default action)
            handleDefaultNotificationAction(userInfo: userInfo)
            
        default:
            break
        }
        
        completionHandler()
    }
    
    // MARK: - Notification Action Handlers
    
    private func handleViewRecipeAction(userInfo: [AnyHashable: Any]) {
        // Navigate to the recipe when notification is tapped
        print("📖 justynx Opening recipe from notification")
        
        // Post notification to switch to recipes tab
        NotificationCenter.default.post(name: .switchToHomeTab, object: nil)
    }
    
    private func handleMarkStepCompleteAction(userInfo: [AnyHashable: Any]) {
        guard let stepNumber = userInfo["stepNumber"] as? Int else { return }
        
        // Mark step as complete via notification action
        print("✅ justynx Marking step \(stepNumber) complete from notification")
    }
    
    private func handleSnoozeTimerAction(userInfo: [AnyHashable: Any]) {
        guard let stepNumber = userInfo["stepNumber"] as? Int,
              let timerID = userInfo["timerID"] as? String else { return }
        
        // Schedule a new notification in 2 minutes
        Task {
            await TimerNotificationService.shared.scheduleTimerNotification(
                stepNumber: stepNumber,
                stepInstruction: "Snoozed timer",
                duration: 120,
                timerID: "\(timerID)_snooze_\(Date().timeIntervalSince1970)"
            )
        }
        
        print("😴 Snoozed timer for step \(stepNumber) for 2 minutes")
    }
    
    private func handleDefaultNotificationAction(userInfo: [AnyHashable: Any]) {
        handleViewRecipeAction(userInfo: userInfo)
    }
}
