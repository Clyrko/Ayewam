//
//  RecipeSubmissionManager.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import Foundation
import CloudKit
import Combine
import UIKit

/// Centralized service for managing the entire recipe submission workflow
@MainActor
class RecipeSubmissionManager: ObservableObject {
    private let repository: RecipeSubmissionRepository
    private let toastManager: ToastManager

    @Published private(set) var isSubmitting = false
    @Published private(set) var userSubmissionCount = 0
    @Published private(set) var lastSubmissionDate: Date?
    @Published private(set) var hasReachedDailyLimit = false
    
    private let dailySubmissionLimit = 5
    private let rateLimitWindow: TimeInterval = 24 * 60 * 60
    
    private enum UserDefaultsKeys {
        static let submissionCount = "RecipeSubmissionCount"
        static let lastSubmissionDate = "LastRecipeSubmissionDate"
        static let lastResetDate = "LastSubmissionResetDate"
    }

    init(
        repository: RecipeSubmissionRepository = RecipeSubmissionRepository(),
        toastManager: ToastManager = ToastManager.shared
    ) {
        self.repository = repository
        self.toastManager = toastManager
        
        loadSubmissionState()
        checkDailyReset()
    }
    
    static let shared = RecipeSubmissionManager()
    
    // MARK: - Public Methods
    func submitRecipe(
        recipeName: String,
        additionalDetails: String? = nil
    ) async -> Result<Void, RecipeSubmissionError> {
        
        guard !isSubmitting else {
            return .failure(.unknownError(NSError(domain: "RecipeSubmission", code: -1, userInfo: [NSLocalizedDescriptionKey: "Another submission is in progress"])))
        }
        
        guard !hasReachedDailyLimit else {
            toastManager.showWarning(
                title: "Daily Limit Reached",
                message: "You can submit up to \(dailySubmissionLimit) recipes per day. Please try again tomorrow.",
                duration: 5.0
            )
            return .failure(.quotaExceeded)
        }
        
        isSubmitting = true
        
        do {
            let userID = try await repository.getCurrentUserID()
            
            // Create submission
            let submission = RecipeSubmission(
                recipeName: recipeName.trimmingCharacters(in: .whitespacesAndNewlines),
                additionalDetails: additionalDetails?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == true ? nil : additionalDetails?.trimmingCharacters(in: .whitespacesAndNewlines),
                userID: userID
            )
            
            try await repository.submitRecipe(submission)
            
            incrementSubmissionCount()
            
            showSuccessNotification()
            
            trackSubmissionSuccess(recipeName: recipeName)
            
            isSubmitting = false
            return .success(())
            
        } catch let error as RecipeSubmissionError {
            isSubmitting = false
            showErrorNotification(error)
            trackSubmissionError(error, recipeName: recipeName)
            return .failure(error)
            
        } catch {
            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
            isSubmitting = false
            showErrorNotification(submissionError)
            trackSubmissionError(submissionError, recipeName: recipeName)
            return .failure(submissionError)
        }
    }
    
    /// Check if a recipe name has already been submitted
    func checkForDuplicateRecipe(_ recipeName: String) async -> Bool {
        do {
            return try await repository.checkDuplicateRecipeName(recipeName)
        } catch {
            print("Failed to check for duplicate recipe: \(error)")
            return false
        }
    }
    
    /// Get user's submission history
    func getUserSubmissions() async -> [RecipeSubmission] {
        do {
            return try await repository.fetchUserSubmissions()
        } catch {
            print("Failed to fetch user submissions: \(error)")
            return []
        }
    }
    
    /// Reset daily submission limit (for testing or admin purposes)
    func resetDailyLimit() {
        userSubmissionCount = 0
        hasReachedDailyLimit = false
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.submissionCount)
        UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastResetDate)
    }
    
    /// Check submission eligibility
    func canSubmitRecipe() -> (canSubmit: Bool, reason: String?) {
        if hasReachedDailyLimit {
            return (false, "You've reached the daily limit of \(dailySubmissionLimit) recipe suggestions. Please try again tomorrow.")
        }
        
        if isSubmitting {
            return (false, "Another submission is in progress. Please wait.")
        }
        
        return (true, nil)
    }
    
    /// Get remaining submissions for today
    var remainingSubmissions: Int {
        max(0, dailySubmissionLimit - userSubmissionCount)
    }
    
    /// Get time until daily reset
    var timeUntilReset: TimeInterval? {
        guard let lastReset = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastResetDate) as? Date else {
            return nil
        }
        
        let nextReset = Calendar.current.startOfDay(for: lastReset.addingTimeInterval(86400))
        let now = Date()
        
        return nextReset.timeIntervalSince(now)
    }
    
    // MARK: - Private Methods
    
    private func loadSubmissionState() {
        userSubmissionCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.submissionCount)
        lastSubmissionDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastSubmissionDate) as? Date
        
        updateDailyLimitStatus()
    }
    
    private func checkDailyReset() {
        let now = Date()
        let calendar = Calendar.current
        
        if let lastReset = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastResetDate) as? Date {
            if !calendar.isDate(lastReset, inSameDayAs: now) {
                resetDailyLimit()
            }
        } else {
            UserDefaults.standard.set(now, forKey: UserDefaultsKeys.lastResetDate)
        }
    }
    
    private func incrementSubmissionCount() {
        userSubmissionCount += 1
        lastSubmissionDate = Date()
        
        UserDefaults.standard.set(userSubmissionCount, forKey: UserDefaultsKeys.submissionCount)
        UserDefaults.standard.set(lastSubmissionDate, forKey: UserDefaultsKeys.lastSubmissionDate)
        
        updateDailyLimitStatus()
    }
    
    private func updateDailyLimitStatus() {
        hasReachedDailyLimit = userSubmissionCount >= dailySubmissionLimit
    }
    
    private func showSuccessNotification() {
        toastManager.showSuccess(
            title: "Suggestion Submitted!",
            message: "Thanks! Your suggestion helps preserve Ghanaian culinary traditions. You'll be notified when recipes are added in future app updates.",
            duration: 4.0
        )
    }
    
    private func showErrorNotification(_ error: RecipeSubmissionError) {
        switch error {
        case .userNotAuthenticated:
            toastManager.showError(
                title: "Sign In Required",
                message: "Please sign in to iCloud to submit recipe suggestions.",
                duration: 5.0,
                action: ToastAction(title: "Settings") {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            )
            
        case .networkError:
            toastManager.showError(
                title: "Network Error",
                message: "Please check your internet connection and try again.",
                duration: 5.0,
                action: ToastAction(title: "Retry") {
                    // The user can manually retry by tapping the submit button again
                }
            )
            
        case .quotaExceeded:
            toastManager.showWarning(
                title: "Daily Limit Reached",
                message: "You can submit up to \(dailySubmissionLimit) recipes per day. Please try again tomorrow.",
                duration: 5.0
            )
            
        default:
            toastManager.showError(
                title: "Submission Failed",
                message: error.localizedDescription,
                duration: 5.0,
                action: ToastAction(title: "Retry") {
                }
            )
        }
    }
    
    // MARK: - Analytics & Tracking
    
    private func trackSubmissionSuccess(recipeName: String) {
        print("📊 Recipe submission successful: \(recipeName)")
        print("📊 User submission count: \(userSubmissionCount)/\(dailySubmissionLimit)")
        
        //TODO: justynx Future: Integrate with analytics framework
        // Analytics.track("recipe_submission_success", properties: [
        //     "recipe_name": recipeName,
        //     "submission_count": userSubmissionCount,
        //     "user_id": await getCurrentUserIDSafely()
        // ])
    }
    
    private func trackSubmissionError(_ error: RecipeSubmissionError, recipeName: String) {
        print("📊 Recipe submission failed: \(error.localizedDescription)")
        print("📊 Recipe name: \(recipeName)")
        
        // TODO: justynx Future: Integrate with analytics framework
        // Analytics.track("recipe_submission_error", properties: [
        //     "error_type": String(describing: error),
        //     "recipe_name": recipeName,
        //     "error_message": error.localizedDescription
        // ])
    }
    
    private func getCurrentUserIDSafely() async -> String? {
        do {
            return try await repository.getCurrentUserID()
        } catch {
            return nil
        }
    }
}

// MARK: - Convenience Extensions
extension RecipeSubmissionManager {
    
    func submitRecipeFromSearch(_ searchTerm: String) async -> Bool {
        let result = await submitRecipe(recipeName: searchTerm)
        
        switch result {
        case .success:
            return true
        case .failure:
            return false
        }
    }
    
    var submissionStatusText: String {
        if hasReachedDailyLimit {
            return "Daily limit reached (\(dailySubmissionLimit)/\(dailySubmissionLimit))"
        } else {
            return "\(userSubmissionCount)/\(dailySubmissionLimit) suggestions today"
        }
    }
    
    var timeUntilResetFormatted: String? {
        guard let timeInterval = timeUntilReset, timeInterval > 0 else {
            return nil
        }
        
        let hours = Int(timeInterval) / 3600
        let minutes = (Int(timeInterval) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m until reset"
        } else {
            return "\(minutes)m until reset"
        }
    }
}

// MARK: - Integration with DataManager
extension DataManager {
    
    var recipeSubmissionManager: RecipeSubmissionManager {
        RecipeSubmissionManager.shared
    }
}

// MARK: - Preview Support

#if DEBUG
extension RecipeSubmissionManager {
    
    static func preview() -> RecipeSubmissionManager {
        let manager = RecipeSubmissionManager()
        manager.userSubmissionCount = 2
        manager.lastSubmissionDate = Date().addingTimeInterval(-3600)
        return manager
    }
    
    static func previewAtLimit() -> RecipeSubmissionManager {
        let manager = RecipeSubmissionManager()
        manager.userSubmissionCount = 5
        manager.hasReachedDailyLimit = true
        manager.lastSubmissionDate = Date().addingTimeInterval(-1800)
        return manager
    }
    
    /// Simulate a submission for testing
    func simulateSubmission() async {
        isSubmitting = true
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        incrementSubmissionCount()
        showSuccessNotification()
        
        isSubmitting = false
    }
}
#endif
