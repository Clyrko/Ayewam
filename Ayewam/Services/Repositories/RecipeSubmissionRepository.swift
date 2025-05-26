//
//  RecipeSubmissionRepository.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import Foundation
import CloudKit
import Combine

class RecipeSubmissionRepository: ObservableObject {
    private let container: CKContainer
    private let publicDatabase: CKDatabase
    
    @Published var isLoading = false
    @Published var lastError: RecipeSubmissionError?
    
    init() {
        self.container = CKContainer.default()
        self.publicDatabase = container.publicCloudDatabase
    }
    
    // MARK: - Public Methods
    /// Submit a new recipe suggestion to CloudKit
    @MainActor
    func submitRecipe(_ submission: RecipeSubmission) async throws {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // Validate submission before sending
            try submission.validate()
            
            // Check CloudKit availability and user authentication
            try await checkCloudKitAvailability()
            
            // Convert to CloudKit record and save
            let record = submission.toCKRecord()
            let _ = try await publicDatabase.save(record)
            
            print("✅ justynx Recipe submission saved successfully: \(submission.recipeName)")
            
        } catch let error as RecipeSubmissionError {
            lastError = error
            throw error
        } catch {
            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
            lastError = submissionError
            throw submissionError
        }
    }
    
    /// Fetch user's submitted recipes
    @MainActor
    func fetchUserSubmissions() async throws -> [RecipeSubmission] {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            // Check CloudKit availability
            try await checkCloudKitAvailability()
            
            // Get current user ID
            let userRecord = try await container.userRecordID()
            let userID = userRecord.recordName
            
            // Create query for user's submissions
            let predicate = NSPredicate(format: "userID == %@", userID)
            let query = CKQuery(recordType: RecipeSubmission.recordType, predicate: predicate)
            
            // Sort by submission date (most recent first)
            query.sortDescriptors = [NSSortDescriptor(key: "submissionDate", ascending: false)]
            
            // Execute query
            let (matchResults, _) = try await publicDatabase.records(matching: query)
            
            // Convert results to RecipeSubmission objects
            var submissions: [RecipeSubmission] = []
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    if let submission = RecipeSubmission(from: record) {
                        submissions.append(submission)
                    }
                case .failure(let error):
                    print("⚠️ justynx Failed to process record: \(error)")
                }
            }
            
            print("📥 justynx Fetched \(submissions.count) user submissions")
            return submissions
            
        } catch {
            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
            lastError = submissionError
            throw submissionError
        }
    }
    
    /// Fetch all approved recipes (for admin/notification purposes)
    @MainActor
    func fetchApprovedSubmissions(since date: Date? = nil) async throws -> [RecipeSubmission] {
        isLoading = true
        lastError = nil
        
        defer {
            isLoading = false
        }
        
        do {
            try await checkCloudKitAvailability()
            
            // Create query for approved submissions
            var predicate: NSPredicate
            
            if let sinceDate = date {
                predicate = NSPredicate(format: "status == %@ AND submissionDate >= %@",
                                      SubmissionStatus.approved.rawValue,
                                      sinceDate as NSDate)
            } else {
                predicate = NSPredicate(format: "status == %@", SubmissionStatus.approved.rawValue)
            }
            
            let query = CKQuery(recordType: RecipeSubmission.recordType, predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "submissionDate", ascending: false)]
            
            // Execute query
            let (matchResults, _) = try await publicDatabase.records(matching: query)
            
            // Convert results to RecipeSubmission objects
            var submissions: [RecipeSubmission] = []
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    if let submission = RecipeSubmission(from: record) {
                        submissions.append(submission)
                    }
                case .failure(let error):
                    print("⚠️ jutynx Failed to process approved record: \(error)")
                }
            }
            
            print("📥 justynx Fetched \(submissions.count) approved submissions")
            return submissions
            
        } catch {
            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
            lastError = submissionError
            throw submissionError
        }
    }
    
    /// Check if a recipe name has already been submitted by any user
    @MainActor
    func checkDuplicateRecipeName(_ recipeName: String) async throws -> Bool {
        do {
            try await checkCloudKitAvailability()
            
            let trimmedName = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)
            let predicate = NSPredicate(format: "recipeName ==[c] %@", trimmedName)
            let query = CKQuery(recordType: RecipeSubmission.recordType, predicate: predicate)
            
            query.sortDescriptors = [NSSortDescriptor(key: "submissionDate", ascending: false)]
            
            let (matchResults, _) = try await publicDatabase.records(matching: query)
            
            return !matchResults.isEmpty
            
        } catch {
            print("⚠️ justynx Error checking duplicate recipe name: \(error)")
            return false
        }
    }
    
    /// Get current user's CloudKit record ID
    @MainActor
    func getCurrentUserID() async throws -> String {
        do {
            try await checkCloudKitAvailability()
            let userRecord = try await container.userRecordID()
            return userRecord.recordName
        } catch {
            throw RecipeSubmissionError.from(cloudKitError: error)
        }
    }
    
    // MARK: - Private Helper Methods
    /// Check CloudKit availability and user authentication
    private func checkCloudKitAvailability() async throws {
        // Check account status
        let accountStatus = try await container.accountStatus()
        
        switch accountStatus {
        case .available:
            break
        case .noAccount:
            throw RecipeSubmissionError.userNotAuthenticated
        case .restricted:
            throw RecipeSubmissionError.permissionDenied
        case .couldNotDetermine:
            throw RecipeSubmissionError.cloudKitNotAvailable
        case .temporarilyUnavailable:
            throw RecipeSubmissionError.cloudKitNotAvailable
        @unknown default:
            throw RecipeSubmissionError.cloudKitNotAvailable
        }
        
        do {
            let _ = try await container.userRecordID()
        } catch {
            throw RecipeSubmissionError.from(cloudKitError: error)
        }
    }
    
    @MainActor
    func clearLastError() {
        lastError = nil
    }
}

// MARK: - Repository Extensions for Testing

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
}
#endif

// MARK: - Batch Operations
extension RecipeSubmissionRepository {
    /// Fetch submissions in batches
    @MainActor
    func fetchSubmissionsBatch(
        limit: Int = 50,
        cursor: CKQueryOperation.Cursor? = nil
    ) async throws -> (submissions: [RecipeSubmission], nextCursor: CKQueryOperation.Cursor?) {
        
        do {
            try await checkCloudKitAvailability()
            
            let userRecord = try await container.userRecordID()
            let userID = userRecord.recordName
            
            let predicate = NSPredicate(format: "userID == %@", userID)
            let query = CKQuery(recordType: RecipeSubmission.recordType, predicate: predicate)
            query.sortDescriptors = [NSSortDescriptor(key: "submissionDate", ascending: false)]
            
            var submissions: [RecipeSubmission] = []
            var nextCursor: CKQueryOperation.Cursor?
            
            if let cursor = cursor {
                let (matchResults, cursor) = try await publicDatabase.records(continuingMatchFrom: cursor)
                nextCursor = cursor
                
                for (_, result) in matchResults {
                    if case .success(let record) = result,
                       let submission = RecipeSubmission(from: record) {
                        submissions.append(submission)
                    }
                }
            } else {
                let (matchResults, cursor) = try await publicDatabase.records(matching: query)
                nextCursor = cursor
                
                for (_, result) in matchResults {
                    if case .success(let record) = result,
                       let submission = RecipeSubmission(from: record) {
                        submissions.append(submission)
                    }
                }
            }
            
            return (submissions: submissions, nextCursor: nextCursor)
            
        } catch {
            let submissionError = RecipeSubmissionError.from(cloudKitError: error)
            lastError = submissionError
            throw submissionError
        }
    }
}
