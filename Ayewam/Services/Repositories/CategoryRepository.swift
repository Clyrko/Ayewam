//
//  CategoryRepository.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData

class CategoryRepository {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Query Operations
    
    /// Fetches all categories
    func fetchCategories() -> [Category] {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Category.name, ascending: true)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching categories: \(error)")
            return []
        }
    }
    
    /// Fetches a category by name
    func fetchCategory(withName name: String) -> Category? {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        request.predicate = NSPredicate(format: "name == %@", name)
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            return results.first
        } catch {
            print("Error fetching category: \(error)")
            return nil
        }
    }
    
    func fetchRecipes(forCategory category: Category) -> [Recipe] {
        guard let recipes = category.recipes as? Set<Recipe> else {
            return []
        }
        
        return recipes.sorted {
            ($0.name ?? "") < ($1.name ?? "")
        }
    }

    /// Returns the number of recipes in a category
    func recipeCount(forCategory category: Category) -> Int {
        return category.recipes?.count ?? 0
    }
}
