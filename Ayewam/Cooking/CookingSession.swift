//
//  CookingSession.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import Combine

class CookingSession: ObservableObject {
    let recipe: Recipe
    @Published var currentStepIndex: Int = 0
    @Published var completedSteps: Set<Int> = []
    @Published var startTime: Date?
    @Published var isActive: Bool = false
    @Published var isPaused: Bool = false
    
    var sortedSteps: [Step] {
        guard let steps = recipe.steps as? Set<Step> else { return [] }
        return steps.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    var currentStep: Step? {
        guard currentStepIndex >= 0 && currentStepIndex < sortedSteps.count else {
            return nil
        }
        return sortedSteps[currentStepIndex]
    }
    
    var totalSteps: Int {
        return sortedSteps.count
    }
    
    var progress: Double {
        if totalSteps == 0 { return 0 }
        return Double(completedSteps.count) / Double(totalSteps)
    }
    
    var isCompleted: Bool {
        return completedSteps.count == totalSteps
    }
    
    init(recipe: Recipe) {
        self.recipe = recipe
    }
    
    func start() {
        startTime = Date()
        isActive = true
        isPaused = false
    }
    
    func pause() {
        isPaused = true
    }
    
    func resume() {
        isPaused = false
    }
    
    func end() {
        isActive = false
        isPaused = false
    }
    
    func moveToNextStep() -> Bool {
        guard currentStepIndex < totalSteps - 1 else {
            // Already at last step
            markCurrentStepComplete()
            return false
        }
        
        markCurrentStepComplete()
        currentStepIndex += 1
        return true
    }
    
    func moveToPreviousStep() -> Bool {
        guard currentStepIndex > 0 else {
            return false
        }
        
        currentStepIndex -= 1
        return true
    }
    
    func markCurrentStepComplete() {
        if let index = currentStep?.orderIndex {
            completedSteps.insert(Int(index))
        }
    }
    
    func isStepCompleted(_ stepIndex: Int) -> Bool {
        return completedSteps.contains(stepIndex)
    }
    
    func jumpToStep(_ index: Int) {
        guard index >= 0 && index < totalSteps else { return }
        currentStepIndex = index
    }
}
