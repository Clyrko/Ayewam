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
    @State private var showClearAllConfirmation = false
    
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
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Current step view
                            if let currentStep = viewModel.session.currentStep {
                                StepCardView(
                                    step: currentStep,
                                    stepNumber: viewModel.session.currentStepIndex + 1,
                                    totalSteps: viewModel.session.totalSteps,
                                    isActive: true,
                                    isCompleted: viewModel.session.isStepCompleted(Int(currentStep.orderIndex)),
                                    timerState: viewModel.activeTimers[Int(currentStep.orderIndex)],
                                    onTimerStart: {
                                        viewModel.startTimer(for: currentStep)
                                        hapticImpact.impactOccurred(intensity: 0.5)
                                    },
                                    onTimerCancel: {
                                        viewModel.cancelTimerWithNotifications(for: Int(currentStep.orderIndex))
                                        hapticImpact.impactOccurred(intensity: 0.3)
                                    },
                                    onMarkComplete: {
                                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                            viewModel.nextStep()
                                        }
                                        hapticImpact.impactOccurred(intensity: 0.8)
                                    }
                                )
                                .transition(.asymmetric(
                                    insertion: .move(edge: .trailing).combined(with: .opacity),
                                    removal: .move(edge: .leading).combined(with: .opacity)
                                ))
                                .id("step-\(currentStep.orderIndex)")
                                
                                if viewModel.session.currentStepIndex < viewModel.session.totalSteps - 1,
                                   let nextStep = getNextStep() {
                                    nextStepPreview(nextStep)
                                        .transition(.move(edge: .bottom).combined(with: .opacity))
                                }
                            }
                            
                            // Ingredients overlay (conditionally shown)
                            if viewModel.showIngredients {
                                IngredientPanelView(
                                    ingredients: sortedIngredients(from: viewModel.session.recipe.ingredients as? Set<Ingredient> ?? []),
                                    onClose: {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            viewModel.toggleIngredients()
                                        }
                                    }
                                )
                                .transition(.move(edge: .bottom).combined(with: .opacity))
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
                        VStack(spacing: 20) {
                            // Multiple timers view
                            MultipleTimersView(
                                activeTimers: viewModel.getActiveTimersList(),
                                onCancelTimer: { stepIndex in
                                    viewModel.cancelTimer(for: stepIndex)
                                    hapticImpact.impactOccurred(intensity: 0.3)
                                }
                            )
                            
                            // Quick timer management tips
                            if !viewModel.activeTimers.isEmpty {
                                timerManagementTips
                            }
                            
                            Spacer(minLength: 50)
                        }
                        .padding()
                    }
                    .navigationTitle("Active Timers")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Clear All") {
                                // Clear all timers with confirmation
                                showClearAllConfirmation = true
                            }
                            .foregroundColor(.red)
                            .disabled(viewModel.activeTimers.isEmpty)
                        }
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showActiveTimers = false
                            }
                        }
                    }
                }
            }
            .alert("Clear All Timers?", isPresented: $showClearAllConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    viewModel.cancelAllTimers()
                    showActiveTimers = false
                    hapticImpact.impactOccurred(intensity: 0.8)
                }
            } message: {
                Text("This will stop all \(viewModel.activeTimers.count) active timers. This action cannot be undone.")
            }
        }
    }
    
    private func getNextStep() -> Step? {
        let nextIndex = viewModel.session.currentStepIndex + 1
        return viewModel.session.sortedSteps.first { Int($0.orderIndex) == nextIndex }
    }

    private func nextStepPreview(_ step: Step) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "eye.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color("GhanaGold"))
                
                Text("Coming Up Next")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("Step \(viewModel.session.currentStepIndex + 2)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray5))
                    )
            }
            
            Text(step.instruction ?? "No instruction available")
                .font(.system(size: 15))
                .foregroundColor(.secondary)
                .lineLimit(2)
                .lineSpacing(2)
            
            if step.duration > 0 {
                HStack(spacing: 6) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(Color("TimerActive"))
                    
                    let minutes = Int(step.duration) / 60
                    let seconds = Int(step.duration) % 60
                    let timeString = minutes > 0 ? "\(minutes)m \(seconds)s" : "\(seconds)s"
                    
                    Text("Will need \(timeString)")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(Color("TimerActive"))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("GhanaGold").opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    // MARK: - Components
    private var cookingHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.session.recipe.name ?? "Recipe")
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemBackground))
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
    
    private var timerManagementTips: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
                
                Text("Timer Tips")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 8) {
                tipRow(icon: "bell.fill", text: "Timers will alert you even if the app is closed")
                tipRow(icon: "iphone", text: "Check your Lock Screen for active timer displays")
                tipRow(icon: "speaker.wave.2.fill", text: "Make sure your volume is up for timer alerts")
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
    }

    private func tipRow(icon: String, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(.orange)
                .frame(width: 16)
            
            Text(text)
                .font(.system(size: 13))
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
}

#Preview {
    NavigationView {
        let recipe = MockData.previewRecipe(in: PersistenceController.preview.container.viewContext)
        CookingView(viewModel: CookingViewModel(recipe: recipe))
    }
}
