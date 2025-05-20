//
//  AyewamTests.swift
//  AyewamTests
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import XCTest
@testable import Ayewam
import CoreData

final class AyewamTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var recipeRepository: RecipeRepository!
    var categoryRepository: CategoryRepository!
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        
        // Create repositories
        recipeRepository = RecipeRepository(context: context)
        categoryRepository = CategoryRepository(context: context)
        
        // Seed test data
        let recipeSeeder = RecipeSeeder(context: context)
        recipeSeeder.seedDefaultRecipesIfNeeded()
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
        recipeRepository = nil
        categoryRepository = nil
    }
    
    // MARK: - Recipe Repository Tests
    
    func testFetchRecipes() throws {
        // Test fetching all recipes
        let recipes = recipeRepository.fetchRecipes()
        
        // Verify recipes were loaded
        XCTAssertFalse(recipes.isEmpty, "Should have loaded recipes")
        
        // Verify recipe properties
        if let recipe = recipes.first {
            XCTAssertNotNil(recipe.id, "Recipe should have an ID")
            XCTAssertNotNil(recipe.name, "Recipe should have a name")
        }
    }
    
    func testFetchRecipeByID() throws {
        // First get any recipe
        let recipes = recipeRepository.fetchRecipes()
        guard let firstRecipe = recipes.first, let id = firstRecipe.id else {
            XCTFail("No recipes found for testing")
            return
        }
        
        // Test fetching by ID
        let fetchedRecipe = recipeRepository.fetchRecipe(withID: id)
        
        // Verify recipe was found
        XCTAssertNotNil(fetchedRecipe, "Recipe should be found by ID")
        XCTAssertEqual(fetchedRecipe?.id, id, "Fetched recipe should have the same ID")
        XCTAssertEqual(fetchedRecipe?.name, firstRecipe.name, "Fetched recipe should have the same name")
    }
    
    func testFetchRecipeWithInvalidID() throws {
        // Test fetching with invalid ID
        let fetchedRecipe = recipeRepository.fetchRecipe(withID: "invalid_id")
        
        // Verify no recipe was found
        XCTAssertNil(fetchedRecipe, "No recipe should be found for invalid ID")
    }
    
    func testFetchFavoriteRecipes() throws {
        // First make sure we have at least one favorite recipe
        let recipes = recipeRepository.fetchRecipes()
        guard let recipe = recipes.first else {
            XCTFail("No recipes found for testing")
            return
        }
        
        // Toggle favorite status to true
        recipe.isFavorite = true
        try context.save()
        
        // Test fetching favorites
        let favorites = recipeRepository.fetchFavoriteRecipes()
        
        // Verify favorite was found
        XCTAssertFalse(favorites.isEmpty, "Should have at least one favorite recipe")
        XCTAssertTrue(favorites.contains { $0.id == recipe.id }, "The marked favorite recipe should be in the results")
    }
    
    func testToggleFavorite() throws {
        // Get a recipe
        let recipes = recipeRepository.fetchRecipes()
        guard let recipe = recipes.first else {
            XCTFail("No recipes found for testing")
            return
        }
        
        // Store initial favorite status
        let initialStatus = recipe.isFavorite
        
        // Toggle favorite status
        try recipeRepository.toggleFavorite(recipe)
        
        // Verify status was toggled
        XCTAssertEqual(recipe.isFavorite, !initialStatus, "Favorite status should be toggled")
        
        // Toggle back and verify again
        try recipeRepository.toggleFavorite(recipe)
        XCTAssertEqual(recipe.isFavorite, initialStatus, "Favorite status should be toggled back")
    }
    
    // MARK: - Category Repository Tests
    
    func testFetchCategories() throws {
        // Test fetching all categories
        let categories = categoryRepository.fetchCategories()
        
        // Verify categories were loaded
        XCTAssertFalse(categories.isEmpty, "Should have loaded categories")
        
        // Verify category properties
        if let category = categories.first {
            XCTAssertNotNil(category.name, "Category should have a name")
        }
    }
    
    func testFetchCategoryByName() throws {
        // First get any category
        let categories = categoryRepository.fetchCategories()
        guard let firstCategory = categories.first, let name = firstCategory.name else {
            XCTFail("No categories found for testing")
            return
        }
        
        // Test fetching by name
        let fetchedCategory = categoryRepository.fetchCategory(withName: name)
        
        // Verify category was found
        XCTAssertNotNil(fetchedCategory, "Category should be found by name")
        XCTAssertEqual(fetchedCategory?.name, name, "Fetched category should have the same name")
    }
    
    func testFetchRecipesByCategory() throws {
        // Get categories and recipes
        let categories = categoryRepository.fetchCategories()
        let recipes = recipeRepository.fetchRecipes()
        
        // Skip test if data is insufficient
        guard let category = categories.first, let recipe = recipes.first else {
            XCTFail("Not enough test data")
            return
        }
        
        // Assign recipe to category
        if let mutableCategory = recipe.category as? NSMutableSet {
            mutableCategory.add(category)
        } else {
            recipe.category = category
        }
        try context.save()
        
        // Fetch recipes for the category
        let categoryRecipes = categoryRepository.fetchRecipes(forCategory: category)
        
        // Verify the recipe was found in the category
        XCTAssertTrue(categoryRecipes.contains { $0.id == recipe.id }, "Recipe should be found in its assigned category")
    }
}
