//
//  CookingView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import SwiftUI
import AVFoundation

struct CookingView: View {
    @ObservedObject var viewModel: CookingViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var showExitConfirmation = false
    @State private var showActiveTimers = false
    
    // Haptic stuff
    private let hapticImpact = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Header
                    cookingHeader
                    
                    // Progress indicator
                    recipeProgressBar
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Current step view
                            if let currentStep = viewModel.session.currentStep {
                                StepDetailView(
                                    step: currentStep,
                                    isActive: true,
                                    isCompleted: viewModel.session.isStepCompleted(Int(currentStep.orderIndex)),
                                    timerState: viewModel.activeTimers[Int(currentStep.orderIndex)],
                                    onTimerStart: {
                                        viewModel.startTimer(for: currentStep)
                                    },
                                    onTimerCancel: {
                                        viewModel.cancelTimer(for: Int(currentStep.orderIndex))
                                    }
                                )
                                .transition(.opacity)
                                .id("step-\(currentStep.orderIndex)")
                            }
                            
                            // Ingredients overlay (conditionally shown)
                            if viewModel.showIngredients {
                                ingredientsPanel
                                    .transition(.move(edge: .bottom))
                            }
                        }
                        .padding()
                    }
                    
                    cookingNavigationControls
                }
            }
            .navigationTitle("Cooking Mode")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showExitConfirmation = true }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button(action: { viewModel.toggleIngredients() }) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(.primary)
                        }
                        
                        Button(action: { showActiveTimers.toggle() }) {
                            Image(systemName: "timer")
                                .foregroundColor(.primary)
                                .overlay(
                                    viewModel.activeTimers.isEmpty ? nil :
                                        Text("\(viewModel.activeTimers.count)")
                                            .font(.system(size: 12))
                                            .padding(4)
                                            .background(Circle().fill(Color.red))
                                            .foregroundColor(.white)
                                            .offset(x: 10, y: -10)
                                )
                        }
                    }
                }
            }
            .alert(isPresented: $showExitConfirmation) {
                Alert(
                    title: Text("Exit Cooking Mode?"),
                    message: Text("Your cooking progress will be lost."),
                    primaryButton: .destructive(Text("Exit")) {
                        exitCookingMode()
                    },
                    secondaryButton: .cancel()
                )
            }
            .overlay(
                // Completion overlay
                Group {
                    if viewModel.showStepCompletion {
                        CookingCompletionView {
                            exitCookingMode()
                        }
                        .transition(.opacity)
                    }
                }
            )
            .onAppear {
                viewModel.startCooking()
            }
            .onDisappear {
                viewModel.endCooking()
            }
            
            .sheet(isPresented: $showActiveTimers) {
                NavigationView {
                    ScrollView {
                        ActiveTimersView(
                            timers: viewModel.getActiveTimersList(),
                            steps: viewModel.session.sortedSteps,
                            onCancel: { stepIndex in
                                viewModel.cancelTimer(for: stepIndex)
                            }
                        )
                        .padding()
                    }
                    .navigationTitle("Active Timers")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showActiveTimers = false
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Components
    private var cookingHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.session.recipe.name ?? "Recipe")
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
            
            if let currentStep = viewModel.session.currentStep {
                Text("Step \(currentStep.orderIndex + 1) of \(viewModel.session.totalSteps)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
    }
    
    private var recipeProgressBar: some View {
        let progress = viewModel.session.progress
        
        return VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    // Progress
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: geometry.size.width * CGFloat(progress), height: 8)
                        .animation(.spring(), value: progress)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
            .padding(.horizontal)
            
            // Step indicators
            HStack(spacing: 0) {
                ForEach(0..<viewModel.session.totalSteps, id: \.self) { index in
                    let isCompleted = viewModel.session.isStepCompleted(index)
                    let isCurrent = index == viewModel.session.currentStepIndex
                    
                    Button(action: {
                        viewModel.session.jumpToStep(index)
                        hapticImpact.impactOccurred()
                    }) {
                        Circle()
                            .fill(stepIndicatorColor(isCompleted: isCompleted, isCurrent: isCurrent))
                            .frame(width: 12, height: 12)
                            .overlay(
                                Circle()
                                    .stroke(isCurrent ? Color.blue : Color.clear, lineWidth: 2)
                            )
                            .padding(8)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
    
    private var ingredientsPanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Ingredients")
                    .font(.headline)
                
                Spacer()
                
                Button(action: { viewModel.toggleIngredients() }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            
            if let ingredients = viewModel.session.recipe.ingredients as? Set<Ingredient>, !ingredients.isEmpty {
                ForEach(sortedIngredients(from: ingredients), id: \.self) { ingredient in
                    HStack(alignment: .top, spacing: 12) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(formatIngredientQuantity(ingredient))
                                    .fontWeight(.medium)
                                
                                Text(ingredient.name ?? "")
                            }
                            
                            if let notes = ingredient.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No ingredients available")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.top, 16)
    }
    
    private var cookingNavigationControls: some View {
        HStack(spacing: 20) {
            // Previous step button
            Button(action: {
                withAnimation {
                    viewModel.previousStep()
                }
                hapticImpact.impactOccurred()
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 60, height: 60)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(30)
            }
            .disabled(viewModel.session.currentStepIndex == 0)
            .opacity(viewModel.session.currentStepIndex == 0 ? 0.5 : 1)
            
            // Mark step done button
            Button(action: {
                withAnimation {
                    viewModel.nextStep()
                }
                hapticImpact.impactOccurred(intensity: 0.8)
            }) {
                HStack(spacing: 8) {
                    if viewModel.session.currentStepIndex == viewModel.session.totalSteps - 1 {
                        Text("Finish Recipe")
                    } else {
                        Text("Next Step")
                    }
                    
                    Image(systemName: "chevron.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(height: 60)
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .cornerRadius(16)
                .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            // Skip button
            Button(action: {
                withAnimation {
                    viewModel.nextStep()
                }
                hapticImpact.impactOccurred()
            }) {
                Image(systemName: "chevron.right")
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 60, height: 60)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(30)
            }
            .disabled(viewModel.session.currentStepIndex >= viewModel.session.totalSteps - 1)
            .opacity(viewModel.session.currentStepIndex >= viewModel.session.totalSteps - 1 ? 0.5 : 1)
        }
        .padding()
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: -4)
        )
    }
    
    // MARK: - Helper Methods
    private func exitCookingMode() {
        viewModel.endCooking()
        presentationMode.wrappedValue.dismiss()
    }
    
    private func stepIndicatorColor(isCompleted: Bool, isCurrent: Bool) -> Color {
        if isCompleted {
            return Color.green
        } else if isCurrent {
            return Color.blue
        } else {
            return Color.gray.opacity(0.3)
        }
    }
    
    private func sortedIngredients(from ingredients: Set<Ingredient>) -> [Ingredient] {
        return ingredients.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    private func formatIngredientQuantity(_ ingredient: Ingredient) -> String {
        let quantityString: String
        if ingredient.quantity == 0 {
            quantityString = ""
        } else if ingredient.quantity.truncatingRemainder(dividingBy: 1) == 0 {
            quantityString = "\(Int(ingredient.quantity))"
        } else {
            quantityString = "\(ingredient.quantity)"
        }
        
        if let unit = ingredient.unit, !unit.isEmpty {
            return quantityString + " " + unit
        } else {
            return quantityString
        }
    }
}

#Preview {
    NavigationView {
        let recipe = MockData.previewRecipe(in: PersistenceController.preview.container.viewContext)
        CookingView(viewModel: CookingViewModel(recipe: recipe))
    }
}
