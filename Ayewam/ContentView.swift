//
//  ContentView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.name, ascending: true)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Category.name, ascending: true)],
        animation: .default)
    private var categories: FetchedResults<Category>
    
    @State private var selectedCategory: Category?
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            List {
                // Categories section
                Section(header: Text("Categories")) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = (selectedCategory == category) ? nil : category
                        }) {
                            HStack {
                                Circle()
                                    .fill(Color(hex: category.colorHex ?? "#000000"))
                                    .frame(width: 12, height: 12)
                                
                                Text(category.name ?? "Unknown")
                                
                                Spacer()
                                
                                if selectedCategory == category {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    if selectedCategory != nil {
                        Button("Clear Filter") {
                            selectedCategory = nil
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                // Recipes section
                Section(header: Text("Recipes")) {
                    if filteredRecipes.isEmpty {
                        Text("No recipes found")
                            .foregroundColor(.secondary)
                            .italic()
                    } else {
                        ForEach(filteredRecipes, id: \.self) { recipe in
                            NavigationLink {
                                RecipeDetailPlaceholder(recipe: recipe)
                            } label: {
                                RecipeRowView(recipe: recipe)
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Ghanaian Recipes")
            .searchable(text: $searchText, prompt: "Search recipes")
            
            // Detail view placeholder (for larger screens)
            Text("Select a recipe")
                .font(.largeTitle)
                .foregroundColor(.secondary)
        }
    }
    
    // Filter recipes based on selected category and search text
    private var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            // Category filter
            let categoryMatch = selectedCategory == nil || recipe.category == selectedCategory
            
            // Search text filter
            let searchMatch: Bool
            if searchText.isEmpty {
                searchMatch = true
            } else {
                let nameMatch = recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false
                let descMatch = recipe.recipeDescription?.localizedCaseInsensitiveContains(searchText) ?? false
                searchMatch = nameMatch || descMatch
            }
            
            return categoryMatch && searchMatch
        }
    }
}

// Placeholder for recipe detail view
struct RecipeDetailPlaceholder: View {
    let recipe: Recipe
    
    var body: some View {
        VStack {
            Text(recipe.name ?? "Unknown Recipe")
                .font(.title)
                .padding()
            
            Text(recipe.recipeDescription ?? "No description")
                .padding()
            
            Spacer()
            
            Text("Full recipe details coming soon!")
                .italic()
                .foregroundColor(.secondary)
        }
        .navigationTitle(recipe.name ?? "Recipe")
    }
}

// Recipe row component
struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            // Recipe image or placeholder
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.3))
                .frame(width: 60, height: 60)
                .overlay(
                    Text(String(recipe.name?.prefix(1) ?? "R"))
                        .font(.title)
                        .foregroundColor(.white)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name ?? "Unknown Recipe")
                    .font(.headline)
                
                if let description = recipe.recipeDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 12) {
                    if recipe.prepTime > 0 || recipe.cookTime > 0 {
                        Label("\(recipe.prepTime + recipe.cookTime) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                        Text(difficulty)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            if recipe.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
