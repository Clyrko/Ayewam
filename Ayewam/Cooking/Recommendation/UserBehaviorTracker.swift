//
//  UserBehaviorTracker.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/23/25.
//

import Foundation
import CoreData

// MARK: - Behavior Analysis Models

struct CookingPatterns {
    let preferredCookingTimes: [Int]        // Hours of day when user is active
    let averageSessionDuration: TimeInterval // How long user typically browses
    let preferredComplexity: String         // Easy, Medium, or Hard
    let explorationRate: Double             // 0.0-1.0: How often user tries new things
    let favoriteCategories: [String]       // Most interacted categories
    let cookingFrequency: CookingFrequency  // How often user cooks
    let skillProgression: SkillLevel        // Current cooking skill assessment
}

struct TimePreferences {
    let morningCookingLikelihood: Double    // 0.0-1.0
    let weekendCookingPreference: Double    // 0.0-1.0
    let quickMealPreference: Double         // 0.0-1.0 (prefers <30 min recipes)
    let traditionalMealPreference: Double   // 0.0-1.0 (prefers cultural dishes)
}

enum CookingFrequency {
    case beginner       // < 5 completed recipes
    case occasional     // 5-15 completed recipes
    case regular        // 15-30 completed recipes
    case experienced    // 30+ completed recipes
}

enum SkillLevel {
    case novice         // Mostly easy recipes
    case developing     // Mix of easy and medium
    case intermediate   // Comfortable with medium, some hard
    case advanced       // Regularly tackles hard recipes
}

// MARK: - User Behavior Tracker

class UserBehaviorTracker: ObservableObject {
    static let shared = UserBehaviorTracker()
    
    private let context: NSManagedObjectContext
    private var userDefaults = UserDefaults.standard
    
    // Published properties for reactive UI updates
    @Published var currentCookingPatterns: CookingPatterns
    @Published var currentTimePreferences: TimePreferences
    
    private init() {
        self.context = PersistenceController.shared.container.viewContext
        
        // Initialize with current patterns and preferences
        self.currentCookingPatterns = CookingPatterns(
            preferredCookingTimes: [],
            averageSessionDuration: 0,
            preferredComplexity: "Easy",
            explorationRate: 0.5,
            favoriteCategories: [],
            cookingFrequency: .beginner,
            skillProgression: .novice
        )
        
        self.currentTimePreferences = TimePreferences(
            morningCookingLikelihood: 0.3,
            weekendCookingPreference: 0.6,
            quickMealPreference: 0.7,
            traditionalMealPreference: 0.5
        )
        
        // Load existing patterns
        updatePatternsFromStoredData()
    }
    
    // MARK: - Core Tracking Methods
    
    /// Track when user views a recipe
    func trackRecipeViewed(_ recipe: Recipe) {
        guard let recipeId = recipe.id else { return }
        
        // Update recently viewed
        userDefaults.addRecentlyViewedRecipe(recipeId)
        
        // Track viewing patterns
        recordInteractionTime()
        trackCategoryInteraction(recipe.categoryName)
        
        // Update session data
        updateSessionMetrics()
        
        // Refresh patterns
        updatePatternsFromStoredData()
    }
    
    /// Track when user starts cooking a recipe
    func trackRecipeCooked(_ recipe: Recipe) {
        guard let recipeId = recipe.id else { return }
        
        // Add to completed recipes
        userDefaults.addCompletedRecipe(recipeId)
        
        // Track cooking session
        userDefaults.lastCookingSession = Date()
        recordCookingTimeSlot()
        
        // Track difficulty progression
        if let difficulty = recipe.difficulty {
            trackDifficultyProgression(difficulty)
        }
        
        // Track category preference
        trackCategoryPreference(recipe.categoryName, weight: 2.0) // Higher weight for cooked recipes
        
        // Update patterns
        updatePatternsFromStoredData()
        
        print("🍳 Recipe cooked: \(recipe.name ?? "Unknown") - Updated user patterns")
    }
    
    /// Track when user favorites a recipe
    func trackRecipeFavorited(_ recipe: Recipe) {
        guard let recipeId = recipe.id else { return }
        
        // Track favorite patterns
        trackCategoryPreference(recipe.categoryName, weight: 1.5)
        
        if let difficulty = recipe.difficulty {
            trackDifficultyPreference(difficulty, weight: 1.5)
        }
        
        // Track cooking time preference
        let totalTime = recipe.prepTime + recipe.cookTime
        trackCookingTimePreference(Int(totalTime))
        
        updatePatternsFromStoredData()
        
        print("❤️ Recipe favorited: \(recipe.name ?? "Unknown")")
    }
    
    /// Track when user ignores a suggestion
    func trackSuggestionIgnored(_ recipe: Recipe, sectionType: RecommendationType) {
        guard let recipeId = recipe.id else { return }
        
        // Track ignored suggestions to reduce similar recommendations
        var ignored = userDefaults.ignoredSuggestions
        let ignoredItem = "\(recipeId)|\(sectionType)"
        
        if !ignored.contains(ignoredItem) {
            ignored.append(ignoredItem)
            userDefaults.ignoredSuggestions = ignored
        }
        
        print("❌ Suggestion ignored: \(recipe.name ?? "Unknown") (\(sectionType))")
    }
    
    /// Track when user interacts with a suggestion
    func trackSuggestionInteracted(_ recipe: Recipe, sectionType: RecommendationType) {
        guard let recipeId = recipe.id else { return }
        
        // Track successful suggestions to promote similar ones
        var successful = userDefaults.successfulSuggestions
        let successItem = "\(recipeId)|\(sectionType)"
        
        if !successful.contains(successItem) {
            successful.append(successItem)
            userDefaults.successfulSuggestions = successful
        }
        
        // Positive reinforcement for suggestion type
        reinforceSuggestionType(sectionType)
        
        print("✅ Suggestion interacted: \(recipe.name ?? "Unknown") (\(sectionType))")
    }
    
    // MARK: - Pattern Analysis Methods
    
    /// Get current cooking patterns based on stored behavior data
    func getCookingPatterns() -> CookingPatterns {
        return currentCookingPatterns
    }
    
    /// Get time-based preferences
    func getTimePreferences() -> TimePreferences {
        return currentTimePreferences
    }
    
    /// Determine user's preferred difficulty level
    func getPreferredDifficulty() -> String {
        let completedRecipes = userDefaults.completedRecipes
        let favoriteRecipes = fetchFavoriteRecipes()
        
        // Analyze completed recipe difficulties
        let completedDifficulties = getRecipeDifficulties(for: completedRecipes)
        let favoriteDifficulties = favoriteRecipes.compactMap { $0.difficulty }
        
        // Weight completed more than favorites
        var difficultyScores: [String: Double] = [:]
        
        // Count completed difficulties (weight: 2.0)
        for difficulty in completedDifficulties {
            difficultyScores[difficulty, default: 0] += 2.0
        }
        
        // Count favorite difficulties (weight: 1.0)
        for difficulty in favoriteDifficulties {
            difficultyScores[difficulty, default: 0] += 1.0
        }
        
        // Return most preferred, default to Easy
        return difficultyScores.max(by: { $0.value < $1.value })?.key ?? "Easy"
    }
    
    /// Get categories user has explored or shown preference for
    func getPreferredCategories() -> [String] {
        let categoryPreferences = userDefaults.categoryPreferences
        
        // Sort by preference score and return top categories
        return categoryPreferences
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
    }
    
    /// Determine if user prefers quick recipes
    func seemsToPreferQuickRecipes() -> Bool {
        let quickPreference = userDefaults.double(forKey: "quickRecipePreference")
        return quickPreference > 0.6 // 60% threshold
    }
    
    /// Get exploration rate (how often user tries new things)
    func getExplorationRate() -> Double {
        let totalViewed = userDefaults.recentlyViewedRecipes.count
        let totalFavorited = fetchFavoriteRecipes().count
        let totalCompleted = userDefaults.completedRecipes.count
        
        // Calculate variety in interactions
        let uniqueCategories = Set(userDefaults.exploredCategories).count
        let maxCategories = 8.0 // We have 8 categories
        
        let categoryExploration = Double(uniqueCategories) / maxCategories
        
        // Balance between exploration and depth
        if totalViewed < 10 {
            return 0.8 // High exploration for new users
        } else {
            return max(0.2, min(0.8, categoryExploration))
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func updatePatternsFromStoredData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Update cooking patterns
            self.currentCookingPatterns = CookingPatterns(
                preferredCookingTimes: self.userDefaults.preferredCookingTimeSlots,
                averageSessionDuration: self.calculateAverageSessionDuration(),
                preferredComplexity: self.getPreferredDifficulty(),
                explorationRate: self.getExplorationRate(),
                favoriteCategories: self.getPreferredCategories(),
                cookingFrequency: self.determineCookingFrequency(),
                skillProgression: self.determineSkillLevel()
            )
            
            // Update time preferences
            self.currentTimePreferences = TimePreferences(
                morningCookingLikelihood: self.calculateMorningCookingLikelihood(),
                weekendCookingPreference: self.calculateWeekendPreference(),
                quickMealPreference: self.calculateQuickMealPreference(),
                traditionalMealPreference: self.calculateTraditionalMealPreference()
            )
        }
    }
    
    private func recordInteractionTime() {
        let now = Date()
        var sessionTimes = userDefaults.sessionTimes
        sessionTimes.append(now.timeIntervalSince1970)
        
        // Keep only last 50 sessions
        if sessionTimes.count > 50 {
            sessionTimes = Array(sessionTimes.suffix(50))
        }
        
        userDefaults.sessionTimes = sessionTimes
    }
    
    private func recordCookingTimeSlot() {
        let hour = Calendar.current.component(.hour, from: Date())
        var timeSlots = userDefaults.preferredCookingTimeSlots
        timeSlots.append(hour)
        
        // Keep only last 30 cooking sessions
        if timeSlots.count > 30 {
            timeSlots = Array(timeSlots.suffix(30))
        }
        
        userDefaults.preferredCookingTimeSlots = timeSlots
    }
    
    private func trackCategoryInteraction(_ categoryName: String) {
        var explored = userDefaults.exploredCategories
        if !explored.contains(categoryName) {
            explored.append(categoryName)
            userDefaults.exploredCategories = explored
        }
    }
    
    private func trackCategoryPreference(_ categoryName: String, weight: Double = 1.0) {
        var preferences = userDefaults.categoryPreferences
        preferences[categoryName, default: 0] += weight
        userDefaults.categoryPreferences = preferences
    }
    
    private func trackDifficultyProgression(_ difficulty: String) {
        var progression = userDefaults.difficultyProgression
        progression[difficulty, default: 0] += 1
        userDefaults.difficultyProgression = progression
    }
    
    private func trackDifficultyPreference(_ difficulty: String, weight: Double) {
        var preferences = userDefaults.difficultyPreferences
        preferences[difficulty, default: 0] += weight
        userDefaults.difficultyPreferences = preferences
    }
    
    private func trackCookingTimePreference(_ totalTime: Int) {
        // Categorize cooking times
        let timeCategory: String
        switch totalTime {
        case 0...20: timeCategory = "quick"
        case 21...45: timeCategory = "medium"
        case 46...90: timeCategory = "long"
        default: timeCategory = "extended"
        }
        
        var preferences = userDefaults.cookingTimePreferences
        preferences[timeCategory, default: 0] += 1
        userDefaults.cookingTimePreferences = preferences
    }
    
    private func reinforceSuggestionType(_ sectionType: RecommendationType) {
        let key = "suggestionType_\(sectionType)"
        let currentScore = userDefaults.double(forKey: key)
        userDefaults.set(currentScore + 1.0, forKey: key)
    }
    
    private func updateSessionMetrics() {
        // Simple session tracking
        let now = Date()
        if let lastSession = userDefaults.lastSessionTime {
            let sessionDuration = now.timeIntervalSince(lastSession)
            if sessionDuration < 3600 { // Less than 1 hour (same session)
                var durations = userDefaults.sessionDurations
                durations.append(sessionDuration)
                
                // Keep only last 20 sessions
                if durations.count > 20 {
                    durations = Array(durations.suffix(20))
                }
                
                userDefaults.sessionDurations = durations
            }
        }
        
        userDefaults.lastSessionTime = now
    }
    
    // MARK: - Calculation Methods
    
    private func calculateAverageSessionDuration() -> TimeInterval {
        let durations = userDefaults.sessionDurations
        guard !durations.isEmpty else { return 0 }
        
        return durations.reduce(0, +) / Double(durations.count)
    }
    
    private func determineCookingFrequency() -> CookingFrequency {
        let completedCount = userDefaults.completedRecipes.count
        
        switch completedCount {
        case 0..<5: return .beginner
        case 5..<15: return .occasional
        case 15..<30: return .regular
        default: return .experienced
        }
    }
    
    private func determineSkillLevel() -> SkillLevel {
        let difficultyProgression = userDefaults.difficultyProgression
        let easyCount = difficultyProgression["Easy"] ?? 0
        let mediumCount = difficultyProgression["Medium"] ?? 0
        let hardCount = difficultyProgression["Hard"] ?? 0
        
        let totalCompleted = easyCount + mediumCount + hardCount
        
        if totalCompleted < 3 {
            return .novice
        } else if hardCount > 2 && hardCount >= totalCompleted * Int(0.3) {
            return .advanced
        } else if mediumCount > 3 && mediumCount >= totalCompleted * Int(0.4) {
            return .intermediate
        } else {
            return .developing
        }
    }
    
    private func calculateMorningCookingLikelihood() -> Double {
        let timeSlots = userDefaults.preferredCookingTimeSlots
        let morningCooks = timeSlots.filter { $0 >= 5 && $0 <= 11 }.count
        
        guard !timeSlots.isEmpty else { return 0.3 } // Default
        return Double(morningCooks) / Double(timeSlots.count)
    }
    
    private func calculateWeekendPreference() -> Double {
        // This would require tracking cooking day of week
        // For now, return default based on cooking frequency
        let frequency = determineCookingFrequency()
        switch frequency {
        case .beginner: return 0.7 // More weekend cooking
        case .occasional: return 0.6
        case .regular: return 0.5
        case .experienced: return 0.4 // Cook any day
        }
    }
    
    private func calculateQuickMealPreference() -> Double {
        let timePreferences = userDefaults.cookingTimePreferences
        let quickCount = timePreferences["quick"] ?? 0
        let totalCount = timePreferences.values.reduce(0, +)
        
        guard totalCount > 0 else { return 0.7 } // Default to preferring quick
        return Double(quickCount) / Double(totalCount)
    }
    
    private func calculateTraditionalMealPreference() -> Double {
        let categoryPreferences = userDefaults.categoryPreferences
        let traditionalCategories = ["Soups", "Stews", "Rice Dishes"]
        
        let traditionalScore = traditionalCategories.reduce(0.0) { sum, category in
            sum + (categoryPreferences[category] ?? 0)
        }
        
        let totalScore = categoryPreferences.values.reduce(0, +)
        
        guard totalScore > 0 else { return 0.5 } // Default
        return traditionalScore / totalScore
    }
    
    // MARK: - Data Fetching Helpers
    
    private func fetchFavoriteRecipes() -> [Recipe] {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching favorite recipes: \(error)")
            return []
        }
    }
    
    private func getRecipeDifficulties(for recipeIds: [String]) -> [String] {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", recipeIds)
        
        do {
            let recipes = try context.fetch(request)
            return recipes.compactMap { $0.difficulty }
        } catch {
            print("Error fetching recipe difficulties: \(error)")
            return []
        }
    }
    
    // MARK: - Public Utility Methods
    
    /// Reset all behavioral data (for user privacy control)
    func resetBehaviorData() {
        // Clear all behavioral tracking
        userDefaults.completedRecipes = []
        userDefaults.recentlyViewedRecipes = []
        userDefaults.preferredCookingTimeSlots = []
        userDefaults.exploredCategories = []
        userDefaults.categoryPreferences = [:]
        userDefaults.difficultyProgression = [:]
        userDefaults.difficultyPreferences = [:]
        userDefaults.cookingTimePreferences = [:]
        userDefaults.sessionTimes = []
        userDefaults.sessionDurations = []
        userDefaults.ignoredSuggestions = []
        userDefaults.successfulSuggestions = []
        
        // Reset time stamps
        userDefaults.lastCookingSession = nil
        userDefaults.lastSessionTime = nil
        
        // Update patterns
        updatePatternsFromStoredData()
        
        print("🔄 User behavior data reset")
    }
    
    /// Get summary of user's cooking journey for debugging/analytics
    func getCookingJourneySummary() -> String {
        let patterns = getCookingPatterns()
        let completed = userDefaults.completedRecipes.count
        let favorites = fetchFavoriteRecipes().count
        let explored = userDefaults.exploredCategories.count
        
        return """
        🍳 Cooking Journey Summary:
        - Completed Recipes: \(completed)
        - Favorite Recipes: \(favorites) 
        - Categories Explored: \(explored)/8
        - Skill Level: \(patterns.skillProgression)
        - Cooking Frequency: \(patterns.cookingFrequency)
        - Preferred Difficulty: \(patterns.preferredComplexity)
        - Exploration Rate: \(String(format: "%.1f", patterns.explorationRate * 100))%
        """
    }
}

// MARK: - Extended UserDefaults for Behavior Tracking

extension UserDefaults {
    // Advanced tracking keys
    private enum BehaviorKeys {
        static let categoryPreferences = "categoryPreferences"
        static let difficultyProgression = "difficultyProgression"
        static let difficultyPreferences = "difficultyPreferences"
        static let cookingTimePreferences = "cookingTimePreferences"
        static let exploredCategories = "exploredCategories"
        static let sessionTimes = "sessionTimes"
        static let sessionDurations = "sessionDurations"
        static let lastSessionTime = "lastSessionTime"
        static let ignoredSuggestions = "ignoredSuggestions"
        static let successfulSuggestions = "successfulSuggestions"
    }
    
    var categoryPreferences: [String: Double] {
        get {
            if let data = data(forKey: BehaviorKeys.categoryPreferences),
               let dict = try? JSONDecoder().decode([String: Double].self, from: data) {
                return dict
            }
            return [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: BehaviorKeys.categoryPreferences)
            }
        }
    }
    
    var difficultyProgression: [String: Int] {
        get {
            if let data = data(forKey: BehaviorKeys.difficultyProgression),
               let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
                return dict
            }
            return [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: BehaviorKeys.difficultyProgression)
            }
        }
    }
    
    var difficultyPreferences: [String: Double] {
        get {
            if let data = data(forKey: BehaviorKeys.difficultyPreferences),
               let dict = try? JSONDecoder().decode([String: Double].self, from: data) {
                return dict
            }
            return [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: BehaviorKeys.difficultyPreferences)
            }
        }
    }
    
    var cookingTimePreferences: [String: Int] {
        get {
            if let data = data(forKey: BehaviorKeys.cookingTimePreferences),
               let dict = try? JSONDecoder().decode([String: Int].self, from: data) {
                return dict
            }
            return [:]
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                set(data, forKey: BehaviorKeys.cookingTimePreferences)
            }
        }
    }
    
    var exploredCategories: [String] {
        get { array(forKey: BehaviorKeys.exploredCategories) as? [String] ?? [] }
        set { set(newValue, forKey: BehaviorKeys.exploredCategories) }
    }
    
    var sessionTimes: [TimeInterval] {
        get { array(forKey: BehaviorKeys.sessionTimes) as? [TimeInterval] ?? [] }
        set { set(newValue, forKey: BehaviorKeys.sessionTimes) }
    }
    
    var sessionDurations: [TimeInterval] {
        get { array(forKey: BehaviorKeys.sessionDurations) as? [TimeInterval] ?? [] }
        set { set(newValue, forKey: BehaviorKeys.sessionDurations) }
    }
    
    var lastSessionTime: Date? {
        get { object(forKey: BehaviorKeys.lastSessionTime) as? Date }
        set { set(newValue, forKey: BehaviorKeys.lastSessionTime) }
    }
    
    var ignoredSuggestions: [String] {
        get { array(forKey: BehaviorKeys.ignoredSuggestions) as? [String] ?? [] }
        set { set(newValue, forKey: BehaviorKeys.ignoredSuggestions) }
    }
    
    var successfulSuggestions: [String] {
        get { array(forKey: BehaviorKeys.successfulSuggestions) as? [String] ?? [] }
        set { set(newValue, forKey: BehaviorKeys.successfulSuggestions) }
    }
}
