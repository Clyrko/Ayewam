//
//  CategoryViewModel.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import CoreData

class CategoryViewModel: ObservableObject {
    private let repository: CategoryRepository
    
    @Published var categories: [Category] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    init(repository: CategoryRepository) {
        self.repository = repository
        loadCategories()
    }
    
    func loadCategories() {
        isLoading = true
        errorMessage = nil
        
        // Simulate network delay for UI testing (remove in production)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            self.categories = self.repository.fetchCategories()
            self.isLoading = false
        }
    }
}
