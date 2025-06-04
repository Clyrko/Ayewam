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
    
    // MARK: - Typography (NEW - Centralized)
    /// Typography system integration
    enum Typography {
        static let heroTitle = Ayewam.Typography.displayLarge
        static let sectionTitle = Ayewam.Typography.displaySmall
        static let cardTitle = Ayewam.Typography.headingMedium
        static let bodyText = Ayewam.Typography.bodyMedium
        static let buttonText = Ayewam.Typography.labelLarge
        static let metadata = Ayewam.Typography.caption
        static let timer = Ayewam.Typography.timerLarge
        static let cultural = Ayewam.Typography.cultural
        
        static func adaptiveSize(for baseSize: CGFloat) -> CGFloat {
            if AccessibilityTypography.prefersLargerText {
                return baseSize * 1.2
            }
            return baseSize
        }
    }
    
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
        static var smallIconSize: CGFloat { Typography.adaptiveSize(for: 16) }
        static var standardIconSize: CGFloat { Typography.adaptiveSize(for: 24) }
        static var largeIconSize: CGFloat { Typography.adaptiveSize(for: 32) }
        static var extraLargeIconSize: CGFloat { Typography.adaptiveSize(for: 60) }
        
        // Touch targets
        static let minimumTouchTarget: CGFloat = AccessibilityTypography.minimumTouchTarget
        static let comfortableTouchTarget: CGFloat = 48
        static let largeTouchTarget: CGFloat = 56
        
        // Recipe Submission UI
        static let submissionCardCornerRadius: CGFloat = 24
        static let notificationCornerRadius: CGFloat = 20
        static let toastDuration: Double = 4.0
        static let submissionFormPadding: CGFloat = 20
        static let characterLimit: Int = 500
        static let dailySubmissionLimit: Int = 5
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
        
        // Recipe Submission
        static let suggestRecipe = localized("suggestRecipe", comment: "Button to suggest a recipe")
        static let recipeSubmissionTitle = localized("recipeSubmissionTitle", comment: "Title for recipe submission form")
        static let recipeSubmissionDescription = localized("recipeSubmissionDescription", comment: "Description for recipe submission feature")
        static let recipeName = localized("recipeName", comment: "Label for recipe name field")
        static let additionalDetails = localized("additionalDetails", comment: "Label for additional details field")
        static let additionalDetailsPlaceholder = localized("additionalDetailsPlaceholder", comment: "Placeholder for additional details field")
        static let submitSuggestion = localized("submitSuggestion", comment: "Button to submit recipe suggestion")
        static let submissionSuccess = localized("submissionSuccess", comment: "Success message for recipe submission")
        static let submissionSuccessMessage = localized("submissionSuccessMessage", comment: "Detailed success message for recipe submission")
        static let didntFindRecipe = localized("didntFindRecipe", comment: "Message when recipe not found in search")
        static let helpUsAddIt = localized("helpUsAddIt", comment: "Call to action to suggest missing recipe")
        static let suggestThisRecipe = localized("suggestThisRecipe", comment: "Button to suggest a specific recipe")
        static let dailyLimitReached = localized("dailyLimitReached", comment: "Message when daily submission limit reached")
        static let submissionsRemaining = localized("submissionsRemaining", comment: "Text showing remaining submissions")
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
    
    /// Asset names and resource identifiers
    enum Assets {
        // Icon names (UPDATED - More semantic)
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
        
        // Recipe Submission Icons
        static let submissionIcon = "paperplane.fill"
        static let approvedIcon = "checkmark.circle.fill"
        static let pendingIcon = "clock.circle"
        static let declinedIcon = "xmark.circle"
        static let suggestIcon = "plus.circle.fill"
        static let notificationIcon = "bell.fill"
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
        
        static let simulatedNetworkDelay: Double = 0.3
        
        // Recipe Submission Timing
        static let toastDuration: Double = 4.0
        static let notificationAnimationDuration: Double = 0.6
        static let submissionTimeout: Double = 30.0
        static let duplicateCheckDebounce: Double = 0.5
    }
    
    enum RecipeSubmission {
        static let dailySubmissionLimit = 5
        static let characterLimit = 500
        static let minimumNameLength = 2
        static let maximumNameLength = 100
        
        // CloudKit
        static let recordType = "RecipeSubmission"
        static let publicDatabase = "public"
        
        // User defaults keys
        static let submissionCountKey = "RecipeSubmissionCount"
        static let lastSubmissionDateKey = "LastRecipeSubmissionDate"
        static let lastResetDateKey = "LastSubmissionResetDate"
        static let lastNotificationCheckKey = "LastNotificationCheckDate"
        
        // Notification types
        static let recipeApprovalType = "recipe_approval"
        static let appUpdateType = "app_update"
        static let announcementType = "announcement"
    }
}
