//
//  MockData.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData
import SwiftUI

/// Provides mock data for previews and testing
struct MockData {
    /// Create and return a preview recipe with all relationships
    static func previewRecipe(in context: NSManagedObjectContext) -> Recipe {
        let existingRecipe = try? context.fetch(Recipe.fetchRequest()).first
        
        if let existing = existingRecipe {
            return existing
        }
        
        // Create a new mock recipe if none exists
        let recipe = Recipe(context: context)
        recipe.id = "jollof_rice_preview"
        recipe.name = "Jollof Rice"
        recipe.recipeDescription = "A one-pot rice dish popular throughout West Africa, with a distinct Ghanaian preparation style."
        recipe.prepTime = 15
        recipe.cookTime = 45
        recipe.servings = 6
        recipe.difficulty = "Medium"
        recipe.region = "Nationwide"
        recipe.imageName = "jollof_rice"
        recipe.isFavorite = true
        
        // Add a category
        let category = previewCategory(in: context)
        recipe.category = category
        
        // Add ingredients
        addIngredientsToRecipe(recipe, in: context)
        
        // Add steps
        addStepsToRecipe(recipe, in: context)
        
        return recipe
    }
    
    /// Create a collection of preview recipes
    static func previewRecipes(count: Int = 5, in context: NSManagedObjectContext) -> [Recipe] {
        // Check if we already have recipes
        let existingRecipes = try? context.fetch(Recipe.fetchRequest())
        if let existing = existingRecipes, existing.count >= count {
            return Array(existing.prefix(count))
        }
        
        // Otherwise create new recipes
        var recipes: [Recipe] = []
        let categories = previewCategories(in: context)
        
        let names = ["Jollof Rice", "Light Soup", "Red Red", "Waakye", "Kelewele", "Banku and Tilapia", "Fufu and Palm Nut Soup"]
        let descriptions = [
            "A one-pot rice dish popular throughout West Africa.",
            "A clear, light broth made with meat and vegetables.",
            "A popular Ghanaian dish made with black-eyed peas and plantains.",
            "Rice and beans cooked together, often served with stew.",
            "Spicy fried plantains, a popular street food.",
            "Fermented corn and cassava dough served with grilled tilapia.",
            "Pounded cassava and plantain with rich palm nut soup."
        ]
        let difficulties = ["Easy", "Medium", "Hard"]
        let regions = ["Greater Accra", "Ashanti", "Central", "Northern", "Nationwide"]
        
        for i in 0..<count {
            let recipe = Recipe(context: context)
            recipe.id = "recipe_\(i)"
            recipe.name = i < names.count ? names[i] : "Ghanaian Recipe \(i + 1)"
            recipe.recipeDescription = i < descriptions.count ? descriptions[i] : "A delicious traditional Ghanaian dish."
            recipe.prepTime = Int32.random(in: 10...30)
            recipe.cookTime = Int32.random(in: 15...90)
            recipe.servings = Int16.random(in: 2...8)
            recipe.difficulty = difficulties.randomElement() ?? "Medium"
            recipe.region = regions.randomElement() ?? "Nationwide"
            recipe.imageName = "recipe_\(i)"
            recipe.isFavorite = Bool.random()
            
            // Assign a random category
            recipe.category = categories.randomElement()
            
            // Add ingredients and steps
            addIngredientsToRecipe(recipe, in: context)
            addStepsToRecipe(recipe, in: context)
            
            recipes.append(recipe)
        }
        
        return recipes
    }
    
    /// Create and return a preview category
    static func previewCategory(in context: NSManagedObjectContext) -> Category {
        let existingCategory = try? context.fetch(Category.fetchRequest()).first
        
        if let existing = existingCategory {
            return existing
        }
        
        let category = Category(context: context)
        category.name = "Rice Dishes"
        category.colorHex = "#FCD116" // Ghanaian flag yellow
        category.imageName = "category_rice"
        
        return category
    }
    
    /// Create a collection of preview categories
    static func previewCategories(in context: NSManagedObjectContext) -> [Category] {
        // Check if we already have categories
        let existingCategories = try? context.fetch(Category.fetchRequest())
        if let existing = existingCategories, !existing.isEmpty {
            return existing
        }
        
        // Category data
        let categoryData: [(name: String, color: String, image: String)] = [
            ("Soups", "#E57373", "category_soups"),
            ("Stews", "#FFB74D", "category_stews"),
            ("Rice Dishes", "#FFF176", "category_rice"),
            ("Street Food", "#81C784", "category_street"),
            ("Breakfast", "#4FC3F7", "category_breakfast"),
            ("Desserts", "#BA68C8", "category_desserts"),
            ("Drinks", "#4DB6AC", "category_drinks"),
            ("Sides", "#A1887F", "category_sides")
        ]
        
        // Create categories
        var categories: [Category] = []
        
        for data in categoryData {
            let category = Category(context: context)
            category.name = data.name
            category.colorHex = data.color
            category.imageName = data.image
            categories.append(category)
        }
        
        return categories
    }
    
    /// Add ingredients to a recipe
    private static func addIngredientsToRecipe(_ recipe: Recipe, in context: NSManagedObjectContext) {
        // Common ingredient groups based on recipe name
        let ingredientGroups: [String: [(name: String, quantity: Double, unit: String, notes: String?)]] = [
            "Jollof Rice": [
                ("Long grain rice", 3, "cups", "Washed and drained"),
                ("Vegetable oil", 0.25, "cup", nil),
                ("Onions", 2, "medium", "Finely chopped"),
                ("Tomato paste", 2, "tablespoons", nil),
                ("Canned tomatoes", 400, "g", "Or 4 fresh tomatoes, blended"),
                ("Chicken stock", 3, "cups", "Or vegetable stock"),
                ("Bay leaves", 2, "", nil),
                ("Curry powder", 1, "teaspoon", nil),
                ("Thyme", 0.5, "teaspoon", "Dried"),
                ("Salt", 1, "to taste", nil)
            ],
            "Light Soup": [
                ("Goat meat or chicken", 500, "g", "Cut into pieces"),
                ("Onion", 1, "medium", "Chopped"),
                ("Tomatoes", 2, "medium", "Chopped"),
                ("Ginger", 1, "thumb-sized", "Grated"),
                ("Garlic", 2, "cloves", "Minced"),
                ("Chili pepper", 1, "small", "Or to taste"),
                ("Water", 1.5, "liters", nil),
                ("Salt", 1, "to taste", nil)
            ]
        ]
        
        // Default ingredients if no specific set matches
        let defaultIngredients: [(name: String, quantity: Double, unit: String, notes: String?)] = [
            ("Main ingredient", 500, "g", "Prepared as needed"),
            ("Onion", 1, "medium", "Chopped"),
            ("Tomatoes", 2, "medium", "Chopped"),
            ("Cooking oil", 2, "tablespoons", nil),
            ("Salt", 1, "to taste", nil),
            ("Pepper", 0.5, "teaspoon", "Ground"),
            ("Water", 2, "cups", nil)
        ]
        
        // Select ingredient list based on recipe name, or use default
        let ingredients = ingredientGroups[recipe.name ?? ""] ?? defaultIngredients
        
        // Create ingredients
        for (index, ingData) in ingredients.enumerated() {
            let ingredient = Ingredient(context: context)
            ingredient.name = ingData.name
            ingredient.quantity = ingData.quantity
            ingredient.unit = ingData.unit
            ingredient.notes = ingData.notes
            ingredient.orderIndex = Int16(index)
            ingredient.recipe = recipe
        }
    }
    
    /// Add cooking steps to a recipe
    private static func addStepsToRecipe(_ recipe: Recipe, in context: NSManagedObjectContext) {
        // Step groups based on recipe name
        let stepGroups: [String: [(instruction: String, duration: Int32, image: String?)]] = [
            "Jollof Rice": [
                ("Heat oil in a large pot over medium heat. Add onions and sauté until translucent.", 300, "jollof_step1"),
                ("Add tomato paste and stir for 2-3 minutes until it darkens slightly.", 180, "jollof_step2"),
                ("Add canned tomatoes, curry powder, thyme, bay leaves, and salt. Simmer for 5 minutes.", 300, "jollof_step3"),
                ("Add the washed rice and stir to coat with the sauce.", 60, "jollof_step4"),
                ("Pour in the stock, stir once, and bring to a boil.", 300, "jollof_step5"),
                ("Reduce heat to low, cover the pot with foil and then the lid to trap steam.", 30, "jollof_step6"),
                ("Cook for 30 minutes or until rice is tender. Fluff with a fork before serving.", 1800, "jollof_step7")
            ],
            "Light Soup": [
                ("In a pot, boil the meat with salt, half the onion, and a little ginger until tender.", 1800, "light_soup_step1"),
                ("In a blender, blend the remaining onion, tomatoes, ginger, garlic, and chili pepper.", 120, "light_soup_step2"),
                ("Add the blended mixture to the pot with the meat and bring to a boil.", 300, "light_soup_step3"),
                ("Reduce heat and simmer for 15-20 minutes until the flavors meld.", 1200, "light_soup_step4"),
                ("Adjust seasoning to taste and serve hot with fufu or rice balls.", 60, "light_soup_step5")
            ]
        ]
        
        // Default steps if no specific set matches
        let defaultSteps: [(instruction: String, duration: Int32, image: String?)] = [
            ("Prepare all ingredients, washing and chopping as needed.", 600, nil),
            ("Heat cooking oil in a pot over medium heat.", 120, nil),
            ("Add onions and sauté until translucent.", 180, nil),
            ("Add remaining ingredients and stir well.", 120, nil),
            ("Cook until all ingredients are properly cooked through.", 1200, nil),
            ("Serve hot and enjoy your Ghanaian dish!", 60, nil)
        ]
        
        // Select step list based on recipe name, or use default
        let steps = stepGroups[recipe.name ?? ""] ?? defaultSteps
        
        // Create steps
        for (index, stepData) in steps.enumerated() {
            let step = Step(context: context)
            step.instruction = stepData.instruction
            step.duration = stepData.duration
            step.imageName = stepData.image
            step.orderIndex = Int16(index)
            step.recipe = recipe
        }
    }
    
    /// Create a preview view context with sample data
    static func previewContext() -> NSManagedObjectContext {
        let context = PersistenceController.preview.container.viewContext
        
        // Create sample data if needed
        _ = previewCategories(in: context)
        _ = previewRecipes(count: 5, in: context)
        
        return context
    }
    
    /// Create a mock recipe manager for previews
    static func mockRecipeManager() -> RecipeManager {
        let context = previewContext()
        return RecipeManager(context: context)
    }

    /// Create a mock view model with sample data for previews
    static func mockRecipeViewModel() -> RecipeViewModel {
        let context = previewContext()
        let manager = mockRecipeManager()
        return RecipeViewModel(
            repository: RecipeRepository(context: context),
            manager: manager
        )
    }

    /// Create a mock category view model with sample data for previews
    static func mockCategoryViewModel() -> CategoryViewModel {
        let context = previewContext()
        let manager = mockRecipeManager()
        return CategoryViewModel(
            repository: CategoryRepository(context: context),
            manager: manager
        )
    }

    /// Create a mock favorite view model with sample data for previews
    static func mockFavoriteViewModel() -> FavoriteViewModel {
        let context = previewContext()
        let manager = mockRecipeManager()
        return FavoriteViewModel(
            repository: RecipeRepository(context: context),
            manager: manager
        )
    }
}

// MARK: - SwiftUI Preview Extensions
extension PreviewProvider {
    /// A convenience method for accessing a preview context with sample data
    static var previewContext: NSManagedObjectContext {
        return MockData.previewContext()
    }
}
