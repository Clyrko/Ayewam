//
//  StepCardView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import SwiftUI

struct StepCardView: View {
    let step: Step
    let stepNumber: Int
    let totalSteps: Int
    let isActive: Bool
    let isCompleted: Bool
    let timerState: TimerState?
    let onTimerStart: () -> Void
    let onTimerCancel: () -> Void
    let onMarkComplete: () -> Void
    
    @State private var showIngredientHighlights = false
    @State private var animateCompletion = false
    @State private var pulseTimer = false
    
    private var hasTimer: Bool {
        step.duration > 0
    }
    
    private var isTimerActive: Bool {
        timerState?.isRunning == true
    }
    
    private var formattedStepDuration: String {
        let minutes = Int(step.duration) / 60
        let seconds = Int(step.duration) % 60
        
        if minutes > 0 && seconds > 0 {
            return "\(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes) min"
        } else if seconds > 0 {
            return "\(seconds)s"
        }
        return ""
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Step header
            stepHeader
            
            // Main instruction content
            instructionContent
            
            // Timer and action section
            stepActions
        }
        .padding(24)
        .background(stepCardBackground)
        .overlay(completionOverlay)
        .scaleEffect(isCompleted ? 0.98 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isCompleted)
        .onAppear {
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                pulseTimer = true
            }
        }
    }
    
    // MARK: - Step Header
    private var stepHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            // Step number
            stepNumberIndicator
            
            VStack(alignment: .leading, spacing: 8) {
                // Step progress indicator
                HStack(spacing: 8) {
                    Text("Step \(stepNumber)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("of \(totalSteps)")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    // Progress dots
                    progressDots
                }
                
                // Duration indicator
                if hasTimer {
                    durationIndicator
                }
            }
        }
        .padding(.bottom, 20)
    }
    
    private var stepNumberIndicator: some View {
        ZStack {
            // Outer ring with progress
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color("CookingProgress"), Color("CookingProgress").opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 56, height: 56)
                .opacity(isActive ? 1.0 : 0.4)
            
            // Inner circle with completion state
            Circle()
                .fill(
                    isCompleted ?
                    LinearGradient(
                        colors: [Color("StepComplete"), Color("ForestGreen")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ) :
                    LinearGradient(
                        colors: [Color("GhanaGold").opacity(0.1), Color("KenteGold").opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay(
                    Group {
                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .scaleEffect(animateCompletion ? 1.2 : 1.0)
                                .animation(.spring(response: 0.4, dampingFraction: 0.6), value: animateCompletion)
                        } else {
                            Text("\(stepNumber)")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(isActive ? Color("GhanaGold") : .secondary)
                        }
                    }
                )
            
            // Active pulse effect
            if isActive && !isCompleted {
                Circle()
                    .stroke(Color("CookingProgress").opacity(0.3), lineWidth: 2)
                    .frame(width: 64, height: 64)
                    .scaleEffect(pulseTimer ? 1.1 : 1.0)
                    .opacity(pulseTimer ? 0.0 : 0.8)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: pulseTimer)
            }
        }
        .onChange(of: isCompleted) { _, completed in
            if completed {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
                    animateCompletion = true
                }
            }
        }
    }
    
    private var progressDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<min(totalSteps, 8), id: \.self) { index in
                Circle()
                    .fill(
                        index < stepNumber ? Color("StepComplete") :
                        index == stepNumber - 1 ? Color("CookingProgress") :
                        Color.gray.opacity(0.3)
                    )
                    .frame(width: index == stepNumber - 1 ? 8 : 6, height: index == stepNumber - 1 ? 8 : 6)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: stepNumber)
            }
            
            if totalSteps > 8 {
                Text("...")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var durationIndicator: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color("TimerActive").opacity(0.1))
                    .frame(width: 24, height: 24)
                
                Image(systemName: isTimerActive ? "timer" : "clock")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isTimerActive ? Color("TimerActive") : Color("CookingProgress"))
                    .scaleEffect(isTimerActive && pulseTimer ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulseTimer)
            }
            
            if let timerState = timerState, isTimerActive {
                Text(timerState.formattedTimeRemaining)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(Color("TimerActive"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color("TimerActive").opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color("TimerActive").opacity(0.3), lineWidth: 1)
                            )
                    )
            } else if hasTimer {
                Text(formattedStepDuration)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Instruction Content
    private var instructionContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Main instruction text
            instructionText
            
            // Ingredient highlights (if any)
            if showIngredientHighlights {
                ingredientHighlights
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.bottom, 24)
    }
    
    private var instructionText: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(step.instruction ?? "No instruction available")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
                .overlay(
                    // Subtle text highlighting for key actions
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isActive ? Color("GhanaGold").opacity(0.2) : Color.clear,
                            lineWidth: 2
                        )
                        .padding(-8)
                )
            
            // Show ingredient highlights toggle
            if hasIngredientMentions {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showIngredientHighlights.toggle()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color("GhanaGold"))
                        
                        Text(showIngredientHighlights ? "Hide ingredients" : "Show ingredients used")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color("GhanaGold"))
                        
                        Image(systemName: showIngredientHighlights ? "chevron.up" : "chevron.down")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(Color("GhanaGold"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color("GhanaGold").opacity(0.1))
                            .overlay(
                                Capsule()
                                    .stroke(Color("GhanaGold").opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var ingredientHighlights: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "list.bullet.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(Color("SoupTeal"))
                
                Text("Ingredients for this step:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            if stepSpecificIngredients.isEmpty {
                // Show message when no ingredients detected
                HStack(spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                    
                    Text("No specific ingredients detected in this step")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .italic()
                }
                .padding(.leading, 8)
            } else {
                // Show detected ingredients with quantities
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(stepSpecificIngredients, id: \.self) { ingredient in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color("SoupTeal"))
                                .frame(width: 6, height: 6)
                            
                            HStack(spacing: 4) {
                                // Show quantity if available
                                if ingredient.quantity > 0 {
                                    Text(formatIngredientQuantity(ingredient))
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.primary)
                                }
                                
                                Text(ingredient.name ?? "Unknown")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(.secondary)
                                
                                // Show notes if available
                                if let notes = ingredient.notes, !notes.isEmpty {
                                    Text("(\(notes))")
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                        .italic()
                                }
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.leading, 8)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color("SoupTeal").opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color("SoupTeal").opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    /// Format ingredient quantity for display
    private func formatIngredientQuantity(_ ingredient: Ingredient) -> String {
        let quantityString: String
        if ingredient.quantity == 0 {
            return ""
        } else if ingredient.quantity.truncatingRemainder(dividingBy: 1) == 0 {
            quantityString = "\(Int(ingredient.quantity))"
        } else {
            quantityString = String(format: "%.1f", ingredient.quantity)
        }
        
        if let unit = ingredient.unit, !unit.isEmpty {
            return quantityString + " " + unit
        } else {
            return quantityString
        }
    }
    
    // MARK: - Step Actions
    private var stepActions: some View {
        VStack(spacing: 20) {
            if hasTimer {
                enhancedTimerSection
            }
            
            // Main action button
            mainActionButton
        }
    }

    // MARK: - Enhanced Timer Section
    private var enhancedTimerSection: some View {
        VStack(spacing: 16) {
            // Timer header
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "timer.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color("TimerActive"))
                    
                    Text("Cooking Timer")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                if !isTimerActive {
                    Text(formattedStepDuration)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color("TimerActive").opacity(0.1))
                        )
                }
            }
            
            // Circular timer display
            EnhancedTimerView(
                duration: Int(step.duration),
                timerState: timerState,
                onStart: onTimerStart,
                onCancel: onTimerCancel
            )
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("TimerActive").opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private var mainActionButton: some View {
        Button(action: onMarkComplete) {
            HStack(spacing: 12) {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                    
                    Text("Step Completed")
                        .font(.system(size: 17, weight: .semibold))
                } else {
                    Text("Mark Step Complete")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.system(size: 20))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        isCompleted ?
                        LinearGradient(
                            colors: [Color("StepComplete"), Color("ForestGreen")],
                            startPoint: .leading,
                            endPoint: .trailing
                        ) :
                        LinearGradient(
                            colors: [Color("GhanaGold"), Color("KenteGold")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .shadow(
                        color: (isCompleted ? Color("StepComplete") : Color("GhanaGold")).opacity(0.4),
                        radius: 8,
                        x: 0,
                        y: 4
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(isCompleted)
    }
    
    // MARK: - Background and Overlays
    private var stepCardBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: isActive ?
                            [Color("CookingProgress").opacity(0.4), Color("GhanaGold").opacity(0.2)] :
                            [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isActive ? 2 : 1
                    )
            )
            .shadow(
                color: isActive ? Color("CookingProgress").opacity(0.2) : Color.black.opacity(0.08),
                radius: isActive ? 16 : 12,
                x: 0,
                y: isActive ? 8 : 6
            )
    }
    
    private var completionOverlay: some View {
        Group {
            if isCompleted {
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .opacity(0.3)
                    .overlay(
                        // Subtle checkmark pattern overlay
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(Color("StepComplete").opacity(0.1))
                            .offset(x: 100, y: -80)
                    )
            }
        }
    }
    
    // MARK: - Helper Properties
    private var hasIngredientMentions: Bool {
        return !stepSpecificIngredients.isEmpty
    }
    
    /// Analyzes the step instruction and returns only ingredients mentioned in this step
    private var stepSpecificIngredients: [Ingredient] {
        guard let instruction = step.instruction?.lowercased(),
              let recipe = step.recipe,
              let allIngredients = recipe.ingredients as? Set<Ingredient> else {
            return []
        }
        
        return allIngredients.filter { ingredient in
            guard let ingredientName = ingredient.name?.lowercased() else { return false }
            
            // Check for exact matches and common variations
            let variations = generateIngredientVariations(ingredientName)
            return variations.contains { variation in
                instruction.contains(variation.lowercased())
            }
        }.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    /// Generates common variations of ingredient names for better matching
    private func generateIngredientVariations(_ name: String) -> [String] {
        var variations = [name]
        
        // Add plural/singular variations
        if name.hasSuffix("s") && name.count > 1 {
            variations.append(String(name.dropLast())) // "onions" -> "onion"
        } else {
            variations.append(name + "s") // "onion" -> "onions"
        }
        
        // Add common cooking variations
        let commonVariations: [String: [String]] = [
            "tomato": ["tomatoes", "tomato", "roma tomato", "fresh tomato", "canned tomato", "tomato paste"],
            "onion": ["onions", "onion", "yellow onion", "white onion", "red onion", "chopped onion"],
            "pepper": ["peppers", "pepper", "bell pepper", "hot pepper", "chili pepper", "scotch bonnet"],
            "ginger": ["ginger", "fresh ginger", "ginger root", "ground ginger"],
            "garlic": ["garlic", "garlic cloves", "fresh garlic", "minced garlic", "garlic powder"],
            "oil": ["oil", "cooking oil", "vegetable oil", "palm oil", "coconut oil"],
            "salt": ["salt", "sea salt", "kosher salt", "table salt"],
            "rice": ["rice", "jasmine rice", "basmati rice", "long grain rice", "white rice"],
            "chicken": ["chicken", "chicken breast", "chicken thighs", "whole chicken", "chicken pieces"],
            "beef": ["beef", "beef chunks", "stewing beef", "ground beef"],
            "fish": ["fish", "fresh fish", "dried fish", "smoked fish", "tilapia"],
            "plantain": ["plantain", "plantains", "ripe plantain", "green plantain"],
            "yam": ["yam", "yams", "white yam", "yellow yam"],
            "cassava": ["cassava", "cassava flour", "fresh cassava"],
            "palm": ["palm nut", "palm fruit", "palm oil", "palm kernel"]
        ]
        
        // Check each base ingredient for matches
        for (base, vars) in commonVariations {
            if name.contains(base) || base.contains(name) {
                variations.append(contentsOf: vars)
            }
        }
        
        // Add partial word matching for compound ingredients
        let words = name.components(separatedBy: " ")
        for word in words where word.count > 3 {
            variations.append(word)
        }
        
        return Array(Set(variations)) // Remove duplicates
    }
}

// MARK: - Preview

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let mockRecipe = MockData.previewRecipe(in: context)
    let mockStep = mockRecipe.steps?.allObjects.first as? Step ?? Step(context: context)
    
    ScrollView {
        VStack(spacing: 20) {
            StepCardView(
                step: mockStep,
                stepNumber: 1,
                totalSteps: 5,
                isActive: true,
                isCompleted: false,
                timerState: nil,
                onTimerStart: {},
                onTimerCancel: {},
                onMarkComplete: {}
            )
            
            StepCardView(
                step: mockStep,
                stepNumber: 2,
                totalSteps: 5,
                isActive: false,
                isCompleted: true,
                timerState: nil,
                onTimerStart: {},
                onTimerCancel: {},
                onMarkComplete: {}
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
