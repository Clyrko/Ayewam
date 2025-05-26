//
//  TrackingIntegration.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/23/25.
//

import SwiftUI
import Foundation
import CoreData

// MARK: - Enhanced Recipe Detail View with Tracking

extension RecipeDetailView {
    
    /// Track user behavior when recipe detail is viewed
    private func trackRecipeDetailViewed() {
        // Track that user viewed this recipe in detail
        UserBehaviorTracker.shared.trackRecipeViewed(recipe)
        
        // Update recently viewed for recommendations
        if let recipeId = recipe.id {
            UserDefaults.standard.addRecentlyViewedRecipe(recipeId)
        }
    }
    
    /// Track when user starts cooking mode
    private func trackCookingModeStarted() {
        // This indicates strong engagement with the recipe
        UserBehaviorTracker.shared.trackRecipeCooked(recipe)
        
        // Update cooking session timing
        UserDefaults.standard.lastCookingSession = Date()
        
        print("🍳 Started cooking: \(recipe.name ?? "Unknown") - Learning preferences")
    }
    
    /// Track favorite toggle with enhanced learning
    private func trackFavoriteToggled(newState: Bool) {
        if newState {
            // Recipe was favorited
            UserBehaviorTracker.shared.trackRecipeFavorited(recipe)
        }
        
        // Call the original toggle method
        viewModel.toggleFavorite(recipe)
        
        print("❤️ Favorite toggled: \(recipe.name ?? "Unknown") -> \(newState)")
    }
}

// MARK: - Enhanced Cooking View with Completion Tracking

extension CookingViewModel {
    
    /// Track when user completes a recipe
    func trackRecipeCompleted() {
        // Mark recipe as completed for skill progression
        if let recipeId = session.recipe.id {
            UserDefaults.standard.addCompletedRecipe(recipeId)
        }
        
        // Track the cooking completion with behavior tracker
        UserBehaviorTracker.shared.trackRecipeCooked(session.recipe)
        
        // Update cooking patterns
        let now = Date()
        let hour = Calendar.current.component(.hour, from: now)
        var timeSlots = UserDefaults.standard.preferredCookingTimeSlots
        timeSlots.append(hour)
        UserDefaults.standard.preferredCookingTimeSlots = timeSlots
        
        print("✅ Recipe completed: \(session.recipe.name ?? "Unknown") - Updated skill progression")
    }
    
    /// Track cooking session duration and patterns
    func trackCookingSessionEnd() {
        guard let startTime = session.startTime else { return }
        
        let sessionDuration = Date().timeIntervalSince(startTime)
        var durations = UserDefaults.standard.sessionDurations
        durations.append(sessionDuration)
        
        // Keep only last 20 sessions
        if durations.count > 20 {
            durations = Array(durations.suffix(20))
        }
        
        UserDefaults.standard.sessionDurations = durations
        
        print("⏱️ Cooking session ended: \(Int(sessionDuration/60)) minutes")
    }
}

// MARK: - Enhanced Recommendation Engine with User Patterns

extension ContextualRecommendationEngine {
    
    /// Get personalized recommendations using learned user behavior
    func getPersonalizedRecommendations() -> [RecommendationSection] {
        let behaviorTracker = UserBehaviorTracker.shared
        let patterns = behaviorTracker.getCookingPatterns()
        let timePreferences = behaviorTracker.getTimePreferences()
        
        var sections: [RecommendationSection] = []
        
        // Get base recommendations
        let baseRecommendations = getRecommendations()
        
        // Apply personalization based on learned patterns
        for section in baseRecommendations {
            let personalizedSection = personalizeSection(section, patterns: patterns, timePreferences: timePreferences)
            sections.append(personalizedSection)
        }
        
        // Add skill-based progression section if appropriate
        if let skillSection = getSkillProgressionSection(patterns: patterns) {
            sections.insert(skillSection, at: 1) // After time-based suggestions
        }
        
        // Add exploration suggestions for adventurous users
        if patterns.explorationRate > 0.6, let explorationSection = getExplorationSection(patterns: patterns) {
            sections.append(explorationSection)
        }
        
        return sections
    }
    
    private func personalizeSection(_ section: RecommendationSection, patterns: CookingPatterns, timePreferences: TimePreferences) -> RecommendationSection {
        var personalizedRecipes = section.recipes
        
        // Filter out ignored suggestions
        let ignoredSuggestions = UserDefaults.standard.ignoredSuggestions
        personalizedRecipes = personalizedRecipes.filter { recipe in
            guard let recipeId = recipe.id else { return true }
            let ignoredKey = "\(recipeId)|\(section.sectionType)"
            return !ignoredSuggestions.contains(ignoredKey)
        }
        
        // Apply user preferences
        switch section.sectionType {
        case .timeBased:
            // Adjust for user's actual cooking time preferences
            if timePreferences.quickMealPreference > 0.7 {
                personalizedRecipes = personalizedRecipes.filter {
                    ($0.prepTime + $0.cookTime) <= 30
                }
            }
            
        case .favoriteExpansion:
            // Boost recipes in preferred categories
            personalizedRecipes.sort { recipe1, recipe2 in
                let cat1Score = patterns.favoriteCategories.firstIndex(of: recipe1.categoryName) ?? 99
                let cat2Score = patterns.favoriteCategories.firstIndex(of: recipe2.categoryName) ?? 99
                return cat1Score < cat2Score
            }
            
        case .skillProgression:
            // Ensure appropriate difficulty progression
            let targetDifficulty = getTargetDifficulty(for: patterns.skillProgression)
            personalizedRecipes = personalizedRecipes.filter {
                $0.difficulty == targetDifficulty
            }
            
        case .culturalContext:
            // Adjust based on traditional meal preference
            if timePreferences.traditionalMealPreference > 0.6 {
                personalizedRecipes = personalizedRecipes.filter { recipe in
                    let name = recipe.name?.lowercased() ?? ""
                    return name.contains("soup") || name.contains("stew") ||
                           name.contains("fufu") || name.contains("banku")
                }
            }
            
        default:
            break
        }
        
        // Limit to top recommendations
        personalizedRecipes = Array(personalizedRecipes.prefix(5))
        
        return RecommendationSection(
            title: section.title,
            subtitle: getPersonalizedSubtitle(for: section, patterns: patterns),
            recipes: personalizedRecipes,
            reasoning: getPersonalizedReasoning(for: section, patterns: patterns),
            sectionType: section.sectionType
        )
    }
    
    private func getSkillProgressionSection(patterns: CookingPatterns) -> RecommendationSection? {
        let allRecipes = getAllRecipes() // Use public method
        let completedRecipes = UserDefaults.standard.completedRecipes
        
        // Don't show if user hasn't completed enough recipes
        guard completedRecipes.count >= 2 else { return nil }
        
        let nextDifficulty = getTargetDifficulty(for: patterns.skillProgression)
        
        let skillRecipes = allRecipes.filter { recipe in
            guard !completedRecipes.contains(recipe.id ?? ""),
                  recipe.difficulty == nextDifficulty else { return false }
            
            // Prefer recipes in user's favorite categories
            return patterns.favoriteCategories.contains(recipe.categoryName)
        }
        
        guard !skillRecipes.isEmpty else { return nil }
        
        let (title, subtitle) = getSkillProgressionTitle(
            level: patterns.skillProgression,
            completedCount: completedRecipes.count
        )
        
        return RecommendationSection(
            title: title,
            subtitle: subtitle,
            recipes: Array(skillRecipes.prefix(4)),
            reasoning: "Based on your cooking progress (\(completedRecipes.count) recipes completed), these \(nextDifficulty.lowercased()) recipes will help you advance your skills.",
            sectionType: .skillProgression
        )
    }
    
    private func getExplorationSection(patterns: CookingPatterns) -> RecommendationSection? {
        let allRecipes = getAllRecipes() // Use public method
        let viewedRecipes = Set(UserDefaults.standard.recentlyViewedRecipes)
        let exploredCategories = Set(patterns.favoriteCategories)
        
        // Find recipes in unexplored categories
        let explorationRecipes = allRecipes.filter { recipe in
            guard let recipeId = recipe.id,
                  !viewedRecipes.contains(recipeId) else { return false }
            
            // Recipe should be in a category user hasn't explored much
            return !exploredCategories.contains(recipe.categoryName)
        }
        
        guard !explorationRecipes.isEmpty else { return nil }
        
        return RecommendationSection(
            title: "Discover Something New",
            subtitle: "Based on your adventurous cooking style",
            recipes: Array(explorationRecipes.shuffled().prefix(4)),
            reasoning: "You enjoy trying new recipes! These dishes from categories you haven't explored much might become new favorites.",
            sectionType: .seasonal
        )
    }
    
    // MARK: - Public Helper Methods
    
    /// Public method to get all recipes (replaces private fetchAllRecipes)
    func getAllRecipes() -> [Recipe] {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)]
        
        do {
            return try getContext().fetch(request)
        } catch {
            print("Error fetching recipes for recommendations: \(error)")
            return []
        }
    }
    
    /// Public method to access context
    func getContext() -> NSManagedObjectContext {
        return PersistenceController.shared.container.viewContext
    }
    
    private func getTargetDifficulty(for skillLevel: SkillLevel) -> String {
        switch skillLevel {
        case .novice: return "Easy"
        case .developing: return "Medium"
        case .intermediate: return "Medium"
        case .advanced: return "Hard"
        }
    }
    
    private func getPersonalizedSubtitle(for section: RecommendationSection, patterns: CookingPatterns) -> String? {
        switch section.sectionType {
        case .skillProgression:
            return "You've completed \(UserDefaults.standard.completedRecipes.count) recipes!"
        case .favoriteExpansion:
            if patterns.favoriteCategories.isEmpty {
                return "Based on your recently viewed recipes"
            } else {
                return "More \(patterns.favoriteCategories.first?.lowercased() ?? "recipes") you might love"
            }
        default:
            return section.subtitle
        }
    }
    
    private func getPersonalizedReasoning(for section: RecommendationSection, patterns: CookingPatterns) -> String {
        let completedCount = UserDefaults.standard.completedRecipes.count
        let favoriteCount = fetchFavoriteRecipes().count
        
        var reasoning = section.reasoning
        
        // Add personalized context
        if completedCount > 0 {
            reasoning += " With \(completedCount) recipes in your cooking journey"
        }
        
        if favoriteCount > 0 {
            reasoning += " and \(favoriteCount) favorites saved"
        }
        
        reasoning += ", these suggestions are tailored to your preferences."
        
        return reasoning
    }
    
    private func fetchFavoriteRecipes() -> [Recipe] {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        
        do {
            return try getContext().fetch(request)
        } catch {
            return []
        }
    }
    
    private func getSkillProgressionTitle(level: SkillLevel, completedCount: Int) -> (String, String) {
        switch level {
        case .novice:
            return ("Build Your Foundation", "Master these basics (\(completedCount) completed so far)")
        case .developing:
            return ("Ready for More Challenge", "Time to level up your skills!")
        case .intermediate:
            return ("Advanced Techniques", "You're becoming a skilled cook!")
        case .advanced:
            return ("Master Chef Level", "Challenge yourself with complex recipes")
        }
    }
}

// MARK: - Smart Suggestion Card Enhanced Tracking

extension SmartSuggestionCard {
    
    /// Enhanced tracking for suggestion interactions
    private func trackAdvancedSuggestionInteraction() {
        guard recipe.id != nil else { return }
        
        // Track the specific suggestion interaction
        UserBehaviorTracker.shared.trackSuggestionInteracted(recipe, sectionType: sectionType)
        
        // Update success metrics for this type of suggestion
        let suggestionKey = "suggestionSuccess_\(sectionType)"
        let currentScore = UserDefaults.standard.double(forKey: suggestionKey)
        UserDefaults.standard.set(currentScore + 1.0, forKey: suggestionKey)
        
        // Track recipe view
        UserBehaviorTracker.shared.trackRecipeViewed(recipe)
        
        print("✨ Smart suggestion clicked: \(recipe.name ?? "Unknown") (\(sectionType))")
    }
    
    /// Track when user dismisses or ignores suggestion
    private func trackSuggestionDismissed() {
        UserBehaviorTracker.shared.trackSuggestionIgnored(recipe, sectionType: sectionType)
        
        print("❌ Suggestion dismissed: \(recipe.name ?? "Unknown") (\(sectionType))")
    }
}

// MARK: - DataManager Enhancement for Centralized Tracking

extension DataManager {
    
    /// Enhanced recipe manager with behavior tracking
    var smartRecipeManager: RecipeManager {
        // Return existing manager but with enhanced tracking
        recipeManager
    }
    
    /// Get behavior-aware viewmodels
    func getSmartRecipeViewModel() -> RecipeViewModel {
        // Could potentially create a new ViewModel that includes behavior tracking
        // For now, return existing one as we're tracking at the interaction level
        return recipeViewModel
    }
    
    /// Initialize behavior tracking
    func initializeBehaviorTracking() {
        // Start behavior tracking
        let _ = UserBehaviorTracker.shared
        
        print("🧠 Behavior tracking initialized")
        
        // Print current cooking journey summary for debugging
        #if DEBUG
        let summary = UserBehaviorTracker.shared.getCookingJourneySummary()
        print(summary)
        #endif
    }
}

// MARK: - App Lifecycle Integration

struct BehaviorTrackingAppDelegate {
    
    /// Call this when app launches to initialize tracking
    static func initializeTracking() {
        DataManager.shared.initializeBehaviorTracking()
    }
    
    /// Call this when app goes to background to save patterns
    static func saveTrackingData() {
        // Data is automatically saved to UserDefaults, but we could
        // perform any cleanup or optimization here
        
        let tracker = UserBehaviorTracker.shared
        let patterns = tracker.getCookingPatterns()
        
        print("💾 Saved cooking patterns: \(patterns.cookingFrequency) frequency, \(patterns.skillProgression) skill level")
    }
    
    /// Call this to reset all behavioral data (for privacy)
    static func resetAllBehaviorData() {
        UserBehaviorTracker.shared.resetBehaviorData()
        print("🔄 All behavior tracking data has been reset")
    }
}

// MARK: - Privacy Control Extension

extension UserDefaults {
    
    /// Get a privacy-friendly summary of tracked data
    var behaviorTrackingSummary: String {
        let completedCount = completedRecipes.count
        let viewedCount = recentlyViewedRecipes.count
        let favoriteCount = UserBehaviorTracker.shared.getCookingPatterns().favoriteCategories.count
        
        return """
        📊 Your Cooking Data:
        • Recipes completed: \(completedCount)
        • Recently viewed: \(viewedCount)
        • Favorite categories: \(favoriteCount)
        
        This data helps improve your recipe suggestions and stays completely private on your device.
        """
    }
    
    /// Check if user has meaningful cooking data
    var hasSignificantCookingData: Bool {
        return completedRecipes.count >= 3 ||
               recentlyViewedRecipes.count >= 10 ||
               categoryPreferences.count >= 3
    }
}
