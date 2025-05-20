//
//  ErrorHandling.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import SwiftUI

/// Domain-specific errors for the Ayewam app
enum AyewamError: Error {
    // Data-related errors
    case dataNotFound
    case failedToSaveData
    case invalidData
    case duplicateData
    
    // Operation-related errors
    case operationFailed(reason: String)
    case networkError(reason: String)
    case userCancelled
    
    // Recipe-specific errors
    case recipeNotFound
    case ingredientNotFound
    case stepNotFound
    case categoryNotFound
    case invalidRecipeData
    
    /// User-friendly description of the error
    var localizedDescription: String {
        switch self {
        case .dataNotFound:
            return "The requested data could not be found."
        case .failedToSaveData:
            return "Failed to save data. Please try again."
        case .invalidData:
            return "The data provided is invalid."
        case .duplicateData:
            return "This data already exists."
            
        case .operationFailed(let reason):
            return "Operation failed: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        case .userCancelled:
            return "Operation cancelled by user."
            
        case .recipeNotFound:
            return "Recipe not found."
        case .ingredientNotFound:
            return "Ingredient not found."
        case .stepNotFound:
            return "Recipe step not found."
        case .categoryNotFound:
            return "Category not found."
        case .invalidRecipeData:
            return "Invalid recipe data."
        }
    }
    
    /// System error log description (more detailed for debugging)
    var logDescription: String {
        switch self {
        case .operationFailed(let reason):
            return "Operation failed: \(reason)"
        case .networkError(let reason):
            return "Network error: \(reason)"
        default:
            return localizedDescription
        }
    }
}

/// Error handler for managing errors across the app
class ErrorHandler {
    // MARK: - Singleton instance
    static let shared = ErrorHandler()
    
    // MARK: - Properties
    private var errors: [String: Error] = [:]
    private var loggedErrors: [String: Int] = [:]
    
    // MARK: - Public methods
    
    /// Log an error with a given identifier
    func logError(_ error: Error, identifier: String) {
        errors[identifier] = error
        
        // Increment the error count for this identifier
        let count = loggedErrors[identifier] ?? 0
        loggedErrors[identifier] = count + 1
        
        // Log to console
        print("ERROR [\(identifier)] #\(count + 1): \(errorDescription(error))")
    }
    
    /// Get a user-friendly error message
    func userFriendlyMessage(for error: Error) -> String {
        if let ayewamError = error as? AyewamError {
            return ayewamError.localizedDescription
        } else if let nsError = error as NSError? {
            // Handle CoreData errors
            if nsError.domain == NSCocoaErrorDomain {
                switch nsError.code {
                case 4097: // Object not found
                    return "The requested item could not be found."
                case 1550: // Cannot save
                    return "Unable to save your changes. Please try again."
                default:
                    return "An unexpected error occurred (\(nsError.domain): \(nsError.code))."
                }
            }
            
            return nsError.localizedDescription
        }
        
        return "An unexpected error occurred."
    }
    
    /// Get detailed error description for logging
    func errorDescription(_ error: Error) -> String {
        if let ayewamError = error as? AyewamError {
            return ayewamError.logDescription
        } else if let nsError = error as NSError? {
            return "[\(nsError.domain):\(nsError.code)] \(nsError.localizedDescription)\nUserInfo: \(nsError.userInfo)"
        }
        
        return error.localizedDescription
    }
    
    /// Clear error for a given identifier
    func clearError(identifier: String) {
        errors.removeValue(forKey: identifier)
    }
    
    /// Clear all logged errors
    func clearAllErrors() {
        errors.removeAll()
    }
}

// MARK: - View Extensions

extension View {
    /// Show an error alert with retry option
    func errorAlert(isPresented: Binding<Bool>, error: Error?, retryAction: @escaping () -> Void = {}) -> some View {
        let errorMessage = error.map { ErrorHandler.shared.userFriendlyMessage(for: $0) } ?? "An error occurred"
        
        return alert(isPresented: isPresented) {
            Alert(
                title: Text(Constants.Text.genericErrorTitle),
                message: Text(errorMessage),
                primaryButton: .default(Text(Constants.Text.retryButtonLabel), action: retryAction),
                secondaryButton: .cancel()
            )
        }
    }
    
    /// Show a simple error message with retry button
    func errorOverlay(error: Error?, isPresented: Bool, retryAction: @escaping () -> Void) -> some View {
        ZStack {
            self
            
            if isPresented, let error = error {
                ErrorView(
                    errorMessage: ErrorHandler.shared.userFriendlyMessage(for: error),
                    retryAction: retryAction
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
    }
}

// MARK: - Result Extension

extension Result where Failure == Error {
    /// Handle the result with success and failure closures
    func handle(
        success: (Success) -> Void,
        failure: (Error) -> Void
    ) {
        switch self {
        case .success(let value):
            success(value)
        case .failure(let error):
            failure(error)
        }
    }
    
    /// Log error with identifier if result is a failure
    func logErrorIfNeeded(identifier: String) {
        if case .failure(let error) = self {
            ErrorHandler.shared.logError(error, identifier: identifier)
        }
    }
}
