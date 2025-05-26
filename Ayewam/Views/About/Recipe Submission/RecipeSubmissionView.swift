//
//  RecipeSubmissionView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import SwiftUI

struct RecipeSubmissionView: View {
    @StateObject private var viewModel = RecipeSubmissionViewModel()
    @Environment(\.dismiss) private var dismiss
    
    let prefilledRecipeName: String?
    
    init(prefilledRecipeName: String? = nil) {
        self.prefilledRecipeName = prefilledRecipeName
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header section
                        headerSection
                        
                        // Form section
                        formSection
                        
                        // Submit section
                        submitSection
                        
                        // Previous submissions
                        if viewModel.hasSubmittedBefore {
                            previousSubmissionsSection
                        }
                    }
                    .padding()
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Suggest a Recipe")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                setupView()
            }
            .confirmationDialog(
                "Submit Recipe Suggestion",
                isPresented: $viewModel.showConfirmationSheet,
                titleVisibility: .visible
            ) {
                confirmationDialogContent
            } message: {
                Text(viewModel.submissionSummary)
            }
            .alert("Error", isPresented: $viewModel.showErrorAlert) {
                Button("OK") {
                    viewModel.dismissError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
        .overlay {
            if viewModel.showSuccessToast {
                successToastView
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.showSuccessToast)
                    .zIndex(100)
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("GhanaGold"), Color("KenteGold")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Help Us Grow")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Suggest traditional Ghanaian recipes")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            Text("Missing a recipe you love? Help us preserve Ghanaian culinary traditions by suggesting dishes you'd like to see in the app.")
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(2)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("GhanaGold").opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Recipe name field
            recipeNameField
            
            // Additional details field
            additionalDetailsField
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private var recipeNameField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Recipe Name", systemImage: "text.cursor")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("*")
                    .foregroundColor(.red)
                    .font(.headline)
                
                Spacer()
                
                if viewModel.isDuplicateChecking {
                    ProgressView()
                        .scaleEffect(0.8)
                } else if viewModel.isDuplicateRecipe {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                }
            }
            
            TextField("e.g., Banku and Tilapia", text: $viewModel.recipeName)
                .textFieldStyle(CustomTextFieldStyle())
                .autocapitalization(.words)
                .disableAutocorrection(false)
                .submitLabel(.next)
                .accessibilityLabel("Recipe name")
                .accessibilityHint("Enter the name of the recipe you'd like to suggest")
            
            // Error messages
            if let error = viewModel.recipeNameError {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            } else if viewModel.isDuplicateRecipe {
                Label("This recipe has already been suggested", systemImage: "info.circle")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
    }
    
    private var additionalDetailsField: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Additional Details", systemImage: "note.text")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("(Optional)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                // Character count
                Text(viewModel.formattedCharacterCount)
                    .font(.caption)
                    .foregroundColor(viewModel.isCharacterLimitExceeded ? .red : .secondary)
            }
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
                    .frame(minHeight: 100)
                
                if viewModel.additionalDetails.isEmpty {
                    Text("Any specific details? e.g., 'Northern style' or 'my grandmother's version'")
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $viewModel.additionalDetails)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .frame(minHeight: 100)
                    .accessibilityLabel("Additional details")
                    .accessibilityHint("Provide any specific details about the recipe preparation")
            }
            
            // Error message for additional details
            if let error = viewModel.additionalDetailsError {
                Label(error, systemImage: "exclamationmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.red)
            }
        }
    }
    
    // MARK: - Submit Section
    private var submitSection: some View {
        VStack(spacing: 16) {
            Button(action: {
                viewModel.showConfirmation()
            }) {
                HStack(spacing: 12) {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.9)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    
                    Text(viewModel.isSubmitting ? "Submitting..." : "Submit Suggestion")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            viewModel.isSubmitButtonEnabled ?
                            LinearGradient(
                                colors: [Color("GhanaGold"), Color("KenteGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                colors: [Color.gray.opacity(0.5)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(
                            color: viewModel.isSubmitButtonEnabled ? Color("GhanaGold").opacity(0.3) : Color.clear,
                            radius: 8,
                            x: 0,
                            y: 4
                        )
                )
            }
            .disabled(!viewModel.isSubmitButtonEnabled)
            .buttonStyle(ScaleButtonStyle())
            
            // Helper text
            Text("You'll be notified when suggested recipes are added in future app updates.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Previous Submissions Section
    private var previousSubmissionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Your Previous Suggestions")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(viewModel.userSubmissions.count)")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
            }
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.userSubmissions.prefix(3)) { submission in
                    submissionRowView(submission)
                }
                
                if viewModel.userSubmissions.count > 3 {
                    Text("+ \(viewModel.userSubmissions.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    private func submissionRowView(_ submission: RecipeSubmission) -> some View {
        HStack(spacing: 12) {
            Image(systemName: submission.status.systemImage)
                .font(.system(size: 16))
                .foregroundColor(statusColor(for: submission.status))
                .frame(width: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(submission.recipeName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text(submission.status.displayName)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(RelativeDateTimeFormatter().localizedString(for: submission.submissionDate, relativeTo: Date()))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Confirmation Dialog
    private var confirmationDialogContent: some View {
        Group {
            Button("Submit", role: .none) {
                Task {
                    await viewModel.submitRecipe()
                }
            }
            
            Button("Cancel", role: .cancel) {
            }
        }
    }
    
    // MARK: - Success Toast
    private var successToastView: some View {
        VStack {
            HStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.green)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggestion Submitted!")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Thanks! Your suggestion helps preserve Ghanaian culinary traditions.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Helper Methods
    private func setupView() {
        if let prefilledName = prefilledRecipeName {
            viewModel.prefillRecipeName(prefilledName)
        }
        
        Task {
            await viewModel.loadUserSubmissions()
        }
    }
    
    private func statusColor(for status: SubmissionStatus) -> Color {
        switch status {
        case .pending:
            return .orange
        case .approved:
            return .green
        case .declined:
            return .red
        }
    }
}

// MARK: - Custom Text Field Style
struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    .opacity(0)
            )
    }
}

// MARK: - Preview

#Preview("Default") {
    RecipeSubmissionView()
}

#Preview("Prefilled") {
    RecipeSubmissionView(prefilledRecipeName: "Kelewele with Groundnut Sauce")
}

#Preview("With Previous Submissions") {
    let view = RecipeSubmissionView()
    return view
        .onAppear {
        }
}
