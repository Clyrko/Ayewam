//
//  FavoriteViewModel.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData
import Combine

class FavoriteViewModel: ObservableObject {
    private let repository: RecipeRepository
    private let manager: RecipeManager
    
    @Published var favoriteRecipes: [Recipe] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: RecipeRepository, manager: RecipeManager) {
        self.repository = repository
        self.manager = manager
        
        // Listen for favorite changes
        manager.favoriteChangedPublisher
            .sink { [weak self] _ in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
        
        loadFavorites()
    }
    
    func loadFavorites() {
        isLoading = true
        errorMessage = nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.simulatedNetworkDelay) { [weak self] in
            guard let self = self else { return }
            
            self.favoriteRecipes = self.manager.fetchFavoriteRecipes()
            self.isLoading = false
        }
    }
    
    func toggleFavorite(_ recipe: Recipe) {
        do {
            try manager.toggleFavorite(recipe)
            loadFavorites()
        } catch {
            ErrorHandler.shared.handleError(error, context: "favorite_toggle")
        }
    }
}
