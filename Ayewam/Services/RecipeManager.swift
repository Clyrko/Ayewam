//
//  RecipeManager.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

// RecipeManager.swift

import Foundation
import CoreData
import Combine

/// Service class for managing recipe operations
class RecipeManager {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private let recipeRepository: RecipeRepository
    private let categoryRepository: CategoryRepository
    
    /// Published events for recipe changes
    var recipeChangedPublisher = PassthroughSubject<Recipe, Never>()
    var favoriteChangedPublisher = PassthroughSubject<Recipe, Never>()
    
    // MARK: - Initialization
    init(context: NSManagedObjectContext) {
        self.context = context
        self.recipeRepository = RecipeRepository(context: context)
        self.categoryRepository = CategoryRepository(context: context)
    }
    
    // MARK: - Shared Instance
    static let shared = RecipeManager(context: PersistenceController.shared.container.viewContext)
    
    // MARK: - Recipe Operations
    
    /// Fetches recipes with optional filtering
    func fetchRecipes(category: Category? = nil, searchText: String? = nil) -> [Recipe] {
        return recipeRepository.fetchRecipes(category: category, searchText: searchText)
    }
    
    /// Fetch recipes with advanced filtering options
    func fetchRecipes(filtering: RecipeFiltering) -> [Recipe] {
        return filtering.apply(to: recipeRepository)
    }
    
    /// Fetches a single recipe by ID
    func fetchRecipe(withID id: String) -> Recipe? {
        return recipeRepository.fetchRecipe(withID: id)
    }
    
    /// Fetches favorite recipes
    func fetchFavoriteRecipes() -> [Recipe] {
        return recipeRepository.fetchFavoriteRecipes()
    }
    
    /// Toggles the favorite status of a recipe
    func toggleFavorite(_ recipe: Recipe) throws {
        try recipeRepository.toggleFavorite(recipe)
        favoriteChangedPublisher.send(recipe)
    }
    
    // MARK: - Category Operations
    
    /// Fetches all categories
    func fetchCategories() -> [Category] {
        return categoryRepository.fetchCategories()
    }
    
    /// Fetches a category by name
    func fetchCategory(withName name: String) -> Category? {
        return categoryRepository.fetchCategory(withName: name)
    }
    
    /// Fetches recipes for a specific category
    func fetchRecipes(forCategory category: Category) -> [Recipe] {
        guard let recipes = category.recipes as? Set<Recipe> else { return [] }
        return recipes.sorted { ($0.name ?? "") < ($1.name ?? "") }
    }
    
    /// Returns the number of recipes in a category
    func recipeCount(forCategory category: Category) -> Int {
        return category.recipes?.count ?? 0
    }
    
    // MARK: - Sorting & Filtering
    
    /// Sorts recipes by the specified criteria
    func sortRecipes(_ recipes: [Recipe], by sortOption: RecipeSortOption) -> [Recipe] {
        switch sortOption {
        case .nameAscending:
            return recipes.sorted { ($0.name ?? "") < ($1.name ?? "") }
        case .nameDescending:
            return recipes.sorted { ($0.name ?? "") > ($1.name ?? "") }
        case .prepTimeAscending:
            return recipes.sorted { $0.prepTime < $1.prepTime }
        case .prepTimeDescending:
            return recipes.sorted { $0.prepTime > $1.prepTime }
        case .cookTimeAscending:
            return recipes.sorted { $0.cookTime < $1.cookTime }
        case .cookTimeDescending:
            return recipes.sorted { $0.cookTime > $1.cookTime }
        case .totalTimeAscending:
            return recipes.sorted { ($0.prepTime + $0.cookTime) < ($1.prepTime + $1.cookTime) }
        case .totalTimeDescending:
            return recipes.sorted { ($0.prepTime + $0.cookTime) > ($1.prepTime + $1.cookTime) }
        }
    }
    
    /// Filters recipes by difficulty level
    func filterRecipesByDifficulty(_ recipes: [Recipe], difficulty: String?) -> [Recipe] {
        guard let difficulty = difficulty, !difficulty.isEmpty else { return recipes }
        return recipes.filter { $0.difficulty == difficulty }
    }
    
    /// Filters recipes by region
    func filterRecipesByRegion(_ recipes: [Recipe], region: String?) -> [Recipe] {
        guard let region = region, !region.isEmpty else { return recipes }
        return recipes.filter { $0.region == region }
    }
    
    /// Returns available difficulty levels from recipes
    func availableDifficultyLevels() -> [String] {
        let recipes = recipeRepository.fetchRecipes()
        let difficulties = recipes.compactMap { $0.difficulty }
        return Array(Set(difficulties)).sorted()
    }
    
    /// Returns available regions from recipes
    func availableRegions() -> [String] {
        let recipes = recipeRepository.fetchRecipes()
        let regions = recipes.compactMap { $0.region }
        return Array(Set(regions)).sorted()
    }
}

// MARK: - Supporting Types

/// Options for sorting recipes
enum RecipeSortOption {
    case nameAscending
    case nameDescending
    case prepTimeAscending
    case prepTimeDescending
    case cookTimeAscending
    case cookTimeDescending
    case totalTimeAscending
    case totalTimeDescending
    
    var description: String {
        switch self {
        case .nameAscending: return "Name (A-Z)"
        case .nameDescending: return "Name (Z-A)"
        case .prepTimeAscending: return "Prep Time (Shortest)"
        case .prepTimeDescending: return "Prep Time (Longest)"
        case .cookTimeAscending: return "Cook Time (Shortest)"
        case .cookTimeDescending: return "Cook Time (Longest)"
        case .totalTimeAscending: return "Total Time (Shortest)"
        case .totalTimeDescending: return "Total Time (Longest)"
        }
    }
}

/// Structure for advanced recipe filtering
struct RecipeFiltering {
    var category: Category?
    var searchText: String?
    var difficulty: String?
    var region: String?
    var maxPrepTime: Int32?
    var maxCookTime: Int32?
    var favorite: Bool?
    var sortOption: RecipeSortOption = .nameAscending
    
    func apply(to repository: RecipeRepository) -> [Recipe] {
        // Start with basic filtering
        var recipes = repository.fetchRecipes(category: category, searchText: searchText)
        
        // Apply additional filters
        if let difficulty = difficulty, !difficulty.isEmpty {
            recipes = recipes.filter { $0.difficulty == difficulty }
        }
        
        if let region = region, !region.isEmpty {
            recipes = recipes.filter { $0.region == region }
        }
        
        if let maxPrepTime = maxPrepTime {
            recipes = recipes.filter { $0.prepTime <= maxPrepTime }
        }
        
        if let maxCookTime = maxCookTime {
            recipes = recipes.filter { $0.cookTime <= maxCookTime }
        }
        
        if let favorite = favorite {
            recipes = recipes.filter { $0.isFavorite == favorite }
        }
        
        // Apply sorting
        switch sortOption {
        case .nameAscending:
            recipes.sort { ($0.name ?? "") < ($1.name ?? "") }
        case .nameDescending:
            recipes.sort { ($0.name ?? "") > ($1.name ?? "") }
        case .prepTimeAscending:
            recipes.sort { $0.prepTime < $1.prepTime }
        case .prepTimeDescending:
            recipes.sort { $0.prepTime > $1.prepTime }
        case .cookTimeAscending:
            recipes.sort { $0.cookTime < $1.cookTime }
        case .cookTimeDescending:
            recipes.sort { $0.cookTime > $1.cookTime }
        case .totalTimeAscending:
            recipes.sort { ($0.prepTime + $0.cookTime) < ($1.prepTime + $1.cookTime) }
        case .totalTimeDescending:
            recipes.sort { ($0.prepTime + $0.cookTime) > ($1.prepTime + $1.cookTime) }
        }
        
        return recipes
    }
}
