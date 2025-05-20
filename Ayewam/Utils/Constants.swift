//
//  Constants.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

// Constants.swift with Localization Support

import SwiftUI

/// Namespace for app-wide constants
enum Constants {
    /// UI-related dimensions and values (no changes needed here)
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
    
    /// String literals and text used throughout the app - with localization support
    enum Text {
        // Helper method to get localized string
        private static func localized(_ key: String, comment: String = "") -> String {
            return NSLocalizedString(key, comment: comment)
        }
        
        // Tab titles
        static let recipesTabTitle = localized("recipesTabTitle", comment: "Title for recipes tab")
        static let categoriesTabTitle = localized("categoriesTabTitle", comment: "Title for categories tab")
        static let favoritesTabTitle = localized("favoritesTabTitle", comment: "Title for favorites tab")
        static let aboutTabTitle = localized("aboutTabTitle", comment: "Title for about tab")
        
        // Navigation titles
        static let appTitle = localized("appTitle", comment: "Main app title")
        static let categoriesTitle = localized("categoriesTitle", comment: "Title for categories screen")
        static let favoritesTitle = localized("favoritesTitle", comment: "Title for favorites screen")
        static let aboutTitle = localized("aboutTitle", comment: "Title for about screen")
        
        // Recipe-related
        static let recipeMinutesAbbreviation = localized("recipeMinutesAbbreviation", comment: "Abbreviation for minutes")
        static let servingsSingular = localized("servingsSingular", comment: "Label for a single serving")
        static let servingsPlural = localized("servingsPlural", comment: "Label for multiple servings")
        static let noRecipesFound = localized("noRecipesFound", comment: "Message when no recipes are found")
        static let tryAdjustingFilters = localized("tryAdjustingFilters", comment: "Message suggesting to adjust search filters")
        static let checkBackLater = localized("checkBackLater", comment: "Message suggesting to check back later for content")
        static let clearFilters = localized("clearFilters", comment: "Button to clear search filters")
        static let searchRecipesPrompt = localized("searchRecipesPrompt", comment: "Placeholder for recipe search field")
        
        // Recipe detail view
        static let aboutThisDish = localized("aboutThisDish", comment: "Heading for recipe description")
        static let preparation = localized("preparation", comment: "Heading for preparation section")
        static let prepTime = localized("prepTime", comment: "Label for preparation time")
        static let cookTime = localized("cookTime", comment: "Label for cooking time")
        static let ingredients = localized("ingredients", comment: "Label for ingredients section")
        static let cookingInstructions = localized("cookingInstructions", comment: "Label for cooking instructions")
        static let stepPrefix = localized("stepPrefix", comment: "Prefix for step number (e.g., 'Step 1')")
        static let overview = localized("overview", comment: "Label for overview tab")
        static let steps = localized("steps", comment: "Label for steps tab")
        static let categoryLabel = localized("categoryLabel", comment: "Label for category")
        static let regionLabel = localized("regionLabel", comment: "Label for region")
        static let noIngredientsAvailable = localized("noIngredientsAvailable", comment: "Message when no ingredients are available")
        static let noStepsAvailable = localized("noStepsAvailable", comment: "Message when no steps are available")
        
        // Favorites
        static let loadingFavorites = localized("loadingFavorites", comment: "Message when loading favorites")
        static let noFavoritesYet = localized("noFavoritesYet", comment: "Message when no favorites exist")
        static let tapToAddFavorites = localized("tapToAddFavorites", comment: "Instructions for adding favorites")
        static let removeFavorite = localized("removeFavorite", comment: "Button to remove from favorites")
        
        // Categories
        static let exploreCategoriesSubtitle = localized("exploreCategoriesSubtitle", comment: "Subtitle for categories screen")
        static let loadingCategories = localized("loadingCategories", comment: "Message when loading categories")
        static let noCategoriesFound = localized("noCategoriesFound", comment: "Message when no categories are found")
        static let checkBackForCategories = localized("checkBackForCategories", comment: "Message suggesting to check back for categories")
        
        // About screen
        static let appTagline = localized("appTagline", comment: "App tagline")
        static let aboutHeading = localized("aboutHeading", comment: "Heading for about section")
        static let aboutDescription = localized("aboutDescription", comment: "Description of the app")
        static let aboutDescription2 = localized("aboutDescription2", comment: "Additional description of the app")
        static let cuisineHeading = localized("cuisineHeading", comment: "Heading for Ghanaian cuisine section")
        static let cuisineDescription = localized("cuisineDescription", comment: "Description of Ghanaian cuisine")
        static let versionLabel = localized("versionLabel", comment: "Label for app version")
        static let copyrightNotice = localized("copyrightNotice", comment: "Copyright notice")
        
        // Error messages
        static let genericErrorTitle = localized("genericErrorTitle", comment: "Generic error title")
        static let retryButtonLabel = localized("retryButtonLabel", comment: "Label for retry button")
        static let failedToLoadRecipes = localized("failedToLoadRecipes", comment: "Message when recipes fail to load")
    }
    
    /// Enhanced localization helpers
    enum Localization {
        /// Returns appropriate plural form based on count
        static func pluralized(singular: String, plural: String, count: Int) -> String {
            return count == 1 ?
                NSLocalizedString(singular, comment: "Singular form") :
                NSLocalizedString(plural, comment: "Plural form")
        }
        
        /// Returns localized "serving" or "servings" based on count
        static func servings(count: Int) -> String {
            return pluralized(
                singular: "servingsSingular",
                plural: "servingsPlural",
                count: count
            )
        }
        
        /// Formats duration in seconds to minutes with localized unit
        static func formatDuration(seconds: Int32) -> String {
            let minutes = seconds / 60
            return "\(minutes) \(Text.recipeMinutesAbbreviation)"
        }
    }
    
    /// Asset names and resource identifiers (no changes needed here)
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
    
    /// CoreData related constants (no changes needed here)
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
    
    /// Timing and animation-related constants (no changes needed here)
    enum Timing {
        // Debounce durations
        static let searchDebounce: Double = 0.3
        
        // Loading simulation delays (for development)
        static let simulatedNetworkDelay: Double = 0.3
    }
}
