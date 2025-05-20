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
    
    @Published var recipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var selectedCategory: Category?
    @Published var searchText: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: RecipeRepository) {
        self.repository = repository
        
        Publishers.CombineLatest($selectedCategory, $searchText)
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] category, searchText in
                self?.loadRecipes(category: category, searchText: searchText)
            }
            .store(in: &cancellables)
    }
    
    func loadRecipes(category: Category? = nil, searchText: String = "") {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            
            self.recipes = self.repository.fetchRecipes(category: category, searchText: searchText)
            self.isLoading = false
        }
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        do {
            try repository.toggleFavorite(recipe)
        } catch {
            errorMessage = "Failed to update favorite status: \(error.localizedDescription)"
        }
    }
}
