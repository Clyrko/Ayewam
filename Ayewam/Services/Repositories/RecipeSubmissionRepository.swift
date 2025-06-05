//
//  RecipeSubmissionRepository.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import Foundation
import MessageUI
import UIKit

class RecipeSubmissionRepository: NSObject, ObservableObject {
    
    @Published var isLoading = false
    @Published var lastError: RecipeSubmissionError?
    
    private let userDefaults = UserDefaults.standard
    private let submissionsKey = "localRecipeSubmissions"
    private let dailyCountKey = "dailySubmissionCount"
    private let lastSubmissionDateKey = "lastSubmissionDate"
    
    // Email configuration
    private let recipientEmail = "bytegeniusdev@gmail.com"
    private let emailSubjectPrefix = "Ayewam Recipe Suggestion"
    
    override init() {
        super.init()
    }
    
    // MARK: - Public Methods
    
    /// Submit a recipe suggestion via email
    @MainActor
    func submitRecipe(_ submission: RecipeSubmission) async throws {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // Validate submission
            try submission.validate()
            
            // Check daily limit
            try checkDailySubmissionLimit()
            
            // Check if email is available
            guard MFMailComposeViewController.canSendMail() else {
                throw RecipeSubmissionError.emailNotConfigured
            }
            
            // Present email composer
            try await presentEmailComposer(for: submission)
            
            // Save locally for tracking
            saveSubmissionLocally(submission)
            
            print("✅ Recipe submission email composed successfully: \(submission.recipeName)")
            
        } catch let error as RecipeSubmissionError {
            lastError = error
            throw error
        } catch {
            let submissionError = RecipeSubmissionError.unknownError(error)
            lastError = submissionError
            throw submissionError
        }
    }
    
    /// Fetch user's local submissions (for UI display)
    @MainActor
    func fetchUserSubmissions() async throws -> [RecipeSubmission] {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        let submissions = getLocalSubmissions()
        print("📥 Fetched \(submissions.count) local submissions")
        return submissions
    }
    
    /// Check if recipe name is duplicate (local check only)
    @MainActor
    func checkDuplicateRecipeName(_ recipeName: String) async throws -> Bool {
        let trimmedName = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)
        let localSubmissions = getLocalSubmissions()
        
        let isDuplicate = localSubmissions.contains { submission in
            submission.recipeName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == trimmedName.lowercased()
        }
        
        return isDuplicate
    }
    
    /// Get current user ID (anonymous for email)
    @MainActor
    func getCurrentUserID() async throws -> String {
        // Generate anonymous user ID for email submissions
        if let existingID = userDefaults.string(forKey: "anonymousUserID") {
            return existingID
        }
        
        let newID = "user_\(UUID().uuidString.prefix(8))"
        userDefaults.set(newID, forKey: "anonymousUserID")
        return newID
    }
    
    @MainActor
    func clearLastError() {
        lastError = nil
    }
    
    // MARK: - Email Composition
    
    private func presentEmailComposer(for submission: RecipeSubmission) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            DispatchQueue.main.async {
                let mailComposer = MFMailComposeViewController()
                mailComposer.mailComposeDelegate = self
                
                // Set email details
                mailComposer.setToRecipients([self.recipientEmail])
                mailComposer.setSubject("\(self.emailSubjectPrefix) - \(submission.recipeName)")
                mailComposer.setMessageBody(self.createEmailBody(for: submission), isHTML: false)
                
                // Present the composer
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let window = windowScene.windows.first,
                   let rootViewController = window.rootViewController {
                    
                    var topController = rootViewController
                    while let presentedViewController = topController.presentedViewController {
                        topController = presentedViewController
                    }
                    
                    topController.present(mailComposer, animated: true) {
                        continuation.resume()
                    }
                } else {
                    continuation.resume(throwing: RecipeSubmissionError.emailPresentationFailed)
                }
            }
        }
    }
    
    private func createEmailBody(for submission: RecipeSubmission) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        dateFormatter.timeStyle = .medium
        
        var body = """
        AYEWAM RECIPE SUGGESTION
        ========================
        
        Recipe Name: \(submission.recipeName)
        """
        
        if let details = submission.additionalDetails, !details.isEmpty {
            body += "\n\nAdditional Details:\n\(details)"
        }
        
        body += """
        
        
        SUBMISSION INFO
        ===============
        Date: \(dateFormatter.string(from: submission.submissionDate))
        User ID: \(submission.userID)
        App Version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
        Build: \(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
        
        
        Thank you for helping preserve Ghanaian culinary traditions!
        
        ---
        Sent from Ayewam iOS App
        """
        
        return body
    }
    
    // MARK: - Local Storage Management
    
    private func saveSubmissionLocally(_ submission: RecipeSubmission) {
        var submissions = getLocalSubmissions()
        
        // Add new submission with pending status
        let localSubmission = RecipeSubmission(
            id: submission.id,
            recipeName: submission.recipeName,
            additionalDetails: submission.additionalDetails,
            submissionDate: submission.submissionDate,
            userID: submission.userID,
            status: .pending,
            approvedRecipeID: nil
        )
        
        submissions.append(localSubmission)
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(submissions) {
            userDefaults.set(encoded, forKey: submissionsKey)
        }
        
        // Update daily count
        updateDailySubmissionCount()
    }
    
    private func getLocalSubmissions() -> [RecipeSubmission] {
        guard let data = userDefaults.data(forKey: submissionsKey),
              let submissions = try? JSONDecoder().decode([RecipeSubmission].self, from: data) else {
            return []
        }
        
        // Sort by most recent first
        return submissions.sorted { $0.submissionDate > $1.submissionDate }
    }
    
    private func checkDailySubmissionLimit() throws {
        let today = Calendar.current.startOfDay(for: Date())
        let lastSubmissionDate = userDefaults.object(forKey: lastSubmissionDateKey) as? Date
        let dailyCount = userDefaults.integer(forKey: dailyCountKey)
        
        // Reset count if it's a new day
        if let lastDate = lastSubmissionDate,
           !Calendar.current.isDate(lastDate, inSameDayAs: today) {
            userDefaults.set(0, forKey: dailyCountKey)
            return
        }
        
        // Check if limit exceeded
        if dailyCount >= Constants.RecipeSubmission.dailySubmissionLimit {
            throw RecipeSubmissionError.quotaExceeded
        }
    }
    
    private func updateDailySubmissionCount() {
        let currentCount = userDefaults.integer(forKey: dailyCountKey)
        userDefaults.set(currentCount + 1, forKey: dailyCountKey)
        userDefaults.set(Date(), forKey: lastSubmissionDateKey)
    }
}

// MARK: - Mail Compose Delegate

extension RecipeSubmissionRepository: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        DispatchQueue.main.async {
            controller.dismiss(animated: true) {
                switch result {
                case .sent:
                    print("✅ Recipe suggestion email sent successfully")
                    // Don't throw error - email was sent successfully
                    
                case .cancelled:
                    print("📧 User cancelled email")
                    self.lastError = RecipeSubmissionError.userCancelled
                    
                case .failed:
                    print("❌ Email failed to send: \(error?.localizedDescription ?? "Unknown error")")
                    self.lastError = RecipeSubmissionError.emailSendFailed
                    
                case .saved:
                    print("💾 Email saved to drafts")
                    // Consider this a success - user can send later
                    
                @unknown default:
                    print("❓ Unknown email result")
                    self.lastError = RecipeSubmissionError.unknownError(error ?? RecipeSubmissionError.emailSendFailed)
                }
            }
        }
    }
}

// MARK: - Debug Extensions

#if DEBUG
extension RecipeSubmissionRepository {
    func createTestSubmission() -> RecipeSubmission {
        return RecipeSubmission(
            recipeName: "Test Recipe \(Int.random(in: 1000...9999))",
            additionalDetails: "This is a test submission for development purposes.",
            userID: "test-user-id"
        )
    }
    
    static func mockSubmission() -> RecipeSubmission {
        return RecipeSubmission(
            id: "mock-id",
            recipeName: "Grandmother's Jollof",
            additionalDetails: "My grandmother's special way of making jollof with extra spices",
            submissionDate: Date().addingTimeInterval(-86400),
            userID: "mock-user-id",
            status: .pending
        )
    }
    
    /// Clear all local submissions (for testing)
    func clearAllLocalSubmissions() {
        userDefaults.removeObject(forKey: submissionsKey)
        userDefaults.removeObject(forKey: dailyCountKey)
        userDefaults.removeObject(forKey: lastSubmissionDateKey)
        print("🗑️ Cleared all local submissions")
    }
}
#endif

// MARK: - Email Configuration Helper

extension RecipeSubmissionRepository {
    /// Check if email is available on device
    static var isEmailAvailable: Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    /// Get instructions for manual email if composer unavailable
    static func getManualEmailInstructions(for submission: RecipeSubmission) -> String {
        return """
        Please send an email manually to: recipes@ayewam.app
        
        Subject: Ayewam Recipe Suggestion - \(submission.recipeName)
        
        Recipe Name: \(submission.recipeName)
        Additional Details: \(submission.additionalDetails ?? "None")
        
        Thank you for helping preserve Ghanaian culinary traditions!
        """
    }
}



//TODO: justynx icloudkit implementation
//import Foundation
//import CloudKit
//import Combine
//
//class RecipeSubmissionRepository: ObservableObject {
//    private let container: CKContainer
//    private let publicDatabase: CKDatabase
//    
//    @Published var isLoading = false
//    @Published var lastError: RecipeSubmissionError?
//    
//    init() {
//        self.container = CKContainer.default()
//        self.publicDatabase = container.publicCloudDatabase
//    }
//    
//    // MARK: - Public Methods
//    /// Submit a new recipe suggestion to CloudKit
//    @MainActor
//    func submitRecipe(_ submission: RecipeSubmission) async throws {
//        isLoading = true
//        lastError = nil
//        
//        defer {
//            isLoading = false
//        }
//        
//        do {
//            // Validate submission before sending
//            try submission.validate()
//            
//            // Check CloudKit availability and user authentication
//            try await checkCloudKitAvailability()
//            
//            // Convert to CloudKit record and save
//            let record = submission.toCKRecord()
//            let _ = try await publicDatabase.save(record)
//            
//            print("✅ justynx Recipe submission saved successfully: \(submission.recipeName)")
//            
//        } catch let error as RecipeSubmissionError {
//            lastError = error
//            throw error
//        } catch {
//            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
//            lastError = submissionError
//            throw submissionError
//        }
//    }
//    
//    /// Fetch user's submitted recipes
//    @MainActor
//    func fetchUserSubmissions() async throws -> [RecipeSubmission] {
//        isLoading = true
//        lastError = nil
//        
//        defer {
//            isLoading = false
//        }
//        
//        do {
//            // Check CloudKit availability
//            try await checkCloudKitAvailability()
//            
//            // Get current user ID
//            let userRecord = try await container.userRecordID()
//            let userID = userRecord.recordName
//            
//            // Create query for user's submissions
//            let predicate = NSPredicate(format: "userID == %@", userID)
//            let query = CKQuery(recordType: RecipeSubmission.recordType, predicate: predicate)
//            
//            // Sort by submission date (most recent first)
//            query.sortDescriptors = [NSSortDescriptor(key: "submissionDate", ascending: false)]
//            
//            // Execute query
//            let (matchResults, _) = try await publicDatabase.records(matching: query)
//            
//            // Convert results to RecipeSubmission objects
//            var submissions: [RecipeSubmission] = []
//            
//            for (_, result) in matchResults {
//                switch result {
//                case .success(let record):
//                    if let submission = RecipeSubmission(from: record) {
//                        submissions.append(submission)
//                    }
//                case .failure(let error):
//                    print("⚠️ justynx Failed to process record: \(error)")
//                }
//            }
//            
//            print("📥 justynx Fetched \(submissions.count) user submissions")
//            return submissions
//            
//        } catch {
//            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
//            lastError = submissionError
//            throw submissionError
//        }
//    }
//    
//    /// Fetch all approved recipes (for admin/notification purposes)
//    @MainActor
//    func fetchApprovedSubmissions(since date: Date? = nil) async throws -> [RecipeSubmission] {
//        isLoading = true
//        lastError = nil
//        
//        defer {
//            isLoading = false
//        }
//        
//        do {
//            try await checkCloudKitAvailability()
//            
//            // Create query for approved submissions
//            var predicate: NSPredicate
//            
//            if let sinceDate = date {
//                predicate = NSPredicate(format: "status == %@ AND submissionDate >= %@",
//                                      SubmissionStatus.approved.rawValue,
//                                      sinceDate as NSDate)
//            } else {
//                predicate = NSPredicate(format: "status == %@", SubmissionStatus.approved.rawValue)
//            }
//            
//            let query = CKQuery(recordType: RecipeSubmission.recordType, predicate: predicate)
//            query.sortDescriptors = [NSSortDescriptor(key: "submissionDate", ascending: false)]
//            
//            // Execute query
//            let (matchResults, _) = try await publicDatabase.records(matching: query)
//            
//            // Convert results to RecipeSubmission objects
//            var submissions: [RecipeSubmission] = []
//            
//            for (_, result) in matchResults {
//                switch result {
//                case .success(let record):
//                    if let submission = RecipeSubmission(from: record) {
//                        submissions.append(submission)
//                    }
//                case .failure(let error):
//                    print("⚠️ jutynx Failed to process approved record: \(error)")
//                }
//            }
//            
//            print("📥 justynx Fetched \(submissions.count) approved submissions")
//            return submissions
//            
//        } catch {
//            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
//            lastError = submissionError
//            throw submissionError
//        }
//    }
//    
//    /// Check if a recipe name has already been submitted by any user
//    @MainActor
//    func checkDuplicateRecipeName(_ recipeName: String) async throws -> Bool {
//        do {
//            try await checkCloudKitAvailability()
//            
//            let trimmedName = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)
//            let predicate = NSPredicate(format: "recipeName ==[c] %@", trimmedName)
//            let query = CKQuery(recordType: RecipeSubmission.recordType, predicate: predicate)
//            
//            query.sortDescriptors = [NSSortDescriptor(key: "submissionDate", ascending: false)]
//            
//            let (matchResults, _) = try await publicDatabase.records(matching: query)
//            
//            return !matchResults.isEmpty
//            
//        } catch {
//            print("⚠️ justynx Error checking duplicate recipe name: \(error)")
//            return false
//        }
//    }
//    
//    /// Get current user's CloudKit record ID
//    @MainActor
//    func getCurrentUserID() async throws -> String {
//        do {
//            try await checkCloudKitAvailability()
//            let userRecord = try await container.userRecordID()
//            return userRecord.recordName
//        } catch {
//            throw RecipeSubmissionError.from(cloudKitError: error)
//        }
//    }
//    
//    // MARK: - Private Helper Methods
//    /// Check CloudKit availability and user authentication
//    private func checkCloudKitAvailability() async throws {
//        // Check account status
//        let accountStatus = try await container.accountStatus()
//        
//        switch accountStatus {
//        case .available:
//            break
//        case .noAccount:
//            throw RecipeSubmissionError.userNotAuthenticated
//        case .restricted:
//            throw RecipeSubmissionError.permissionDenied
//        case .couldNotDetermine:
//            throw RecipeSubmissionError.cloudKitNotAvailable
//        case .temporarilyUnavailable:
//            throw RecipeSubmissionError.cloudKitNotAvailable
//        @unknown default:
//            throw RecipeSubmissionError.cloudKitNotAvailable
//        }
//        
//        do {
//            let _ = try await container.userRecordID()
//        } catch {
//            throw RecipeSubmissionError.from(cloudKitError: error)
//        }
//    }
//    
//    @MainActor
//    func clearLastError() {
//        lastError = nil
//    }
//}
//
//// MARK: - Repository Extensions for Testing
//
//#if DEBUG
//extension RecipeSubmissionRepository {
//    func createTestSubmission() -> RecipeSubmission {
//        return RecipeSubmission(
//            recipeName: "Test Recipe \(Int.random(in: 1000...9999))",
//            additionalDetails: "This is a test submission for development purposes.",
//            userID: "test-user-id"
//        )
//    }
//    
//    static func mockSubmission() -> RecipeSubmission {
//        return RecipeSubmission(
//            id: "mock-id",
//            recipeName: "Grandmother's Jollof",
//            additionalDetails: "My grandmother's special way of making jollof with extra spices",
//            submissionDate: Date().addingTimeInterval(-86400),
//            userID: "mock-user-id",
//            status: .pending
//        )
//    }
//}
//#endif
//
//// MARK: - Batch Operations
//extension RecipeSubmissionRepository {
//    /// Fetch submissions in batches
//    @MainActor
//    func fetchSubmissionsBatch(
//        limit: Int = 50,
//        cursor: CKQueryOperation.Cursor? = nil
//    ) async throws -> (submissions: [RecipeSubmission], nextCursor: CKQueryOperation.Cursor?) {
//        
//        do {
//            try await checkCloudKitAvailability()
//            
//            let userRecord = try await container.userRecordID()
//            let userID = userRecord.recordName
//            
//            let predicate = NSPredicate(format: "userID == %@", userID)
//            let query = CKQuery(recordType: RecipeSubmission.recordType, predicate: predicate)
//            query.sortDescriptors = [NSSortDescriptor(key: "submissionDate", ascending: false)]
//            
//            var submissions: [RecipeSubmission] = []
//            var nextCursor: CKQueryOperation.Cursor?
//            
//            if let cursor = cursor {
//                let (matchResults, cursor) = try await publicDatabase.records(continuingMatchFrom: cursor)
//                nextCursor = cursor
//                
//                for (_, result) in matchResults {
//                    if case .success(let record) = result,
//                       let submission = RecipeSubmission(from: record) {
//                        submissions.append(submission)
//                    }
//                }
//            } else {
//                let (matchResults, cursor) = try await publicDatabase.records(matching: query)
//                nextCursor = cursor
//                
//                for (_, result) in matchResults {
//                    if case .success(let record) = result,
//                       let submission = RecipeSubmission(from: record) {
//                        submissions.append(submission)
//                    }
//                }
//            }
//            
//            return (submissions: submissions, nextCursor: nextCursor)
//            
//        } catch {
//            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
//            lastError = submissionError
//            throw submissionError
//        }
//    }
//}
