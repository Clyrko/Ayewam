//
//  RecipeViewModel.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import Combine
import CoreData

class RecipeViewModel: ObservableObject {
    private let repository: RecipeRepository
    private let manager: RecipeManager
    
    @Published var recipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedCategory: Category?
    @Published var searchText: String = ""
    @Published var selectedSortOption: RecipeSortOption = .nameAscending
    @Published var selectedDifficulty: String?
    @Published var selectedRegion: String?
    
    // Available filtering options
    @Published var availableDifficulties: [String] = []
    @Published var availableRegions: [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: RecipeRepository, manager: RecipeManager) {
        self.repository = repository
        self.manager = manager
        
        // Load available filtering options
        loadFilteringOptions()
        
        // Setup publishers for search and filtering changes
        Publishers.CombineLatest4($selectedCategory, $searchText, $selectedDifficulty, $selectedRegion)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] category, searchText, difficulty, region in
                self?.loadRecipes(category: category, searchText: searchText, difficulty: difficulty, region: region)
            }
            .store(in: &cancellables)
        
        // Setup publisher for sort option changes
        $selectedSortOption
            .dropFirst()
            .sink { [weak self] _ in
                self?.sortRecipes()
            }
            .store(in: &cancellables)
        
        // Listen for recipe changes
        manager.favoriteChangedPublisher
            .sink { [weak self] recipe in
                self?.refreshRecipeInList(recipe)
            }
            .store(in: &cancellables)
    }
    
    func loadRecipes(category: Category? = nil, searchText: String = "", difficulty: String? = nil, region: String? = nil) {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay for UI testing
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.simulatedNetworkDelay) { [weak self] in
            guard let self = self else { return }
            
            let filtering = RecipeFiltering(
                category: category,
                searchText: searchText.isEmpty ? nil : searchText,
                difficulty: difficulty,
                region: region,
                sortOption: self.selectedSortOption
            )
            
            self.recipes = self.manager.fetchRecipes(filtering: filtering)
            self.isLoading = false
        }
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        do {
            try manager.toggleFavorite(recipe)
        } catch {
            ErrorHandler.shared.logError(error, identifier: "RecipeViewModel.toggleFavorite")
            errorMessage = ErrorHandler.shared.userFriendlyMessage(for: error)
        }
    }
    
    func loadRecipe(withID id: String, completion: @escaping (Result<Recipe, Error>) -> Void) {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.simulatedNetworkDelay) { [weak self] in
            guard let self = self else { return }
            
            let result = self.repository.fetchRecipeResult(withID: id)
            self.isLoading = false
            
            switch result {
            case .success(let recipe):
                completion(.success(recipe))
            case .failure(let error):
                self.errorMessage = ErrorHandler.shared.userFriendlyMessage(for: error)
                completion(.failure(error))
            }
        }
    }
    
    func loadFilteringOptions() {
        availableDifficulties = manager.availableDifficultyLevels()
        availableRegions = manager.availableRegions()
    }
    
    func clearFilters() {
        selectedCategory = nil
        searchText = ""
        selectedDifficulty = nil
        selectedRegion = nil
        selectedSortOption = .nameAscending
    }
    
    private func sortRecipes() {
        recipes = manager.sortRecipes(recipes, by: selectedSortOption)
    }
    
    private func refreshRecipeInList(_ recipe: Recipe) {
        if let index = recipes.firstIndex(where: { $0.id == recipe.id }) {
            // Replace the recipe in the array to update the UI
            recipes[index] = recipe
        }
    }
}
