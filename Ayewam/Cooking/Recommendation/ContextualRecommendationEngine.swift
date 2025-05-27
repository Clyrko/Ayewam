//
//  ContextualRecommendationEngine.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/23/25.
//

import Foundation
import CoreData
import Combine

// MARK: - Recommendation Models

struct RecommendationSection {
    let title: String
    let subtitle: String?
    let recipes: [Recipe]
    let reasoning: String
    let sectionType: RecommendationType
}

enum RecommendationType {
    case timeBased
    case favoriteExpansion
    case skillProgression
    case culturalContext
    case seasonal
    case quickAndEasy
}

// MARK: - Core Recommendation Engine

class ContextualRecommendationEngine: ObservableObject {
    private let context: NSManagedObjectContext
    
    // Published properties for reactive UI updates
    @Published var isLoading = false
    @Published var lastUpdateTime = Date()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Main Recommendation Method
    
    /// Returns organized recommendation sections based on current context
    func getRecommendations() -> [RecommendationSection] {
        var sections: [RecommendationSection] = []
        
        // Get all available recipes for filtering
        let allRecipes = fetchAllRecipes()
        guard !allRecipes.isEmpty else { return [] }
        
        // Generate different types of recommendations
        if let timeBasedSection = getTimeBasedSection(from: allRecipes) {
            sections.append(timeBasedSection)
        }
        
        if let favoriteSection = getFavoriteExpansionSection(from: allRecipes) {
            sections.append(favoriteSection)
        }
        
        if let skillSection = getSkillProgressionSection(from: allRecipes) {
            sections.append(skillSection)
        }
        
        if let culturalSection = getCulturalContextSection(from: allRecipes) {
            sections.append(culturalSection)
        }
        
        return sections
    }
    
    // MARK: - Time-Based Recommendations
    
    private func getTimeBasedSection(from recipes: [Recipe]) -> RecommendationSection? {
        let hour = Calendar.current.component(.hour, from: Date())
        let isWeekend = Calendar.current.isDateInWeekend(Date())
        
        let (title, subtitle, reasoning, suggestedRecipes) = getTimeBasedSuggestions(
            hour: hour,
            isWeekend: isWeekend,
            from: recipes
        )
        
        guard !suggestedRecipes.isEmpty else { return nil }
        
        return RecommendationSection(
            title: title,
            subtitle: subtitle,
            recipes: Array(suggestedRecipes.prefix(5)),
            reasoning: reasoning,
            sectionType: .timeBased
        )
    }
    
    private func getTimeBasedSuggestions(hour: Int, isWeekend: Bool, from recipes: [Recipe]) -> (String, String?, String, [Recipe]) {
        switch hour {
        case 5...11:
            // Morning suggestions
            let timeLimit = isWeekend ? 45 : 20 // More time on weekends
            let filtered = recipes.filter { recipe in
                let totalTime = recipe.prepTime + recipe.cookTime
                return totalTime <= timeLimit &&
                       (recipe.name?.localizedCaseInsensitiveContains("koko") == true ||
                        recipe.name?.localizedCaseInsensitiveContains("porridge") == true ||
                        recipe.name?.localizedCaseInsensitiveContains("tea") == true ||
                        recipe.name?.localizedCaseInsensitiveContains("bread") == true ||
                        recipe.name?.localizedCaseInsensitiveContains("bofrot") == true ||
                        totalTime <= 30)
            }
            
            let title = isWeekend ? "Perfect for Weekend Morning" : "Quick Breakfast Ideas"
            let subtitle = isWeekend ? "Start your weekend with something special" : "Ready in under 20 minutes"
            let reasoning = "Selected based on current time (\(formatHour(hour))) and typical morning cooking preferences."
            
            return (title, subtitle, reasoning, filtered)
            
        case 12...17:
            // Afternoon/Lunch suggestions
            let timeLimit = isWeekend ? 60 : 35
            let filtered = recipes.filter { recipe in
                let totalTime = recipe.prepTime + recipe.cookTime
                return totalTime > 20 && totalTime <= timeLimit &&
                       (recipe.name?.localizedCaseInsensitiveContains("rice") == true ||
                        recipe.name?.localizedCaseInsensitiveContains("waakye") == true ||
                        recipe.name?.localizedCaseInsensitiveContains("jollof") == true ||
                        recipe.difficulty == "Easy" || recipe.difficulty == "Medium")
            }
            
            let title = isWeekend ? "Weekend Lunch Specials" : "Satisfying Lunch Options"
            let subtitle = isWeekend ? "Perfect for a relaxed weekend meal" : "Filling and not too heavy"
            let reasoning = "Moderate preparation time dishes suitable for midday cooking."
            
            return (title, subtitle, reasoning, filtered)
            
        case 18...22:
            // Evening/Dinner suggestions
            let filtered = recipes.filter { recipe in
                return recipe.name?.localizedCaseInsensitiveContains("soup") == true ||
                       recipe.name?.localizedCaseInsensitiveContains("stew") == true ||
                       recipe.name?.localizedCaseInsensitiveContains("light soup") == true ||
                       recipe.name?.localizedCaseInsensitiveContains("palm nut") == true ||
                       recipe.name?.localizedCaseInsensitiveContains("groundnut") == true ||
                       (recipe.cookTime >= 30 && recipe.difficulty != "Hard")
            }
            
            let title = "Traditional Evening Meals"
            let subtitle = "Hearty dishes perfect for dinner"
            let reasoning = "Traditional Ghanaian dinner dishes that bring family together."
            
            return (title, subtitle, reasoning, filtered)
            
        default:
            // Late night - quick and simple
            let filtered = recipes.filter { recipe in
                let totalTime = recipe.prepTime + recipe.cookTime
                return totalTime <= 25 &&
                       (recipe.name?.localizedCaseInsensitiveContains("kelewele") == true ||
                        recipe.name?.localizedCaseInsensitiveContains("plantain") == true ||
                        recipe.difficulty == "Easy")
            }
            
            let title = "Quick Late Night Bites"
            let subtitle = "Simple and satisfying"
            let reasoning = "Easy-to-make dishes perfect for late evening cooking."
            
            return (title, subtitle, reasoning, filtered)
        }
    }
    
    // MARK: - Favorite-Based Expansion
    
    private func getFavoriteExpansionSection(from recipes: [Recipe]) -> RecommendationSection? {
        let favoriteRecipes = recipes.filter { $0.isFavorite }
        
        guard !favoriteRecipes.isEmpty else { return nil }
        
        // Analyze favorite patterns
        let favoriteCategories = Set(favoriteRecipes.compactMap { $0.categoryObject })
        let favoriteDifficulties = Set(favoriteRecipes.compactMap { $0.difficulty })
        let averageCookTime = favoriteRecipes.map { $0.prepTime + $0.cookTime }.reduce(0, +) / Int32(favoriteRecipes.count)
        
        // Find similar recipes that aren't favorited
        let suggestions = recipes.filter { recipe in
            guard !recipe.isFavorite else { return false }
            
            // Check if recipe matches favorite patterns
            let categoryMatch = favoriteCategories.contains { category in
                recipe.categoryArray.contains(category)
            }
            
            let difficultyMatch = favoriteDifficulties.contains(recipe.difficulty ?? "")
            
            let timeMatch = abs((recipe.prepTime + recipe.cookTime) - averageCookTime) <= 15
            
            return categoryMatch || difficultyMatch || timeMatch
        }
        
        guard !suggestions.isEmpty else { return nil }
        
        return RecommendationSection(
            title: "More Like Your Favorites",
            subtitle: "Based on recipes you've saved",
            recipes: Array(suggestions.prefix(5)),
            reasoning: "Suggested because they match the categories, difficulty levels, or cooking times of your favorite recipes.",
            sectionType: .favoriteExpansion
        )
    }
    
    // MARK: - Skill Progression
    
    private func getSkillProgressionSection(from recipes: [Recipe]) -> RecommendationSection? {
        let completedRecipes = UserDefaults.standard.completedRecipes
        let completedDifficulties = completedRecipes.compactMap { recipeId in
            recipes.first { $0.id == recipeId }?.difficulty
        }
        
        let nextDifficulty = determineNextSkillLevel(from: completedDifficulties)
        
        let skillSuggestions = recipes.filter { recipe in
            guard !completedRecipes.contains(recipe.id ?? "") else { return false }
            return recipe.difficulty == nextDifficulty
        }
        
        guard !skillSuggestions.isEmpty else { return nil }
        
        let (title, subtitle) = getSkillProgressionTitle(
            currentLevel: nextDifficulty,
            completedCount: completedRecipes.count
        )
        
        return RecommendationSection(
            title: title,
            subtitle: subtitle,
            recipes: Array(skillSuggestions.prefix(4)),
            reasoning: "Suggested to help you progress your cooking skills at a comfortable pace.",
            sectionType: .skillProgression
        )
    }
    
    private func determineNextSkillLevel(from completedDifficulties: [String]) -> String {
        let easyCount = completedDifficulties.filter { $0 == "Easy" }.count
        let mediumCount = completedDifficulties.filter { $0 == "Medium" }.count
        let hardCount = completedDifficulties.filter { $0 == "Hard" }.count
        
        // Progression logic: Easy -> Medium -> Hard
        if easyCount < 3 || hardCount > mediumCount {
            return "Easy"
        } else if mediumCount < 5 || easyCount < mediumCount * 2 {
            return "Medium"
        } else {
            return "Hard"
        }
    }
    
    private func getSkillProgressionTitle(currentLevel: String, completedCount: Int) -> (String, String) {
        switch currentLevel {
        case "Easy":
            return ("Master the Basics", "Build confidence with these fundamentals")
        case "Medium":
            return ("Ready for More Challenge", "Take your skills to the next level")
        case "Hard":
            return ("Advanced Techniques", "Master traditional Ghanaian cooking")
        default:
            return ("Continue Learning", "Keep building your cooking skills")
        }
    }
    
    // MARK: - Cultural Context
    
    private func getCulturalContextSection(from recipes: [Recipe]) -> RecommendationSection? {
        let isWeekend = Calendar.current.isDateInWeekend(Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        
        if isWeekend {
            return getWeekendCulturalSuggestions(from: recipes)
        } else {
            return getWeekdayCulturalSuggestions(from: recipes, month: currentMonth)
        }
    }
    
    private func getWeekendCulturalSuggestions(from recipes: [Recipe]) -> RecommendationSection? {
        // Weekend: Family cooking, elaborate dishes, traditional preparations
        let weekendSuggestions = recipes.filter { recipe in
            let totalTime = recipe.prepTime + recipe.cookTime
            return totalTime >= 45 || // More elaborate dishes
                   recipe.name?.localizedCaseInsensitiveContains("banku") == true ||
                   recipe.name?.localizedCaseInsensitiveContains("fufu") == true ||
                   recipe.name?.localizedCaseInsensitiveContains("palm nut") == true ||
                   recipe.name?.localizedCaseInsensitiveContains("groundnut") == true ||
                   recipe.servings >= 4 // Family-sized portions
        }
        
        guard !weekendSuggestions.isEmpty else { return nil }
        
        return RecommendationSection(
            title: "Traditional Weekend Cooking",
            subtitle: "Perfect for family time and relaxed cooking",
            recipes: Array(weekendSuggestions.prefix(4)),
            reasoning: "Weekend dishes that bring family together and celebrate Ghanaian cooking traditions.",
            sectionType: .culturalContext
        )
    }
    
    private func getWeekdayCulturalSuggestions(from recipes: [Recipe], month: Int) -> RecommendationSection? {
        // Weekday: Practical, efficient, still authentic
        let weekdaySuggestions = recipes.filter { recipe in
            let totalTime = recipe.prepTime + recipe.cookTime
            return totalTime <= 45 &&
                   recipe.difficulty != "Hard" &&
                   (recipe.name?.localizedCaseInsensitiveContains("jollof") == true ||
                    recipe.name?.localizedCaseInsensitiveContains("waakye") == true ||
                    recipe.name?.localizedCaseInsensitiveContains("kelewele") == true ||
                    recipe.name?.localizedCaseInsensitiveContains("red red") == true)
        }
        
        guard !weekdaySuggestions.isEmpty else { return nil }
        
        return RecommendationSection(
            title: "Practical Weekday Dishes",
            subtitle: "Authentic flavors without the weekend time commitment",
            recipes: Array(weekdaySuggestions.prefix(4)),
            reasoning: "Traditional Ghanaian dishes adapted for busy weekday schedules.",
            sectionType: .culturalContext
        )
    }
    
    // MARK: - Helper Methods
    
    public func fetchAllRecipes() -> [Recipe] {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching recipes for recommendations: \(error)")
            return []
        }
    }
    
    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h a"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
}

// MARK: - UserDefaults Extension for Simple Tracking

extension UserDefaults {
    private enum Keys {
        static let completedRecipes = "completedRecipes"
        static let recentlyViewedRecipes = "recentlyViewedRecipes"
        static let lastCookingSession = "lastCookingSession"
        static let preferredCookingTimeSlots = "preferredCookingTimeSlots"
    }
    
    var completedRecipes: [String] {
        get { array(forKey: Keys.completedRecipes) as? [String] ?? [] }
        set { set(newValue, forKey: Keys.completedRecipes) }
    }
    
    var recentlyViewedRecipes: [String] {
        get {
            let recent = array(forKey: Keys.recentlyViewedRecipes) as? [String] ?? []
            return Array(recent.prefix(20)) // Keep only last 20
        }
        set {
            let limited = Array(newValue.prefix(20))
            set(limited, forKey: Keys.recentlyViewedRecipes)
        }
    }
    
    var lastCookingSession: Date? {
        get { object(forKey: Keys.lastCookingSession) as? Date }
        set { set(newValue, forKey: Keys.lastCookingSession) }
    }
    
    var preferredCookingTimeSlots: [Int] {
        get { array(forKey: Keys.preferredCookingTimeSlots) as? [Int] ?? [] }
        set { set(newValue, forKey: Keys.preferredCookingTimeSlots) }
    }
    
    // Helper methods for tracking
    func addCompletedRecipe(_ recipeId: String) {
        var completed = completedRecipes
        if !completed.contains(recipeId) {
            completed.append(recipeId)
            completedRecipes = completed
        }
    }
    
    func addRecentlyViewedRecipe(_ recipeId: String) {
            var recent = stringArray(forKey: "recentlyViewedRecipes") ?? []
            // Remove if already exists
            recent.removeAll { $0 == recipeId }
            // Add to front
            recent.insert(recipeId, at: 0)
            // Keep only last 10
            recent = Array(recent.prefix(10))
            
            set(recent, forKey: "recentlyViewedRecipes")
        }
}
