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
    
    // Manager
    let recipeManager: RecipeManager
    
    // ViewModels
    let recipeViewModel: RecipeViewModel
    let categoryViewModel: CategoryViewModel
    let favoriteViewModel: FavoriteViewModel
    
    private init() {
        persistenceController = PersistenceController.shared
        context = persistenceController.container.viewContext
        
        // Initialize manager
        recipeManager = RecipeManager(context: context)
        
        // Initialize repositories (for backward compatibility)
        let recipeRepository = RecipeRepository(context: context)
        let categoryRepository = CategoryRepository(context: context)
        
        // Initialize ViewModels
        recipeViewModel = RecipeViewModel(repository: recipeRepository, manager: recipeManager)
        categoryViewModel = CategoryViewModel(repository: categoryRepository, manager: recipeManager)
        favoriteViewModel = FavoriteViewModel(repository: recipeRepository, manager: recipeManager)
    }
}
