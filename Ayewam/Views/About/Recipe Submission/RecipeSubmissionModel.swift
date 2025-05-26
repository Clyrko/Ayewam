//
//  RecipeSubmissionModel.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import Foundation
import CloudKit

// MARK: - Recipe Submission Model
/// Represents a user's recipe suggestion submitted to CloudKit
struct RecipeSubmission: Identifiable, Codable {
    let id: String
    let recipeName: String
    let additionalDetails: String?
    let submissionDate: Date
    let userID: String
    let status: SubmissionStatus
    let approvedRecipeID: String?
    
    init(
        id: String = UUID().uuidString,
        recipeName: String,
        additionalDetails: String? = nil,
        submissionDate: Date = Date(),
        userID: String,
        status: SubmissionStatus = .pending,
        approvedRecipeID: String? = nil
    ) {
        self.id = id
        self.recipeName = recipeName
        self.additionalDetails = additionalDetails
        self.submissionDate = submissionDate
        self.userID = userID
        self.status = status
        self.approvedRecipeID = approvedRecipeID
    }
}

// MARK: - Submission Status
enum SubmissionStatus: String, CaseIterable, Codable {
    case pending = "pending"
    case approved = "approved"
    case declined = "declined"
    
    var displayName: String {
        switch self {
        case .pending:
            return "Under Review"
        case .approved:
            return "Added to App"
        case .declined:
            return "Not Added"
        }
    }
    
    var systemImage: String {
        switch self {
        case .pending:
            return "clock.circle"
        case .approved:
            return "checkmark.circle.fill"
        case .declined:
            return "xmark.circle"
        }
    }
}

// MARK: - Ghanaian Regions
enum GhanaianRegion: String, CaseIterable, Codable {
    case northern = "Northern"
    case ashanti = "Ashanti"
    case greaterAccra = "Greater Accra"
    case central = "Central"
    case western = "Western"
    case eastern = "Eastern"
    case upperEast = "Upper East"
    case upperWest = "Upper West"
    case volta = "Volta"
    case bono = "Bono"
    case nationwide = "Nationwide"
    
    var displayName: String {
        return self.rawValue
    }
    
    static var allDisplayNames: [String] {
        return allCases.map { $0.displayName }
    }
}

// MARK: - CloudKit Extensions
extension RecipeSubmission {
    /// CloudKit record type name
    static let recordType = "RecipeSubmission"
    
    /// CloudKit field names
    enum CloudKitField: String {
        case recipeName = "recipeName"
        case additionalDetails = "additionalDetails"
        case submissionDate = "submissionDate"
        case userID = "userID"
        case status = "status"
        case approvedRecipeID = "approvedRecipeID"
    }
    
    /// Initialize from CloudKit record
    init?(from record: CKRecord) {
        guard let recipeName = record[CloudKitField.recipeName.rawValue] as? String,
              let submissionDate = record[CloudKitField.submissionDate.rawValue] as? Date,
              let userID = record[CloudKitField.userID.rawValue] as? String,
              let statusString = record[CloudKitField.status.rawValue] as? String,
              let status = SubmissionStatus(rawValue: statusString) else {
            return nil
        }
        
        self.id = record.recordID.recordName
        self.recipeName = recipeName
        self.additionalDetails = record[CloudKitField.additionalDetails.rawValue] as? String
        self.submissionDate = submissionDate
        self.userID = userID
        self.status = status
        self.approvedRecipeID = record[CloudKitField.approvedRecipeID.rawValue] as? String
    }
    
    /// Convert to CloudKit record
    func toCKRecord() -> CKRecord {
        let recordID = CKRecord.ID(recordName: id)
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        
        record[CloudKitField.recipeName.rawValue] = recipeName
        record[CloudKitField.additionalDetails.rawValue] = additionalDetails
        record[CloudKitField.submissionDate.rawValue] = submissionDate
        record[CloudKitField.userID.rawValue] = userID
        record[CloudKitField.status.rawValue] = status.rawValue
        record[CloudKitField.approvedRecipeID.rawValue] = approvedRecipeID
        
        return record
    }
}

// MARK: - Validation

extension RecipeSubmission {
    /// Validate recipe submission data
    func validate() throws {
        try validateRecipeName()
        try validateAdditionalDetails()
    }
    
    private func validateRecipeName() throws {
        let trimmed = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmed.count >= 2 else {
            throw RecipeSubmissionError.recipeNameTooShort
        }
        
        guard trimmed.count <= 100 else {
            throw RecipeSubmissionError.recipeNameTooLong
        }
        
        let allowedCharacterSet = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-'"))
        
        guard trimmed.unicodeScalars.allSatisfy({ allowedCharacterSet.contains($0) }) else {
            throw RecipeSubmissionError.recipeNameInvalidCharacters
        }
        
        guard trimmed.contains(where: { $0.isLetter }) else {
            throw RecipeSubmissionError.recipeNameInvalidFormat
        }
    }
    
    private func validateAdditionalDetails() throws {
        if let details = additionalDetails {
            let trimmed = details.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count <= 500 else {
                throw RecipeSubmissionError.additionalDetailsTooLong
            }
        }
    }
}

// MARK: - Recipe Submission Errors
enum RecipeSubmissionError: LocalizedError {
    case recipeNameTooShort
    case recipeNameTooLong
    case recipeNameInvalidCharacters
    case recipeNameInvalidFormat
    case additionalDetailsTooLong
    case userNotAuthenticated
    case cloudKitNotAvailable
    case networkError(Error)
    case quotaExceeded
    case permissionDenied
    case unknownError(Error)
    
    var errorDescription: String? {
        switch self {
        case .recipeNameTooShort:
            return "Recipe name must be at least 2 characters long."
        case .recipeNameTooLong:
            return "Recipe name cannot be longer than 100 characters."
        case .recipeNameInvalidCharacters:
            return "Recipe name can only contain letters, numbers, spaces, hyphens, and apostrophes."
        case .recipeNameInvalidFormat:
            return "Recipe name must contain at least one letter."
        case .additionalDetailsTooLong:
            return "Additional details cannot be longer than 500 characters."
        case .userNotAuthenticated:
            return "Please sign in to iCloud to submit recipe suggestions."
        case .cloudKitNotAvailable:
            return "Recipe suggestions are not available right now. Please try again later."
        case .networkError:
            return "Network connection error. Please check your internet connection and try again."
        case .quotaExceeded:
            return "You've reached the limit for recipe suggestions. Please try again later."
        case .permissionDenied:
            return "Permission denied. Please check your iCloud settings."
        case .unknownError(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .userNotAuthenticated:
            return "Go to Settings > [Your Name] > iCloud and make sure you're signed in."
        case .networkError:
            return "Check your internet connection and try again."
        case .cloudKitNotAvailable:
            return "This feature requires iCloud. Please try again in a few moments."
        case .quotaExceeded:
            return "You can submit more suggestions tomorrow."
        case .permissionDenied:
            return "Check your iCloud settings in the Settings app."
        default:
            return "Please try again or contact support if the problem persists."
        }
    }
}

// MARK: - CloudKit Error Mapping
extension RecipeSubmissionError {
    /// Create appropriate error from CloudKit error
    static func from(cloudKitError: Error) -> RecipeSubmissionError {
        guard let ckError = cloudKitError as? CKError else {
            return .unknownError(cloudKitError)
        }
        
        switch ckError.code {
        case .notAuthenticated:
            return .userNotAuthenticated
        case .quotaExceeded:
            return .quotaExceeded
        case .permissionFailure:
            return .permissionDenied
        case .networkUnavailable, .networkFailure:
            return .networkError(cloudKitError)
        case .serviceUnavailable, .requestRateLimited:
            return .cloudKitNotAvailable
        default:
            return .unknownError(cloudKitError)
        }
    }
}
