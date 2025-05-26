//
//  RecipeSubmissionViewModel.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import Foundation
import SwiftUI
import Combine

@MainActor
class RecipeSubmissionViewModel: ObservableObject {
    private let repository: RecipeSubmissionRepository
        
    @Published var recipeName: String = ""
    @Published var additionalDetails: String = ""
    @Published var isSubmitting: Bool = false
    @Published var isLoading: Bool = false
    
    @Published var recipeNameError: String?
    @Published var additionalDetailsError: String?
    @Published var isFormValid: Bool = false
    
    @Published var showConfirmationSheet: Bool = false
    @Published var showSuccessToast: Bool = false
    @Published var showErrorAlert: Bool = false
    @Published var errorMessage: String?
    
    // User submissions tracking
    @Published var userSubmissions: [RecipeSubmission] = []
    @Published var hasSubmittedBefore: Bool = false
    
    // Duplicate checking
    @Published var isDuplicateChecking: Bool = false
    @Published var isDuplicateRecipe: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var duplicateCheckTask: Task<Void, Never>?
    
    var isSubmitButtonEnabled: Bool {
        isFormValid && !isSubmitting && !isDuplicateChecking && !isDuplicateRecipe
    }
    
    var formattedCharacterCount: String {
        let count = additionalDetails.count
        let limit = 500
        return "\(count)/\(limit)"
    }
    
    var isCharacterLimitExceeded: Bool {
        additionalDetails.count > 500
    }
    
    var submissionSummary: String {
        var summary = "Recipe Name: \(recipeName.trimmingCharacters(in: .whitespacesAndNewlines))"
        
        if !additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            summary += "\n\nAdditional Details: \(additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines))"
        }
        
        return summary
    }
        
    init(repository: RecipeSubmissionRepository = RecipeSubmissionRepository()) {
        self.repository = repository
        setupValidation()
        setupRepositoryBindings()
    }
    
    // MARK: - Methods
    /// Submit the recipe suggestion
    func submitRecipe() async {
        guard isFormValid else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        do {
            // Get current user ID
            let userID = try await repository.getCurrentUserID()
            
            // Create submission
            let submission = RecipeSubmission(
                recipeName: recipeName.trimmingCharacters(in: .whitespacesAndNewlines),
                additionalDetails: additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines),
                userID: userID
            )
            
            try await repository.submitRecipe(submission)
            
            handleSubmissionSuccess()
            
        } catch let error as RecipeSubmissionError {
            handleSubmissionError(error)
        } catch {
            handleSubmissionError(.unknownError(error))
        }
        
        isSubmitting = false
    }
    
    /// Pre-fill the form with a recipe name (for empty search state)
    func prefillRecipeName(_ name: String) {
        recipeName = name
        validateRecipeName()
    }
    
    /// Reset the form to initial state
    func resetForm() {
        recipeName = ""
        additionalDetails = ""
        recipeNameError = nil
        additionalDetailsError = nil
        showConfirmationSheet = false
        showSuccessToast = false
        showErrorAlert = false
        errorMessage = nil
        isDuplicateRecipe = false
        duplicateCheckTask?.cancel()
    }
    
    /// Load user's previous submissions
    func loadUserSubmissions() async {
        isLoading = true
        
        do {
            userSubmissions = try await repository.fetchUserSubmissions()
            hasSubmittedBefore = !userSubmissions.isEmpty
        } catch {
            print("Failed to load user submissions: \(error)")
        }
        
        isLoading = false
    }
    
    /// Check if recipe name is a duplicate
    func checkForDuplicate() {
        let trimmedName = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard trimmedName.count >= 2 else {
            isDuplicateRecipe = false
            return
        }
        
        // Cancel previous check
        duplicateCheckTask?.cancel()
        
        duplicateCheckTask = Task { @MainActor in
            isDuplicateChecking = true
            
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
                
                guard !Task.isCancelled else { return }
                
                isDuplicateRecipe = try await repository.checkDuplicateRecipeName(trimmedName)
            } catch {
                print("Duplicate check failed: \(error)")
                isDuplicateRecipe = false
            }
            
            isDuplicateChecking = false
        }
    }
    
    func dismissError() {
        showErrorAlert = false
        errorMessage = nil
        repository.clearLastError()
    }
    
    func showConfirmation() {
        showConfirmationSheet = true
    }
    
    // MARK: - Private Methods
    
    private func setupValidation() {
        $recipeName
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateRecipeName()
                self?.checkForDuplicate()
            }
            .store(in: &cancellables)
        
        $additionalDetails
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.validateAdditionalDetails()
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest3($recipeNameError, $additionalDetailsError, $isDuplicateRecipe)
            .map { recipeError, detailsError, isDuplicate in
                recipeError == nil && detailsError == nil && !isDuplicate
            }
            .assign(to: &$isFormValid)
    }
    
    private func setupRepositoryBindings() {
        repository.$isLoading
            .assign(to: &$isLoading)
        
        repository.$lastError
            .compactMap { $0 }
            .sink { [weak self] error in
                self?.handleRepositoryError(error)
            }
            .store(in: &cancellables)
    }
    
    private func validateRecipeName() {
        let trimmed = recipeName.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.isEmpty {
            recipeNameError = "Recipe name is required"
            return
        }
        
        if trimmed.count < 2 {
            recipeNameError = "Recipe name must be at least 2 characters"
            return
        }
        
        if trimmed.count > 100 {
            recipeNameError = "Recipe name cannot exceed 100 characters"
            return
        }
        
        let allowedCharacterSet = CharacterSet.alphanumerics
            .union(.whitespaces)
            .union(CharacterSet(charactersIn: "-'"))
        
        if !trimmed.unicodeScalars.allSatisfy({ allowedCharacterSet.contains($0) }) {
            recipeNameError = "Recipe name can only contain letters, numbers, spaces, hyphens, and apostrophes"
            return
        }
        
        if !trimmed.contains(where: { $0.isLetter }) {
            recipeNameError = "Recipe name must contain at least one letter"
            return
        }
        
        recipeNameError = nil
    }
    
    private func validateAdditionalDetails() {
        let trimmed = additionalDetails.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.count > 500 {
            additionalDetailsError = "Additional details cannot exceed 500 characters"
            return
        }
        
        additionalDetailsError = nil
    }
    
    private func handleSubmissionSuccess() {
        resetForm()
        showSuccessToast = true
        
        // Hide toast after 4 seconds
        Task {
            try? await Task.sleep(nanoseconds: 4_000_000_000)
            showSuccessToast = false
        }
        
        Task {
            await loadUserSubmissions()
        }
    }
    
    private func handleSubmissionError(_ error: RecipeSubmissionError) {
        errorMessage = error.localizedDescription
        showErrorAlert = true
    }
    
    private func handleRepositoryError(_ error: RecipeSubmissionError) {
        if !isSubmitting {
            errorMessage = error.localizedDescription
            showErrorAlert = true
        }
    }
}

// MARK: - Preview Support
//TODO: justynx delete
#if DEBUG
extension RecipeSubmissionViewModel {
    static func preview() -> RecipeSubmissionViewModel {
        let viewModel = RecipeSubmissionViewModel()
        viewModel.recipeName = "Fufu and Light Soup"
        viewModel.additionalDetails = "Traditional Northern style preparation"
        viewModel.hasSubmittedBefore = true
        viewModel.userSubmissions = [
            RecipeSubmissionRepository.mockSubmission()
        ]
        return viewModel
    }
    
    static func previewWithError() -> RecipeSubmissionViewModel {
        let viewModel = RecipeSubmissionViewModel()
        viewModel.errorMessage = "Network connection error. Please check your internet connection and try again."
        viewModel.showErrorAlert = true
        return viewModel
    }
    
    static func previewLoading() -> RecipeSubmissionViewModel {
        let viewModel = RecipeSubmissionViewModel()
        viewModel.recipeName = "Test Recipe"
        viewModel.isSubmitting = true
        return viewModel
    }
}
#endif

// MARK: - Analytics Extension
extension RecipeSubmissionViewModel {
    /// Track submission analytics
    private func trackSubmissionAttempt() {
        print("📊 Recipe submission attempted: \(recipeName)")
    }
    
    private func trackSubmissionSuccess() {
        print("📊 Recipe submission successful: \(recipeName)")
    }
    
    private func trackSubmissionError(_ error: RecipeSubmissionError) {
        print("📊 Recipe submission failed: \(error.localizedDescription)")
    }
}
