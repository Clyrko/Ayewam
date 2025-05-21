//
//  TimerManager.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import Foundation
import Combine
import UserNotifications
import AVFoundation
import UIKit

class TimerManager: ObservableObject {
    // Dictionary to track active timers
    @Published var activeTimers: [String: TimerData] = [:]
    
    // Audio player for timer sounds
    private var audioPlayer: AVAudioPlayer?
    
    // Notification center reference
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // Combine cancellables
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Request notification permissions
        requestNotificationPermissions()
        
        // Setup background notification handling
        setupBackgroundNotificationHandling()
        
        // Load any persisted timers
        loadPersistedTimers()
    }
    
    // MARK: - Timer Management
    
    func startTimer(id: String, duration: Int, name: String, recipeId: String? = nil) {
        // Cancel existing timer with this ID if it exists
        cancelTimer(id: id)
        
        // Calculate end time
        let endTime = Date().addingTimeInterval(TimeInterval(duration))
        
        // Create new timer data
        let timer = TimerData(
            id: id,
            name: name,
            duration: duration,
            endTime: endTime,
            recipeId: recipeId
        )
        
        // Save to active timers
        activeTimers[id] = timer
        
        // Schedule timer updates
        let timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer(id: id)
            }
        
        timer.cancellable = timerPublisher
        
        // Schedule local notification
        scheduleTimerNotification(for: timer)
        
        // Persist timers
        persistTimers()
    }
    
    func cancelTimer(id: String) {
        // Cancel the publisher if it exists
        activeTimers[id]?.cancellable?.cancel()
        
        // Remove timer from active timers
        activeTimers.removeValue(forKey: id)
        
        // Remove pending notification
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [id])
        
        // Persist timers
        persistTimers()
    }
    
    func cancelAllTimers() {
        // Get all timer IDs
        let timerIds = activeTimers.keys.map { $0 }
        
        // Cancel each timer
        timerIds.forEach { cancelTimer(id: $0) }
    }
    
    func pauseAllTimers() {
        activeTimers.forEach { id, timer in
            pauseTimer(id: id)
        }
    }
    
    func resumeAllTimers() {
        activeTimers.forEach { id, timer in
            resumeTimer(id: id)
        }
    }
    
    func pauseTimer(id: String) {
        guard var timer = activeTimers[id], !timer.isPaused else { return }
        
        // Cancel the publisher
        timer.cancellable?.cancel()
        
        // Calculate and store the remaining time
        let remainingTime = max(0, Int(timer.endTime.timeIntervalSinceNow))
        timer.remainingTime = remainingTime
        timer.isPaused = true
        
        // Update timer
        activeTimers[id] = timer
        
        // Persist timers
        persistTimers()
    }
    
    func resumeTimer(id: String) {
        guard var timer = activeTimers[id], timer.isPaused else { return }
        
        // Calculate new end time
        let newEndTime = Date().addingTimeInterval(TimeInterval(timer.remainingTime))
        timer.endTime = newEndTime
        timer.isPaused = false
        
        // Create new publisher
        let timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTimer(id: id)
            }
        
        timer.cancellable = timerPublisher
        
        // Update timer
        activeTimers[id] = timer
        
        // Update notification
        scheduleTimerNotification(for: timer)
        
        // Persist timers
        persistTimers()
    }
    
    private func updateTimer(id: String) {
        guard var timer = activeTimers[id], !timer.isPaused else { return }
        
        // Calculate remaining time
        let remainingTime = max(0, Int(timer.endTime.timeIntervalSinceNow))
        timer.remainingTime = remainingTime
        
        // Update timer
        activeTimers[id] = timer
        
        // Check if timer completed
        if remainingTime <= 0 {
            timerCompleted(id: id)
        }
    }
    
    private func timerCompleted(id: String) {
        // Play sound
        playTimerCompletionSound()
        
        // Cancel timer
        activeTimers[id]?.cancellable?.cancel()
        
        // Mark as completed but keep in active timers for a while
        var timer = activeTimers[id]!
        timer.isCompleted = true
        activeTimers[id] = timer
        
        // Remove from active timers after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) { [weak self] in
            self?.activeTimers.removeValue(forKey: id)
            self?.persistTimers()
        }
    }
    
    // MARK: - Notification Handling
    
    private func requestNotificationPermissions() {
        notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleTimerNotification(for timer: TimerData) {
        // Remove any existing notification for this timer
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [timer.id])
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = "Timer Complete"
        content.body = "Time's up for: \(timer.name)"
        content.sound = .default
        
        // Calculate trigger time
        let triggerTime = timer.remainingTime
        
        // Only schedule if the timer has more than 1 second remaining
        if triggerTime > 1 {
            // Create trigger and request
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(triggerTime), repeats: false)
            let request = UNNotificationRequest(identifier: timer.id, content: content, trigger: trigger)
            
            // Schedule notification
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling notification: \(error)")
                }
            }
        }
    }
    
    private func setupBackgroundNotificationHandling() {
        // Observer for app entering background
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.persistTimers()
            }
            .store(in: &cancellables)
        
        // Observer for app entering foreground
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.loadPersistedTimers()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sound Effects
    
    private func playTimerCompletionSound() {
        guard let soundURL = Bundle.main.url(forResource: "timer_complete", withExtension: "wav") else {
            // Try system sound if custom sound not available
            AudioServicesPlaySystemSound(1007) // System sound for timer
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error)")
            // Fallback to system sound
            AudioServicesPlaySystemSound(1007)
        }
    }
    
    // MARK: - Persistence
    
    private func persistTimers() {
        // Convert timers to a serializable format
        let timerDataDicts = activeTimers.compactMapValues { timer -> [String: Any]? in
            guard !timer.isCompleted else { return nil }
            
            return [
                "id": timer.id,
                "name": timer.name,
                "duration": timer.duration,
                "endTime": timer.endTime.timeIntervalSince1970,
                "remainingTime": timer.remainingTime,
                "isPaused": timer.isPaused,
                "recipeId": timer.recipeId ?? ""
            ]
        }
        
        // Save to UserDefaults
        UserDefaults.standard.set(timerDataDicts, forKey: "AyewamActiveTimers")
    }
    
    private func loadPersistedTimers() {
        // Clear existing timers
        cancelAllTimers()
        
        // Get saved timer data
        guard let timerDicts = UserDefaults.standard.dictionary(forKey: "AyewamActiveTimers") as? [String: [String: Any]] else {
            return
        }
        
        // Create timers from saved data
        for (id, dict) in timerDicts {
            guard let name = dict["name"] as? String,
                  let duration = dict["duration"] as? Int,
                  let endTimeInterval = dict["endTime"] as? TimeInterval,
                  let remainingTime = dict["remainingTime"] as? Int,
                  let isPaused = dict["isPaused"] as? Bool else {
                continue
            }
            
            let recipeId = dict["recipeId"] as? String
            
            // Convert end time
            let endTime = Date(timeIntervalSince1970: endTimeInterval)
            
            // Create timer
            var timer = TimerData(
                id: id,
                name: name,
                duration: duration,
                endTime: endTime,
                recipeId: recipeId
            )
            
            // Set remaining time and paused state
            timer.remainingTime = remainingTime
            timer.isPaused = isPaused
            
            // If the timer is not paused, create a publisher for it
            if !isPaused {
                // Check if the timer has already completed
                if remainingTime <= 0 {
                    timer.isCompleted = true
                    timer.remainingTime = 0
                } else {
                    // Create new publisher
                    let timerPublisher = Timer.publish(every: 0.1, on: .main, in: .common)
                        .autoconnect()
                        .sink { [weak self] _ in
                            self?.updateTimer(id: id)
                        }
                    
                    timer.cancellable = timerPublisher
                    
                    // Schedule notification
                    scheduleTimerNotification(for: timer)
                }
            }
            
            // Add to active timers
            activeTimers[id] = timer
        }
    }
}

// Timer data model
class TimerData: ObservableObject, Identifiable {
    let id: String
    let name: String
    let duration: Int
    var endTime: Date
    var remainingTime: Int
    var isPaused: Bool = false
    var isCompleted: Bool = false
    var recipeId: String?
    var cancellable: AnyCancellable?
    
    init(id: String, name: String, duration: Int, endTime: Date, recipeId: String? = nil) {
        self.id = id
        self.name = name
        self.duration = duration
        self.endTime = endTime
        self.remainingTime = duration
        self.recipeId = recipeId
    }
    
    var progress: Float {
        if duration == 0 { return 0 }
        return Float(duration - remainingTime) / Float(duration)
    }
    
    var formattedTimeRemaining: String {
        let minutes = remainingTime / 60
        let seconds = remainingTime % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
