//
//  ContentView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView { HomeRecipeView() }
                    .tag(0)

                NavigationView { CategoryListView() }
                    .tag(1)

                NavigationView { FavoritesView() }
                    .tag(2)

                NavigationView { AboutView() }
                    .tag(3)
            }

            HStack {
                ForEach(0..<4) { index in
                    Button(action: {
                        selectedTab = index
                    }) {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(selectedTab == index ? .white : .gray)
                            .frame(width: 44, height: 44)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(selectedTab == index ? Color.accentColor : Color.clear)
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding(.horizontal)
        }
        .ignoresSafeArea(.keyboard)
    }

    func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "book"
        case 1: return "square.grid.2x2"
        case 2: return "heart"
        case 3: return "info.circle"
        default: return "questionmark"
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
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Time-based greeting section
                timeBasedGreetingSection
                
                // Search and filter section
                searchAndFilterSection
                
                // Curated recipes for time of day
                curatedRecipesSection
                
                // Categories section with icons
                categoriesSection
                
                // All recipes section
                allRecipesSection
            }
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Time-based Greeting
    private var timeBasedGreetingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(timeBasedGreeting)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("What would you like to cook today?")
                .font(.title3)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
    
    // MARK: - Search and Filter Section
    private var searchAndFilterSection: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField("Search recipes...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            
            // Filter button (placeholder for now)
            Button(action: {
                // TODO: Implement filter functionality
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                    )
            }
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Curated Recipes Section
    private var curatedRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(curatedSectionTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // TODO: Show all curated recipes
                }) {
                    Text("See All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(curatedRecipes, id: \.self) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                        } label: {
                            CuratedRecipeCard(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - Categories Section
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Browse by Category")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    // TODO: Show all categories
                }) {
                    Text("See All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            selectedCategory = (selectedCategory == category) ? nil : category
                        }) {
                            HorizontalCategoryCard(
                                category: category,
                                isSelected: selectedCategory == category
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
    
    // MARK: - All Recipes Section
    private var allRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("All Recipes")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .padding(.horizontal, 20)
            
            LazyVStack(spacing: 16) {
                ForEach(filteredRecipes, id: \.self) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                    } label: {
                        ModernRecipeCard(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    // MARK: - Computed Properties
    private var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5...11:
            return "Good Morning"
        case 12...17:
            return "Good Afternoon"
        default:
            return "Good Evening"
        }
    }
    
    private var curatedSectionTitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5...11:
            return "Breakfast Favorites"
        case 12...14:
            return "Lunch Specials"
        case 17...21:
            return "Dinner Classics"
        default:
            return "Quick Bites"
        }
    }
    
    private var curatedRecipes: [Recipe] {
        let hour = Calendar.current.component(.hour, from: Date())
        let allRecipes = Array(recipes)
        
        switch hour {
        case 5...11:
            // Morning - lighter dishes, breakfast items
            return allRecipes.filter { recipe in
                let name = recipe.name?.lowercased() ?? ""
                return name.contains("tea") || name.contains("bread") ||
                       name.contains("porridge") || name.contains("pancake") ||
                       recipe.prepTime + recipe.cookTime <= 20
            }.prefix(5).map { $0 }
        case 12...14:
            // Lunch - medium prep time dishes
            return allRecipes.filter { recipe in
                let totalTime = recipe.prepTime + recipe.cookTime
                return totalTime > 20 && totalTime <= 45
            }.prefix(5).map { $0 }
        case 17...21:
            // Dinner - heartier dishes, soups, stews
            return allRecipes.filter { recipe in
                let name = recipe.name?.lowercased() ?? ""
                return name.contains("soup") || name.contains("stew") ||
                       name.contains("rice") || name.contains("fufu")
            }.prefix(5).map { $0 }
        default:
            // Late night - quick and easy
            return allRecipes.filter { recipe in
                recipe.prepTime + recipe.cookTime <= 30
            }.prefix(5).map { $0 }
        }
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

// MARK: - Supporting Views

struct CuratedRecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe image
            if let imageName = recipe.imageName, !imageName.isEmpty {
                AsyncImageView.asset(imageName, cornerRadius: 16)
                    .frame(width: 180, height: 120)
                    .clipped()
            } else {
                AsyncImageView.placeholder(
                    color: Color.accentColor.opacity(0.3),
                    text: recipe.name,
                    cornerRadius: 16
                )
                .frame(width: 180, height: 120)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name ?? "Unknown Recipe")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    if recipe.prepTime > 0 || recipe.cookTime > 0 {
                        Label("\(recipe.prepTime + recipe.cookTime) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                        Text("• \(difficulty)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.top, 12)
        }
        .frame(width: 180)
    }
}

struct ModernCategoryCard: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                Circle()
                    .fill(Color(hex: category.colorHex ?? "#767676").opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: categoryIcon(for: category.name ?? ""))
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(Color(hex: category.colorHex ?? "#767676"))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.name ?? "Unknown")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("\(recipeCount(for: category)) recipes")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
        )
    }
    
    private func categoryIcon(for categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "soups":
            return "drop.circle"
        case "stews":
            return "flame"
        case "rice dishes":
            return "circle.grid.3x3"
        case "street food":
            return "cart"
        case "breakfast":
            return "sun.horizon"
        case "desserts":
            return "heart.circle"
        case "drinks":
            return "cup.and.saucer"
        case "sides":
            return "square.3.layers.3d"
        default:
            return "fork.knife"
        }
    }
    
    private func recipeCount(for category: Category) -> Int {
        return category.recipes?.count ?? 0
    }
}

struct ModernRecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 16) {
            // Recipe image
            if let imageName = recipe.imageName, !imageName.isEmpty {
                AsyncImageView.asset(imageName, cornerRadius: 12)
                    .frame(width: 80, height: 80)
                    .clipped()
            } else {
                AsyncImageView.placeholder(
                    color: Color.accentColor.opacity(0.3),
                    text: recipe.name,
                    cornerRadius: 12
                )
                .frame(width: 80, height: 80)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name ?? "Unknown Recipe")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let description = recipe.recipeDescription, !description.isEmpty {
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack(spacing: 12) {
                    if recipe.prepTime > 0 || recipe.cookTime > 0 {
                        Label("\(recipe.prepTime + recipe.cookTime) min", systemImage: "clock")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                        Label(difficulty, systemImage: "speedometer")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                    }
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

struct HorizontalCategoryCard: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // Category icon
            Image(systemName: categoryIcon(for: category.name ?? ""))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? .white : Color(hex: category.colorHex ?? "#767676"))
            
            Text(category.name ?? "Unknown")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            Capsule()
                .fill(isSelected ? Color(hex: category.colorHex ?? "#767676") : Color(.systemGray6))
        )
    }
    
    private func categoryIcon(for categoryName: String) -> String {
        switch categoryName.lowercased() {
        case "soups":
            return "drop.circle"
        case "stews":
            return "flame"
        case "rice dishes":
            return "circle.grid.3x3"
        case "street food":
            return "cart"
        case "breakfast":
            return "sun.horizon"
        case "desserts":
            return "heart.circle"
        case "drinks":
            return "cup.and.saucer"
        case "sides":
            return "square.3.layers.3d"
        default:
            return "fork.knife"
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

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageName = recipe.imageName, !imageName.isEmpty {
                AsyncImageView.asset(imageName, cornerRadius: 12)
                    .frame(height: 180)
                    .clipped()
            } else {
                AsyncImageView.placeholder(
                    color: Color.blue.opacity(0.3),
                    text: recipe.name,
                    cornerRadius: 12
                )
                .frame(height: 180)
            }

            Text(recipe.name ?? "Unknown")
                .font(.headline)

            if let desc = recipe.recipeDescription, !desc.isEmpty {
                Text(desc)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack {
                if recipe.prepTime > 0 || recipe.cookTime > 0 {
                    Label("\(recipe.prepTime + recipe.cookTime) min", systemImage: Constants.Assets.clockIcon)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if recipe.isFavorite {
                    Image(systemName: Constants.Assets.favoriteFilledIcon)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}
