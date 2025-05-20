//
//  DataManager.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData

class DataManager {
    static let shared = DataManager()
    
    private let persistenceController: PersistenceController
    private let context: NSManagedObjectContext
    
    // Repositories
    let recipeRepository: RecipeRepository
    let categoryRepository: CategoryRepository
    
    // ViewModels
    let recipeViewModel: RecipeViewModel
    let categoryViewModel: CategoryViewModel
    let favoriteViewModel: FavoriteViewModel
    
    private init() {
        persistenceController = PersistenceController.shared
        context = persistenceController.container.viewContext
        
        // Initialize repositories
        recipeRepository = RecipeRepository(context: context)
        categoryRepository = CategoryRepository(context: context)
        
        // Initialize ViewModels
        recipeViewModel = RecipeViewModel(repository: recipeRepository)
        categoryViewModel = CategoryViewModel(repository: categoryRepository)
        favoriteViewModel = FavoriteViewModel(repository: recipeRepository)
        
        // Seed data if needed
        seedDataIfNeeded()
    }
    
    private func seedDataIfNeeded() {
        let recipeSeeder = RecipeSeeder(context: context)
        recipeSeeder.seedDefaultRecipesIfNeeded()
    }
}
