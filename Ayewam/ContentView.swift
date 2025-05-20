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
    
    var body: some View {
        TabView {
            // Recipes Tab
            NavigationView {
                HomeRecipeView()
            }
            .tabItem {
                Label("Recipes", systemImage: "book")
            }
            
            // Categories Tab
            NavigationView {
                CategoryListView()
            }
            .tabItem {
                Label("Categories", systemImage: "square.grid.2x2")
            }
            
            // Favorites Tab
            NavigationView {
                FavoritesView()
            }
            .tabItem {
                Label("Favorites", systemImage: "heart")
            }
            
            // About Tab
            NavigationView {
                AboutView()
            }
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
    }
}

struct HomeRecipeView: View {
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
    
    init(initialCategory: Category? = nil) {
        self._selectedCategory = State(initialValue: initialCategory)
    }
    
    var body: some View {
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
                            RecipeDetailView(
                                recipe: recipe,
                                viewModel: DataManager.shared.recipeViewModel
                            )
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
    }
    
    // Filter recipes based on selected category and search text
    private var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let categoryMatch: Bool
            if let selectedCategory = selectedCategory {
                categoryMatch = recipe.categoryArray.contains(selectedCategory)
            } else {
                categoryMatch = true
            }
            
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

// Recipe row component
struct RecipeRowView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 12) {
            // Recipe image or placeholder
            if let imageName = recipe.imageName, !imageName.isEmpty {
                AsyncImageView.asset(
                    imageName,
                    cornerRadius: Constants.UI.smallCornerRadius
                )
                .frame(width: 60, height: 60)
            } else {
                AsyncImageView.placeholder(
                    color: Color.blue.opacity(0.3),
                    text: recipe.name,
                    cornerRadius: Constants.UI.smallCornerRadius
                )
                .frame(width: 60, height: 60)
            }
            
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
                        Label("\(recipe.prepTime + recipe.cookTime) \(Constants.Text.recipeMinutesAbbreviation)", systemImage: Constants.Assets.clockIcon)
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
                Image(systemName: Constants.Assets.favoriteFilledIcon)
                    .foregroundColor(.red)
            }
        }
        .padding(.vertical, 4)
    }
}

// Favorites View
struct FavoritesView: View {
    @ObservedObject private var viewModel = DataManager.shared.favoriteViewModel
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView(message: "Loading favorites...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage) {
                    viewModel.loadFavorites()
                }
            } else if viewModel.favoriteRecipes.isEmpty {
                emptyFavoritesView
            } else {
                favoritesList
            }
        }
        .navigationTitle("Favorites")
        .onAppear {
            viewModel.loadFavorites()
        }
    }
    
    private var emptyFavoritesView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Tap the heart icon on any recipe to add it to your favorites")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var favoritesList: some View {
        List {
            ForEach(viewModel.favoriteRecipes, id: \.self) { recipe in
                NavigationLink {
                    RecipeDetailView(
                        recipe: recipe,
                        viewModel: DataManager.shared.recipeViewModel
                    )
                } label: {
                    RecipeRowView(recipe: recipe)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.toggleFavorite(recipe)
                    } label: {
                        Label("Remove", systemImage: "heart.slash")
                    }
                }
            }
        }
        .listStyle(InsetGroupedListStyle())
    }
}

// About View
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // App info header
                VStack(alignment: .center, spacing: 16) {
                    Image(systemName: "book.closed")
                        .font(.system(size: 60))
                        .foregroundColor(Color.ghGreen)
                    
                    Text("Ayewam")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Authentic Ghanaian Recipes")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 20)
                
                // App description
                Group {
                    Text("About Ayewam")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Ayewam is your guide to authentic Ghanaian cuisine, offering traditional recipes with step-by-step instructions. Explore the rich culinary heritage of Ghana through our carefully curated collection of dishes.")
                        .padding(.bottom, 8)
                    
                    Text("Whether you're looking to prepare Jollof Rice, Light Soup, or other Ghanaian classics, Ayewam provides you with the knowledge and guidance to create authentic dishes at home.")
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                // Ghanaian cuisine info
                Group {
                    Text("Ghanaian Cuisine")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text("Ghanaian cuisine is known for its flavorful stews, soups, and one-pot dishes. Key ingredients include plantains, cassava, yams, corn, beans, and various proteins. Dishes are often seasoned with aromatic spices and herbs.")
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    
                    // Ghana flag colors
                    HStack(spacing: 0) {
                        Color.ghRed
                        Color.ghYellow
                        Color.ghGreen
                    }
                    .frame(height: 20)
                    .cornerRadius(4)
                    .padding(.horizontal)
                }
                
                Divider()
                    .padding(.vertical)
                
                // App version and credits
                VStack(alignment: .center, spacing: 8) {
                    Text("Version 1.0")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("© 2025 Justyn Adusei-Prempeh")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 30)
            }
            .padding()
        }
        .navigationTitle("About")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
