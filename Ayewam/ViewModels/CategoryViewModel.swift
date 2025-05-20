//
//  CategoryViewModel.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData
import Combine

class CategoryViewModel: ObservableObject {
    private let repository: CategoryRepository
    private let manager: RecipeManager
    
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: CategoryRepository, manager: RecipeManager) {
        self.repository = repository
        self.manager = manager
        loadCategories()
    }
    
    func loadCategories() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay for UI testing
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.Timing.simulatedNetworkDelay) { [weak self] in
            guard let self = self else { return }
            
            self.categories = self.manager.fetchCategories()
            self.isLoading = false
        }
    }
    
    func recipeCount(for category: Category) -> Int {
        return manager.recipeCount(forCategory: category)
    }
    
    func recipes(for category: Category) -> [Recipe] {
        return manager.fetchRecipes(forCategory: category)
    }
}
