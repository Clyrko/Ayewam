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
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        
        var predicates: [NSPredicate] = []
        
        if let category = category {
            predicates.append(NSPredicate(format: "category == %@ OR category CONTAINS %@", category, category))
        }
        
        if let searchText = searchText, !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name CONTAINS[cd] %@ OR recipeDescription CONTAINS[cd] %@", searchText, searchText))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        // Sorting by name
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            //TODO: justynx uncomment this
//            ErrorHandler.shared.logError(error, identifier: "RecipeRepository.fetchRecipes")
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
        let request: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        request.predicate = NSPredicate(format: "isFavorite == YES")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching favorite recipes: \(error)")
            return []
        }
    }
    
    // MARK: - Update Operations
    /// Toggles the favorite status of a recipe
    func toggleFavorite(_ recipe: Recipe) throws {
        recipe.isFavorite.toggle()
        
        do {
            try context.save()
        } catch {
            ErrorHandler.shared.logError(error, identifier: "RecipeRepository.toggleFavorite")
            throw AyewamError.failedToSaveData
        }
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
