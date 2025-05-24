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
                NavigationView {
                    SmartHomeRecipeView()
                }
                .tag(0)

                NavigationView { CategoryListView() }
                    .tag(1)

                NavigationView { FavoritesView() }
                    .tag(2)

                NavigationView { AboutView() }
                    .tag(3)
            }

            // Tab Bar
            TabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }

    func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "book.closed.fill"
        case 1: return "square.grid.2x2.fill"
        case 2: return "heart.fill"
        case 3: return "info.circle.fill"
        default: return "questionmark"
        }
    }
    
    func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Recipes"
        case 1: return "Categories"
        case 2: return "Favorites"
        case 3: return "About"
        default: return ""
        }
    }
}

// MARK: - Smart Home Recipe View (Enhanced with Modern Design)

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
    
    private var recommendationEngine: ContextualRecommendationEngine {
        ContextualRecommendationEngine(context: viewContext)
    }
    
    init(initialCategory: Category? = nil) {
        self._selectedCategory = State(initialValue: initialCategory)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // ENHANCED: Modern time-based greeting with gradient
                modernGreetingSection
                
                // ENHANCED: Modern search bar with glassmorphism
                modernSearchSection
                
                // ENHANCED: Smart recommendations with improved design
                smartRecommendationsSection
                
                // ENHANCED: Modern curated recipes section
                modernCuratedSection
                
                // ENHANCED: Categories with improved cards
                modernCategoriesSection
                
                // ENHANCED: All recipes with modern card design
                modernAllRecipesSection
            }
            .padding(.top, 8)
        }
        .navigationBarHidden(true)
        .background(
            // ENHANCED: Dynamic gradient background
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
        }
        .refreshable {
            await refreshRecommendations()
        }
    }
    
    // MARK: - Modern Greeting Section
    private var modernGreetingSection: some View {
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
                
                // ENHANCED: Profile/Settings icon with modern styling
                Button(action: {
                    // TODO: Profile action
                }) {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - Modern Search Section
    private var modernSearchSection: some View {
        HStack(spacing: 16) {
            // ENHANCED: Modern search field with glassmorphism
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
            
            // ENHANCED: Modern filter button
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
    
    // MARK: - Smart Recommendations Section (Enhanced)
    private var smartRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            if isLoadingRecommendations {
                // Enhanced loading state
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
                // ENHANCED: Recommendations content with modern styling
                VStack(alignment: .leading, spacing: 28) {
                    // Section header with improved styling
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
                        
                        // Enhanced refresh button
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
                    
                    // Recommendation sections with staggered animation
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
    
    // MARK: - Modern Curated Section
    private var modernCuratedSection: some View {
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
    
    // MARK: - Modern Categories Section
    private var modernCategoriesSection: some View {
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
    
    // MARK: - Modern All Recipes Section
    private var modernAllRecipesSection: some View {
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
        }
    }
    
    // MARK: - Smart Recommendations Logic (unchanged)
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
    
    // MARK: - Computed Properties (unchanged logic, but will enhance the cards)
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

// MARK: - Favorites and About Views (Enhanced)

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
                modernEmptyFavoritesView
            } else {
                modernFavoritesList
            }
        }
        .navigationTitle("Favorites")
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
            viewModel.loadFavorites()
        }
    }
    
    private var modernEmptyFavoritesView: some View {
        VStack(spacing: 24) {
            // ENHANCED: Modern empty state with gradient and animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.red.opacity(0.1), Color.pink.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
                
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red.opacity(0.7), .pink.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, options: .repeat(.continuous))
            }
            
            VStack(spacing: 12) {
                Text("No Favorites Yet")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                
                Text("Tap the heart icon on any recipe to add it to your favorites")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .lineSpacing(2)
            }
            
            // ENHANCED: Call-to-action button with modern styling
            NavigationLink(destination: SmartHomeRecipeView()) {
                HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Explore Recipes")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.red, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: .red.opacity(0.4), radius: 12, x: 0, y: 6)
                )
            }
            .padding(.top, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var modernFavoritesList: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                // ENHANCED: Header with count and animation
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Your Favorites")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Text("\(viewModel.favoriteRecipes.count) saved recipes")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // ENHANCED: Animated heart count
                    HStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.red)
                            .symbolEffect(.pulse)
                        
                        Text("\(viewModel.favoriteRecipes.count)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                
                ForEach(Array(viewModel.favoriteRecipes.enumerated()), id: \.element) { index, recipe in
                    NavigationLink {
                        RecipeDetailView(
                            recipe: recipe,
                            viewModel: DataManager.shared.recipeViewModel
                        )
                    } label: {
                        ModernFavoriteCard(recipe: recipe) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                viewModel.toggleFavorite(recipe)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .scale)
                    ))
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.05), value: viewModel.favoriteRecipes.count)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100) // Extra padding for tab bar
        }
    }
}


struct AboutView: View {
    @State private var showCredits = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                // ENHANCED: Hero section with animated elements
                VStack(alignment: .center, spacing: 24) {
                    ZStack {
                        // ENHANCED: Animated background circles
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.ghGreen.opacity(0.15), Color.ghYellow.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: true)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.ghRed.opacity(0.1), Color.ghYellow.opacity(0.1)],
                                    startPoint: .bottomLeading,
                                    endPoint: .topTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(0.9)
                            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: true)
                        
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.ghGreen, Color.ghYellow, Color.ghRed],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.bounce, options: .repeat(.periodic(delay: 3.0)))
                    }
                    
                    VStack(spacing: 12) {
                        Text("Ayewam")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Authentic Ghanaian Recipes")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
                
                // ENHANCED: Feature highlights with modern cards
                VStack(spacing: 20) {
                    ModernFeatureCard(
                        title: "About Ayewam",
                        description: "Ayewam is your guide to authentic Ghanaian cuisine, offering traditional recipes with step-by-step instructions. Explore the rich culinary heritage of Ghana through our carefully curated collection of dishes.",
                        icon: "info.circle.fill",
                        gradientColors: [.blue, .cyan]
                    )
                    
                    ModernFeatureCard(
                        title: "Smart Cooking",
                        description: "Experience guided cooking with integrated timers, step-by-step instructions, and personalized recipe recommendations based on your preferences and cooking history.",
                        icon: "brain.head.profile",
                        gradientColors: [.purple, .pink]
                    )
                    
                    ModernFeatureCard(
                        title: "Ghanaian Cuisine",
                        description: "Discover the rich flavors of Ghana with our collection of traditional stews, soups, and one-pot dishes. Learn about key ingredients like plantains, cassava, yams, and aromatic spices.",
                        icon: "globe.africa.fill",
                        gradientColors: [.green, .mint]
                    )
                }
                
                // ENHANCED: Ghana flag section with animation
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Republic of Ghana")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    // ENHANCED: Animated Ghana flag
                    HStack(spacing: 0) {
                        Color.ghRed
                        Color.ghYellow
                        Color.ghGreen
                    }
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Text("The colors represent the mineral wealth (gold), forests and agriculture (green), and the blood of those who fought for independence (red).")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 24)
                                .stroke(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                )
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                
                Spacer(minLength: 40)
                
                // ENHANCED: Credits section with tap interaction
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showCredits.toggle()
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text("Made with ❤️ in Ghana")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 4) {
                                Text("Tap to view credits")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: showCredits ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if showCredits {
                        VStack(spacing: 8) {
                            Text("Version 1.0")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("© 2025 Justyn Adusei-Prempeh")
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.tertiaryLabel))

                            Text("Built with SwiftUI & Core Data")
                                .font(.system(size: 12))
                                .foregroundColor(Color(UIColor.quaternaryLabel))
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 100) // Extra padding for tab bar
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .navigationTitle("About")
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.2),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

struct ModernFeatureCard: View {
    let title: String
    let description: String
    let icon: String
    let gradientColors: [Color]
    @State private var isHovered = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: gradientColors.map { $0.opacity(0.15) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(
                            LinearGradient(
                                colors: gradientColors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                Text(title)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            Text(description)
                .font(.system(size: 16))
                .foregroundColor(.secondary)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: isHovered ? 16 : 12, x: 0, y: isHovered ? 8 : 6)
        .scaleEffect(isHovered ? 1.02 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isHovered)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.1)) {
                isHovered = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isHovered = false
                }
            }
        }
    }
}

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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
