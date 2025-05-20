//
//  Constants.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI

/// Namespace for app-wide constants
enum Constants {
    /// UI-related dimensions and values
    enum UI {
        // Common dimensions
        static let standardPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let largePadding: CGFloat = 24
        
        // Corner radii
        static let smallCornerRadius: CGFloat = 8
        static let standardCornerRadius: CGFloat = 12
        static let largeCornerRadius: CGFloat = 16
        
        // Animation durations
        static let quickAnimation: Double = 0.2
        static let standardAnimation: Double = 0.3
        static let slowAnimation: Double = 0.5
        
        // Opacities
        static let disabledOpacity: Double = 0.6
        static let hoverOpacity: Double = 0.8
        
        // Shadow values
        static let standardShadowOpacity: Double = 0.1
        static let standardShadowRadius: CGFloat = 5
        static let standardShadowY: CGFloat = 2
        
        // Grid values
        static let gridMinimumWidth: CGFloat = 150
        static let gridItemSpacing: CGFloat = 16
        
        // Icon sizes
        static let smallIconSize: CGFloat = 16
        static let standardIconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 32
        static let extraLargeIconSize: CGFloat = 60
    }
    
    /// String literals and text used throughout the app
    enum Text {
        // Tab titles
        static let recipesTabTitle = "Recipes"
        static let categoriesTabTitle = "Categories"
        static let favoritesTabTitle = "Favorites"
        static let aboutTabTitle = "About"
        
        // Navigation titles
        static let appTitle = "Ghanaian Recipes"
        static let categoriesTitle = "Categories"
        static let favoritesTitle = "My Favorites"
        static let aboutTitle = "About Ayewam"
        
        // Recipe-related
        static let recipeMinutesAbbreviation = "min"
        static let servingsSingular = "serving"
        static let servingsPlural = "servings"
        static let noRecipesFound = "No recipes found"
        static let tryAdjustingFilters = "Try adjusting your filters or search terms"
        static let checkBackLater = "Check back later for new recipes"
        static let clearFilters = "Clear Filters"
        static let searchRecipesPrompt = "Search recipes"
        
        // Recipe detail view
        static let aboutThisDish = "About this dish"
        static let preparation = "Preparation"
        static let prepTime = "Prep Time"
        static let cookTime = "Cook Time"
        static let ingredients = "Ingredients"
        static let cookingInstructions = "Cooking Instructions"
        static let stepPrefix = "Step"
        static let overview = "Overview"
        static let steps = "Steps"
        static let categoryLabel = "Category:"
        static let regionLabel = "Region:"
        static let noIngredientsAvailable = "No ingredients available"
        static let noStepsAvailable = "No cooking steps available"
        
        // Favorites
        static let loadingFavorites = "Loading favorites..."
        static let noFavoritesYet = "No Favorites Yet"
        static let tapToAddFavorites = "Tap the heart icon on any recipe to add it to your favorites"
        static let removeFavorite = "Remove"
        
        // Categories
        static let exploreCategoriesSubtitle = "Explore Ghanaian cuisine through these traditional categories"
        static let loadingCategories = "Loading categories..."
        static let noCategoriesFound = "No Categories Found"
        static let checkBackForCategories = "Check back later for new categories"
        
        // About screen
        static let appTagline = "Authentic Ghanaian Recipes"
        static let aboutHeading = "About Ayewam"
        static let aboutDescription = "Ayewam is your guide to authentic Ghanaian cuisine, offering traditional recipes with step-by-step instructions. Explore the rich culinary heritage of Ghana through our carefully curated collection of dishes."
        static let aboutDescription2 = "Whether you're looking to prepare Jollof Rice, Light Soup, or other Ghanaian classics, Ayewam provides you with the knowledge and guidance to create authentic dishes at home."
        static let cuisineHeading = "Ghanaian Cuisine"
        static let cuisineDescription = "Ghanaian cuisine is known for its flavorful stews, soups, and one-pot dishes. Key ingredients include plantains, cassava, yams, corn, beans, and various proteins. Dishes are often seasoned with aromatic spices and herbs."
        static let versionLabel = "Version 1.0"
        static let copyrightNotice = "© 2025 Justyn Adusei-Prempeh"
        
        // Error messages
        static let genericErrorTitle = "Oops!"
        static let retryButtonLabel = "Try Again"
        static let failedToLoadRecipes = "We couldn't load your recipes. Please check your connection and try again."
    }
    
    /// Asset names and resource identifiers
    enum Assets {
        // Icon names
        static let recipeTabIcon = "book"
        static let categoriesTabIcon = "square.grid.2x2"
        static let favoritesTabIcon = "heart"
        static let aboutTabIcon = "info.circle"
        
        static let emptyFavoritesIcon = "heart.slash"
        static let emptyCategoriesIcon = "square.grid.2x2"
        static let defaultFoodIcon = "fork.knife"
        static let clockIcon = "clock"
        static let difficultyIcon = "speedometer"
        static let servingsIcon = "person.2"
        static let regionIcon = "mappin.and.ellipse"
        static let checkmarkIcon = "checkmark"
        static let favoriteFilledIcon = "heart.fill"
        static let favoriteOutlineIcon = "heart"
        static let searchIcon = "magnifyingglass"
        static let clearIcon = "xmark.circle.fill"
        static let photoPlaceholderIcon = "photo"
        static let bookClosedIcon = "text.book.closed"
        
        // Default category colors (hex)
        static let defaultCategoryColor = "#767676"
    }
    
    /// CoreData related constants
    enum Database {
        // Entity names
        static let recipeEntity = "Recipe"
        static let categoryEntity = "Category"
        static let ingredientEntity = "Ingredient"
        static let stepEntity = "Step"
        
        // Default sort descriptors
        static let recipeSortDescriptor = NSSortDescriptor(keyPath: \Recipe.name, ascending: true)
        static let categorySortDescriptor = NSSortDescriptor(keyPath: \Category.name, ascending: true)
        static let ingredientSortDescriptor = NSSortDescriptor(keyPath: \Ingredient.orderIndex, ascending: true)
        static let stepSortDescriptor = NSSortDescriptor(keyPath: \Step.orderIndex, ascending: true)
    }
    
    /// Timing and animation-related constants
    enum Timing {
        // Debounce durations
        static let searchDebounce: Double = 0.3
        
        // Loading simulation delays (for development)
        static let simulatedNetworkDelay: Double = 0.3
        
        // Duration-related formatting
        static func formatDuration(seconds: Int32) -> String {
            let minutes = seconds / 60
            return "\(minutes) \(Text.recipeMinutesAbbreviation)"
        }
    }
}
