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
    @State private var gridLayout = [GridItem(.adaptive(minimum: 150, maximum: 170), spacing: 16)]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("Explore Ghanaian cuisine through these traditional categories")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Grid of categories
                if viewModel.isLoading {
                    LoadingView(message: "Loading categories...")
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
        .navigationTitle("Categories")
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
                    CategoryCard(category: category)
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
    
    var body: some View {
        VStack {
            // Category color and icon
            ZStack {
                Rectangle()
                    .fill(Color(hex: category.colorHex ?? "#767676"))
                    .aspectRatio(1.5, contentMode: .fit)
                    .cornerRadius(12)
                
                if let imageName = category.imageName, !imageName.isEmpty {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text(String(category.name?.prefix(1) ?? "C"))
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            
            // Category name
            Text(category.name ?? "Unknown")
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .lineLimit(1)
                .padding(.top, 8)
                .padding(.bottom, 4)
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
