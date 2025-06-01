//
//  HapticFeedbackManager.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 6/1/25.
//

import UIKit
import SwiftUI

class HapticFeedbackManager {
    static let shared = HapticFeedbackManager()
    
    // Generators for different feedback types
    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()
    
    private init() {
        prepareGenerators()
    }
    
    // MARK: - Generator Preparation
    
    private func prepareGenerators() {
        impactLight.prepare()
        impactMedium.prepare()
        impactHeavy.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }
    
    // MARK: - Recipe Interaction Feedback
    /// Light tap when browsing recipes or cards
    func recipeTapped() {
        impactLight.impactOccurred()
    }
    
    /// Medium feedback when favoriting a recipe
    func recipeFavorited() {
        impactMedium.impactOccurred()
    }
    
    /// Strong feedback when unfavoriting a recipe
    func recipeUnfavorited() {
        impactHeavy.impactOccurred()
    }
    
    /// Selection feedback for category changes
    func categorySelected() {
        selectionGenerator.selectionChanged()
    }
    
    /// Success notification for recipe submission
    func recipeSubmissionSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Error notification for recipe submission failure
    func recipeSubmissionError() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    // MARK: - Cooking Mode Feedback
    
    /// Medium feedback when starting cooking mode
    func cookingModeStarted() {
        impactMedium.impactOccurred()
    }
    
    /// Light feedback when moving to next step
    func cookingStepAdvanced() {
        impactLight.impactOccurred()
    }
    
    /// Heavy feedback when completing a step
    func cookingStepCompleted() {
        impactHeavy.impactOccurred()
    }
    
    /// Success notification when recipe is completed
    func recipeCompleted() {
        // Create a custom completion pattern
        DispatchQueue.main.async { [weak self] in
            self?.impactMedium.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self?.impactMedium.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.notificationGenerator.notificationOccurred(.success)
                }
            }
        }
    }
    
    // MARK: - Timer Feedback
    
    /// Medium feedback when starting a timer
    func timerStarted() {
        impactMedium.impactOccurred()
    }
    
    /// Light warning feedback for timer warnings (30s, 60s remaining)
    func timerWarning() {
        impactLight.impactOccurred()
    }
    
    /// Strong completion feedback when timer finishes
    func timerCompleted() {
        // Create a distinctive timer completion pattern
        DispatchQueue.main.async { [weak self] in
            self?.impactHeavy.impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                self?.impactMedium.impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.notificationGenerator.notificationOccurred(.success)
                }
            }
        }
    }
    
    /// Medium feedback when canceling a timer
    func timerCanceled() {
        impactMedium.impactOccurred()
    }
    
    // MARK: - Navigation Feedback
    
    /// Light feedback for tab switches
    func tabSwitched() {
        selectionGenerator.selectionChanged()
    }
    
    /// Light feedback for button presses
    func buttonPressed() {
        impactLight.impactOccurred()
    }
    
    /// Medium feedback for important actions
    func actionPerformed() {
        impactMedium.impactOccurred()
    }
    
    // MARK: - Search and Filter Feedback
    
    /// Selection feedback for search filters
    func filterApplied() {
        selectionGenerator.selectionChanged()
    }
    
    /// Light feedback when clearing search/filters
    func searchCleared() {
        impactLight.impactOccurred()
    }
    
    /// Success feedback for successful search
    func searchSuccess() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Light warning for empty search results
    func searchEmpty() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    // MARK: - Generic Feedback
    
    /// Success notification for any successful action
    func success() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Error notification for any failed action
    func error() {
        notificationGenerator.notificationOccurred(.error)
    }
    
    /// Warning notification for cautionary actions
    func warning() {
        notificationGenerator.notificationOccurred(.warning)
    }
    
    /// Light impact for subtle interactions
    func lightImpact() {
        impactLight.impactOccurred()
    }
    
    /// Medium impact for standard interactions
    func mediumImpact() {
        impactMedium.impactOccurred()
    }
    
    /// Heavy impact for important interactions
    func heavyImpact() {
        impactHeavy.impactOccurred()
    }
    
    /// Selection feedback for picker-style interactions
    func selection() {
        selectionGenerator.selectionChanged()
    }
    
    // MARK: - Refresh and Loading Feedback
    
    /// Medium feedback when pull-to-refresh starts
    func refreshStarted() {
        impactMedium.impactOccurred()
    }
    
    /// Success feedback when refresh completes
    func refreshCompleted() {
        notificationGenerator.notificationOccurred(.success)
    }
    
    /// Light feedback for loading states
    func loadingStateChanged() {
        impactLight.impactOccurred()
    }
    
    // MARK: - Utility Methods
    
    /// Prepares generators for better performance before expected use
    func prepareForInteraction() {
        prepareGenerators()
    }
    
    /// Custom haptic pattern with specific timing
    func customPattern(impacts: [(UIImpactFeedbackGenerator.FeedbackStyle, TimeInterval)]) {
        guard !impacts.isEmpty else { return }
        
        let firstImpact = impacts[0]
        performImpact(style: firstImpact.0)
        
        for i in 1..<impacts.count {
            let impact = impacts[i]
            DispatchQueue.main.asyncAfter(deadline: .now() + impact.1) { [weak self] in
                self?.performImpact(style: impact.0)
            }
        }
    }
    
    private func performImpact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light:
            impactLight.impactOccurred()
        case .medium:
            impactMedium.impactOccurred()
        case .heavy:
            impactHeavy.impactOccurred()
        @unknown default:
            impactMedium.impactOccurred()
        }
    }
}

// MARK: - SwiftUI View Extension for Easy Haptic Integration

extension View {
    /// Adds haptic feedback to any view on tap
    func hapticTap(
        _ feedbackType: HapticFeedbackType = .light,
        action: @escaping () -> Void = {}
    ) -> some View {
        self.onTapGesture {
            HapticFeedbackManager.shared.performFeedback(feedbackType)
            action()
        }
    }
    
    /// Adds haptic feedback on button press
    func hapticPress(
        _ feedbackType: HapticFeedbackType = .medium
    ) -> some View {
        self.pressEvents(
            onPress: {
                HapticFeedbackManager.shared.performFeedback(feedbackType)
            },
            onRelease: {}
        )
    }
}

// MARK: - Haptic Feedback Types Enum

enum HapticFeedbackType {
    case light
    case medium
    case heavy
    case selection
    case success
    case warning
    case error
    case recipeTap
    case recipeFavorite
    case cookingStep
    case timerStart
    case timerComplete
    case tabSwitch
    case refresh
}

extension HapticFeedbackManager {
    /// Performs feedback based on type
    func performFeedback(_ type: HapticFeedbackType) {
        switch type {
        case .light:
            lightImpact()
        case .medium:
            mediumImpact()
        case .heavy:
            heavyImpact()
        case .selection:
            selection()
        case .success:
            success()
        case .warning:
            warning()
        case .error:
            error()
        case .recipeTap:
            recipeTapped()
        case .recipeFavorite:
            recipeFavorited()
        case .cookingStep:
            cookingStepAdvanced()
        case .timerStart:
            timerStarted()
        case .timerComplete:
            timerCompleted()
        case .tabSwitch:
            tabSwitched()
        case .refresh:
            refreshStarted()
        }
    }
}
