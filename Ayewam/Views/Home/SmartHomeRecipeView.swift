//
//  SmartHomeRecipeView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/24/25.
//

import SwiftUI
import CoreData

struct SmartHomeRecipeView: View {
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
    @State private var recommendationSections: [RecommendationSection] = []
    @State private var isLoadingRecommendations = true
    
    private var timeOfDayIcon: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5...11:
            return "sun.horizon.fill"
        case 12...17:
            return "sun.max.fill"
        case 18...20:
            return "sunset.fill"
        default:
            return "moon.stars.fill"
        }
    }
    
    private var timeOfDayColor: Color {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5...11:
            return .orange
        case 12...17:
            return .yellow
        case 18...20:
            return .orange
        default:
            return .indigo
        }
    }
    
    private var recommendationEngine: ContextualRecommendationEngine {
        ContextualRecommendationEngine(context: viewContext)
    }
    
    init(initialCategory: Category? = nil) {
        self._selectedCategory = State(initialValue: initialCategory)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Time-based greeting
                greetingSection
                
                // Search bar
                searchSection
                
                // Smart recommendations section
                smartRecommendationsSection
                
                // Curated recipes section
                curatedSection
                
                // Categories section
                CategoriesSection
                
                // All recipes section
                allRecipesSection
            }
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        //TODO: justynx debugging delete
#if DEBUG
        .overlay(
            VStack {
                HStack {
                    Spacer()
                    Button("🔄") {
                        let seeder = RecipeSeeder(context: viewContext)
                        UserDefaults.standard.removeObject(forKey: "lastSeededVersion")
                        seeder.seedDefaultRecipesIfNeeded()
                        print("🌱 Debug: Re-seeded recipes")
                    }
                    .padding()
                    .background(Color.red.opacity(0.7))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                }
                .padding()
                Spacer()
            }
        )
#endif
        .background(
            // Dynamic gradient background
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemBackground).opacity(0.8),
                    Color(.systemGray6).opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
                loadSmartRecommendations()
                
                // ADD THE DEBUG CODE HERE
                #if DEBUG
                let count = try? viewContext.count(for: Recipe.fetchRequest())
                print("📊 Recipe count: \(count ?? 0)")
                
                let version = UserDefaults.standard.string(forKey: "lastSeededVersion") ?? "none"
                print("📱 Last seeded version: \(version)")
                #endif
            }
        .refreshable {
            await refreshRecommendations()
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(timeBasedGreeting)
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, .primary.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("What would you like to cook today?")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Time of day icon
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 44, height: 44)
                    .overlay(
                        Image(systemName: timeOfDayIcon)
                            .font(.system(size: 20))
                            .foregroundColor(timeOfDayColor)
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack(spacing: 16) {
            // Search field
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 18, weight: .medium))
                
                TextField("Search recipes...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16, weight: .medium))
                
                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            
            // Filter button
            Button(action: {
                // TODO: Implement filter functionality
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 52, height: 52)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.ultraThinMaterial)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Smart Recommendations Section
    private var smartRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            if isLoadingRecommendations {
                // Loading state
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Smart Suggestions")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundColor(.blue)
                            .symbolEffect(.variableColor.iterative)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    RecommendationLoadingView()
                }
            } else if recommendationSections.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Smart Suggestions")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Image(systemName: "sparkles")
                            .font(.title3)
                            .foregroundColor(.blue)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 24)
                    
                    RecommendationEmptyView()
                }
            } else {
                // Recommendations section
                VStack(alignment: .leading, spacing: 28) {
                    // Section header
                    HStack {
                        HStack(spacing: 8) {
                            Text("Smart Suggestions")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(.primary)
                            
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundColor(.blue)
                                .symbolEffect(.bounce, value: recommendationSections.count)
                        }
                        
                        Spacer()
                        
                        // Refresh button
                        Button(action: {
                            Task { await refreshRecommendations() }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .frame(width: 32, height: 32)
                                .background(
                                    Circle()
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Recommendation sections
                    ForEach(recommendationSections.indices, id: \.self) { index in
                        RecommendationSectionView(section: recommendationSections[index])
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: recommendationSections.count)
                    }
                }
            }
        }
    }
    
    // MARK: - Curated Section
    private var curatedSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(curatedSectionTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Perfectly timed for you")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // TODO: Show all curated recipes
                }) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(curatedRecipes, id: \.self) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                        } label: {
                            CuratedCard(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                        .onTapGesture {
                            if let recipeId = recipe.id {
                                UserDefaults.standard.addRecentlyViewedRecipe(recipeId)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Categories Section
    private var CategoriesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Browse by Category")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Explore Ghanaian cuisine")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {
                    // TODO: Show all categories
                }) {
                    HStack(spacing: 4) {
                        Text("See All")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                selectedCategory = (selectedCategory == category) ? nil : category
                            }
                        }) {
                            ModernCategoryCard(
                                category: category,
                                isSelected: selectedCategory == category
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - All Recipes Section
    private var allRecipesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text("All Recipes")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(filteredRecipes.count) recipes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            
            LazyVStack(spacing: 20) {
                ForEach(filteredRecipes, id: \.self) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                    } label: {
                        RecipeCard(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                    .onTapGesture {
                        if let recipeId = recipe.id {
                            UserDefaults.standard.addRecentlyViewedRecipe(recipeId)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Smart Recommendations Logic
    private func loadSmartRecommendations() {
        isLoadingRecommendations = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let sections = recommendationEngine.getRecommendations()
            
            withAnimation(.easeInOut(duration: 0.4)) {
                self.recommendationSections = sections
                self.isLoadingRecommendations = false
            }
        }
    }
    
    @MainActor
    private func refreshRecommendations() async {
        withAnimation(.easeInOut(duration: 0.2)) {
            isLoadingRecommendations = true
        }
        
        try? await Task.sleep(nanoseconds: 400_000_000)
        
        let sections = recommendationEngine.getRecommendations()
        
        withAnimation(.easeInOut(duration: 0.4)) {
            self.recommendationSections = sections
            self.isLoadingRecommendations = false
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
            return allRecipes.filter { recipe in
                let name = recipe.name?.lowercased() ?? ""
                return name.contains("tea") || name.contains("bread") ||
                name.contains("porridge") || name.contains("pancake") ||
                name.contains("koko") || name.contains("bofrot") ||
                recipe.prepTime + recipe.cookTime <= 20
            }.prefix(5).map { $0 }
        case 12...14:
            return allRecipes.filter { recipe in
                let totalTime = recipe.prepTime + recipe.cookTime
                return totalTime > 20 && totalTime <= 45
            }.prefix(5).map { $0 }
        case 17...21:
            return allRecipes.filter { recipe in
                let name = recipe.name?.lowercased() ?? ""
                return name.contains("soup") || name.contains("stew") ||
                name.contains("rice") || name.contains("fufu")
            }.prefix(5).map { $0 }
        default:
            return allRecipes.filter { recipe in
                recipe.prepTime + recipe.cookTime <= 30
            }.prefix(5).map { $0 }
        }
    }
    
    private var filteredRecipes: [Recipe] {
        recipes.filter { recipe in
            let categoryMatch: Bool
            if let selectedCategory = selectedCategory {
                categoryMatch = recipe.categoryArray.contains(selectedCategory)
            } else {
                categoryMatch = true
            }
            
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
