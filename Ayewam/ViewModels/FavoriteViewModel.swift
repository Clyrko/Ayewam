//
//  FavoriteViewModel.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData

class FavoriteViewModel: ObservableObject {
    private let repository: RecipeRepository
    
    @Published var favoriteRecipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(repository: RecipeRepository) {
        self.repository = repository
        loadFavorites()
    }
    
    func loadFavorites() {
        isLoading = true
        errorMessage = nil
        
        //TODO: jutynx Simulate network delay for UI testing (remove in production)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.favoriteRecipes = self.repository.fetchFavoriteRecipes()
            self.isLoading = false
        }
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        do {
            try repository.toggleFavorite(recipe)
            loadFavorites()
        } catch {
            errorMessage = "Failed to update favorite status: \(error.localizedDescription)"
        }
    }
}
