//
//  RecipeRepository.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData

class RecipeRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Query Operations
    
    /// Fetches all recipes, optionally filtered by category
    func fetchRecipes(category: Category? = nil, searchText: String? = nil) -> [Recipe] {
        var predicates: [NSPredicate] = []
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@ OR category CONTAINS %@", category, category))
        }
        
        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@ OR recipeDescription CONTAINS[cd] %@", searchText, searchText))
        }
        
        let predicate = predicates.isEmpty ? nil : NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        let sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)]
        
        let request = CoreDataOptimizer.optimizedFetchRequest(
            for: Recipe.self,
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        
        do {
            return try context.fetch(request)
        } catch {
            ErrorHandler.shared.logError(error, identifier: "RecipeRepository.fetchRecipes")
            return []
        }
    }
    
    /// Fetches a single recipe by ID
    func fetchRecipe(withID id: String) -> Recipe? {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching recipe: \(error)")
            return nil
        }
    }
    
    /// Fetches favorite recipes
    func fetchFavoriteRecipes() -> [Recipe] {
        let predicate = NSPredicate(format: "isFavorite == YES")
        let sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)]
        
        let request = CoreDataOptimizer.optimizedFetchRequest(
            for: Recipe.self,
            predicate: predicate,
            sortDescriptors: sortDescriptors
        )
        
        do {
            return try context.fetch(request)
        } catch {
            ErrorHandler.shared.logError(error, identifier: "RecipeRepository.fetchFavoriteRecipes")
            return []
        }
    }
    
    // MARK: - Update Operations
    /// Toggles the favorite status of a recipe
    func toggleFavorite(_ recipe: Recipe) throws {
        // If we're toggling a single recipe, use the regular approach
        if context.registeredObjects.contains(recipe) {
            recipe.isFavorite.toggle()
            try CoreDataOptimizer.saveContext(context)
            return
        }
        
        // For bulk operations, use batch update
        guard let id = recipe.id else {
            throw AyewamError.invalidData
        }
        
        // Get current status
        let currentValue = recipe.isFavorite
        
        // Perform batch update
        let predicate = NSPredicate(format: "id == %@", id)
        let _ = try CoreDataOptimizer.batchUpdate(
            in: context,
            entityName: "Recipe",
            propertiesToUpdate: ["isFavorite": !currentValue],
            predicate: predicate
        )
    }
    
    func fetchRecipeResult(withID id: String) -> Result<Recipe, Error> {
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let recipe = results.first {
                return .success(recipe)
            } else {
                return .failure(AyewamError.recipeNotFound)
            }
        } catch {
            ErrorHandler.shared.logError(error, identifier: "RecipeRepository.fetchRecipeResult")
            return .failure(AyewamError.operationFailed(reason: "Failed to fetch recipe"))
        }
    }
}
