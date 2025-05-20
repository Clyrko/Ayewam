//
//  AyewamViewModelTests.swift
//  AyewamTests
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import XCTest
@testable import Ayewam
import CoreData
import Combine

final class AyewamViewModelTests: XCTestCase {
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var recipeRepository: RecipeRepository!
    var categoryRepository: CategoryRepository!
    var recipeManager: RecipeManager!
    var cancellables = Set<AnyCancellable>()
    
    override func setUpWithError() throws {
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        
        recipeRepository = RecipeRepository(context: context)
        categoryRepository = CategoryRepository(context: context)
        recipeManager = RecipeManager(context: context)
        
        let recipeSeeder = RecipeSeeder(context: context)
        recipeSeeder.seedDefaultRecipesIfNeeded()
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
        recipeRepository = nil
        categoryRepository = nil
        recipeManager = nil
        cancellables.removeAll()
    }
    
    // MARK: - RecipeViewModel Tests
    
    func testRecipeViewModelLoadsRecipes() throws {
        // Create the view model
        let viewModel = RecipeViewModel(repository: recipeRepository, manager: recipeManager)
        
        // Set up expectation
        let expectation = self.expectation(description: "Load recipes")
        
        viewModel.$recipes
            .dropFirst()
            .sink { recipes in
                if !recipes.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.loadRecipes()
        
        // Wait for expectation
        waitForExpectations(timeout: 2.0)
        
        // Verify recipes were loaded
        XCTAssertFalse(viewModel.recipes.isEmpty, "ViewModel should have loaded recipes")
        XCTAssertFalse(viewModel.isLoading, "Loading should be complete")
        XCTAssertNil(viewModel.errorMessage, "There should be no error")
    }
    
    func testRecipeViewModelFiltersRecipesByCategory() throws {
        // Create the view model
        let viewModel = RecipeViewModel(repository: recipeRepository, manager: recipeManager)
        
        // Get a category to filter by
        let categories = categoryRepository.fetchCategories()
        guard let category = categories.first else {
            XCTFail("No categories for testing")
            return
        }
        
        // Assign a recipe to the category for testing
        let recipes = recipeRepository.fetchRecipes()
        guard let recipe = recipes.first else {
            XCTFail("No recipes for testing")
            return
        }
        recipe.category = category
        try context.save()
        
        // Set up expectation
        let expectation = self.expectation(description: "Filter by category")
        
        // Listen for changes to recipes array after setting category
        viewModel.$recipes
            .dropFirst(2)
            .sink { recipes in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // First load all recipes
        viewModel.loadRecipes()
        
        // Then filter by category
        viewModel.selectedCategory = category
        
        // Wait for expectation
        waitForExpectations(timeout: 2.0)
        
        // Verify filtering works
        XCTAssertFalse(viewModel.recipes.isEmpty, "Filtered recipes should not be empty")
        
        // All returned recipes should be in the selected category
        for filteredRecipe in viewModel.recipes {
            if let recipeCategory = filteredRecipe.categoryObject {
                XCTAssertEqual(recipeCategory.name, category.name, "Filtered recipe should be in the selected category")
            }
        }
    }
    
    func testRecipeViewModelFiltersRecipesBySearchText() throws {
        // Create the view model
        let viewModel = RecipeViewModel(repository: recipeRepository, manager: recipeManager)
        
        // Set up expectation
        let expectation = self.expectation(description: "Filter by search text")
        
        // First load all recipes
        viewModel.loadRecipes()
        
        // Get a search term from an existing recipe
        guard let recipe = viewModel.recipes.first, let name = recipe.name, !name.isEmpty else {
            XCTFail("No valid recipes for search test")
            return
        }
        
        // Get a unique substring from the recipe name
        let searchText = String(name.prefix(4))
        
        // Listen for filtered recipes
        viewModel.$recipes
            .dropFirst(2)
            .sink { recipes in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        // Set search text
        viewModel.searchText = searchText
        
        // Wait for expectation
        waitForExpectations(timeout: 2.0)
        
        // Verify search filtering works
        XCTAssertFalse(viewModel.recipes.isEmpty, "Search results should not be empty")
        
        // All returned recipes should contain the search text
        for filteredRecipe in viewModel.recipes {
            let nameMatch = filteredRecipe.name?.localizedCaseInsensitiveContains(searchText) ?? false
            let descMatch = filteredRecipe.recipeDescription?.localizedCaseInsensitiveContains(searchText) ?? false
            XCTAssertTrue(nameMatch || descMatch, "Filtered recipe should contain search text")
        }
    }
    
    func testRecipeViewModelTogglesFavorite() throws {
        // Create the view model
        let viewModel = RecipeViewModel(repository: recipeRepository, manager: recipeManager)
        
        // Load recipes and get one to work with
        viewModel.loadRecipes()
        
        // Wait for recipes to load
        let loadExpectation = self.expectation(description: "Load recipes")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            loadExpectation.fulfill()
        }
        waitForExpectations(timeout: 2.0)
        
        guard let recipe = viewModel.recipes.first else {
            XCTFail("No recipes loaded for testing")
            return
        }
        
        // Store initial favorite status
        let initialStatus = recipe.isFavorite
        
        // Toggle favorite
        viewModel.toggleFavorite(recipe)
        
        // Wait for toggle to process
        let toggleExpectation = self.expectation(description: "Toggle favorite")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            toggleExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
        
        // Fetch the recipe again to verify change
        let updatedRecipe = recipeRepository.fetchRecipe(withID: recipe.id ?? "")
        XCTAssertNotNil(updatedRecipe, "Recipe should still exist")
        XCTAssertEqual(updatedRecipe?.isFavorite, !initialStatus, "Favorite status should be toggled")
    }
    
    // MARK: - CategoryViewModel Tests
    
    func testCategoryViewModelLoadsCategories() throws {
        // Create the view model
        let viewModel = CategoryViewModel(repository: categoryRepository, manager: recipeManager)
        
        // Set up expectation
        let expectation = self.expectation(description: "Load categories")
        
        // Listen for changes to categories array
        viewModel.$categories
            .dropFirst()
            .sink { categories in
                if !categories.isEmpty {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Trigger loading
        viewModel.loadCategories()
        
        // Wait for expectation
        waitForExpectations(timeout: 2.0)
        
        // Verify categories were loaded
        XCTAssertFalse(viewModel.categories.isEmpty, "ViewModel should have loaded categories")
        XCTAssertFalse(viewModel.isLoading, "Loading should be complete")
        XCTAssertNil(viewModel.errorMessage, "There should be no error")
    }
    
    func testCategoryViewModelCountsRecipes() throws {
        // Create the view model
        let viewModel = CategoryViewModel(repository: categoryRepository, manager: recipeManager)
        
        // Load categories
        viewModel.loadCategories()
        
        // Wait for categories to load
        let loadExpectation = self.expectation(description: "Load categories")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            loadExpectation.fulfill()
        }
        waitForExpectations(timeout: 2.0)
        
        guard let category = viewModel.categories.first else {
            XCTFail("No categories loaded for testing")
            return
        }
        
        // Get a recipe to assign to the category
        let recipes = recipeRepository.fetchRecipes()
        guard let recipe = recipes.first else {
            XCTFail("No recipes for testing")
            return
        }
        
        // Assign recipe to category
        recipe.category = category
        try context.save()
        
        // Get the count of recipes in the category
        let count = viewModel.recipeCount(for: category)
        
        // Verify recipe count
        XCTAssertGreaterThan(count, 0, "Category should have at least one recipe")
        
        // Get recipes for the category
        let categoryRecipes = viewModel.recipes(for: category)
        
        // Verify recipes were retrieved
        XCTAssertEqual(categoryRecipes.count, count, "Recipe count should match number of recipes")
        XCTAssertTrue(categoryRecipes.contains { $0.id == recipe.id }, "Assigned recipe should be in the category")
    }
}
