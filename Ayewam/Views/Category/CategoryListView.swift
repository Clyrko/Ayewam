//
//  CategoryListView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI
import CoreData

struct CategoryListView: View {
    @ObservedObject private var viewModel = DataManager.shared.categoryViewModel
    @State private var gridLayout = [GridItem(.adaptive(minimum: Constants.UI.gridMinimumWidth, maximum: 170), spacing: Constants.UI.gridItemSpacing)]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Constants.UI.standardPadding) {
                // Header
                Text(Constants.Text.exploreCategoriesSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Grid of categories
                if viewModel.isLoading {
                    LoadingView(message: Constants.Text.loadingCategories)
                } else if let errorMessage = viewModel.errorMessage {
                    ErrorView(errorMessage: errorMessage) {
                        viewModel.loadCategories()
                    }
                } else if viewModel.categories.isEmpty {
                    emptyCategoriesView
                } else {
                    categoriesGrid
                }
            }
            .padding(.top)
        }
        .navigationTitle(Constants.Text.categoriesTitle)
        .onAppear {
            viewModel.loadCategories()
        }
    }
    
    // Category grid
    private var categoriesGrid: some View {
        LazyVGrid(columns: gridLayout, spacing: 16) {
            ForEach(viewModel.categories, id: \.self) { category in
                NavigationLink(destination:
                    HomeRecipeView(initialCategory: category)
                        .navigationTitle(category.name ?? "Recipes")
                ) {
                    CategoryCard(
                        category: category,
                        recipeCount: viewModel.recipeCount(for: category)
                    )
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    // Empty state view
    private var emptyCategoriesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 50))
                .foregroundColor(.secondary)
            
            Text("No Categories Found")
                .font(.headline)
            
            Text("Check back later for new categories")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: 300)
        .padding()
    }
}

// Category Card Component
struct CategoryCard: View {
    let category: Category
    let recipeCount: Int
    
    var body: some View {
        VStack {
            // Category color and icon
            ZStack {
                Rectangle()
                    .fill(Color(hex: category.colorHex ?? Constants.Assets.defaultCategoryColor))
                    .aspectRatio(1.5, contentMode: .fit)
                    .cornerRadius(Constants.UI.standardCornerRadius)
                
                if let imageName = category.imageName, !imageName.isEmpty {
                    Image(systemName: Constants.Assets.defaultFoodIcon)
                        .font(.system(size: Constants.UI.extraLargeIconSize * 2/3))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text(String(category.name?.prefix(1) ?? "C"))
                        .font(.system(size: Constants.UI.extraLargeIconSize * 2/3, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Category name and recipe count
            VStack(spacing: 4) {
                Text(category.name ?? "Unknown")
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                Text("\(recipeCount) \(Constants.Localization.pluralized(singular: "recipe", plural: "recipes", count: recipeCount))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, Constants.UI.smallPadding)
            .padding(.bottom, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(Constants.UI.standardCornerRadius)
        .shadow(color: Color.black.opacity(Constants.UI.standardShadowOpacity),
                radius: Constants.UI.standardShadowRadius,
                x: 0,
                y: Constants.UI.standardShadowY)
    }
}

// Preview Provider
struct CategoryListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CategoryListView()
        }
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
