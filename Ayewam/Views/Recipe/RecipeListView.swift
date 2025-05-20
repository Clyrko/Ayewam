//
//  RecipeListView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI
import CoreData

struct RecipeListView: View {
    @ObservedObject var viewModel: RecipeViewModel
    @ObservedObject var categoryViewModel: CategoryViewModel
    @State private var showingSearchBar = false
    
    var body: some View {
        ZStack {
            // Main content
            VStack(spacing: 0) {
                // Search and filter header
                searchAndFilterHeader
                
                // Recipe list
                if viewModel.isLoading {
                    LoadingView(message: "Loading recipes...")
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        viewModel.loadRecipes(category: viewModel.selectedCategory, searchText: viewModel.searchText)
                    }
                    .padding()
                } else if viewModel.recipes.isEmpty {
                    emptyStateView
                } else {
                    recipeListView
                }
            }
        }
        .navigationTitle("Ghanaian Recipes")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingSearchBar.toggle() }) {
                    Image(systemName: showingSearchBar ? "xmark" : "magnifyingglass")
                }
            }
        }
    }
    
    // MARK: - Search and Filter Header
    private var searchAndFilterHeader: some View {
        VStack(spacing: 0) {
            // Search bar
            if showingSearchBar {
                searchBar
            }
            
            // Category filter chips
            categoryFilterView
        }
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search recipes", text: $viewModel.searchText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.top, 8)
        .animation(.default, value: showingSearchBar)
    }
    
    // MARK: - Category Filter
    private var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // All recipes option
                CategoryChip(
                    title: "All",
                    colorHex: "#767676",
                    isSelected: viewModel.selectedCategory == nil
                ) {
                    viewModel.selectedCategory = nil
                }
                
                // Category chips
                ForEach(categoryViewModel.categories, id: \.self) { category in
                    CategoryChip(
                        title: category.name ?? "Unknown",
                        colorHex: category.colorHex ?? "#000000",
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - Recipe List
    private var recipeListView: some View {
        List {
            ForEach(viewModel.recipes, id: \.self) { recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe, viewModel: viewModel)
                } label: {
                    RecipeRowView(recipe: recipe)
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "text.book.closed")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No recipes found")
                .font(.headline)
            
            Text(viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty ?
                "Try adjusting your filters or search terms" :
                "Check back later for new recipes"
            )
            .font(.subheadline)
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .padding(.horizontal)
            
            if viewModel.selectedCategory != nil || !viewModel.searchText.isEmpty {
                Button("Clear Filters") {
                    viewModel.selectedCategory = nil
                    viewModel.searchText = ""
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Category Chip Component
struct CategoryChip: View {
    let title: String
    let colorHex: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Circle()
                    .fill(Color(hex: colorHex))
                    .frame(width: 8, height: 8)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: colorHex).opacity(0.2) : Color(.systemGray6))
            )
        }
    }
}

struct RecipeListView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        
        let manager = RecipeManager(context: context)
        
        let recipeRepository = RecipeRepository(context: context)
        let categoryRepository = CategoryRepository(context: context)
        
        NavigationView {
            RecipeListView(
                viewModel: RecipeViewModel(
                    repository: recipeRepository,
                    manager: manager
                ),
                categoryViewModel: CategoryViewModel(
                    repository: categoryRepository,
                    manager: manager
                )
            )
        }
    }
}
