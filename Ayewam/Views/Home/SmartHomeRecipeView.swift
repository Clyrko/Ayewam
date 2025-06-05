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
    @State private var showingRecipeSubmission = false
    @State private var stableRecommendations: [Recipe] = []
    @State private var isRefreshing = false
    
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
            return Color("GhanaGold")
        case 12...17:
            return Color("WarmRed")
        case 18...20:
            return Color("ForestGreen")
        default:
            return Color("KenteGold")
        }
    }
    
    
    private var pullToRefreshBinding: Binding<Bool> {
        Binding(
            get: { isRefreshing },
            set: { newValue in
                if !newValue && isRefreshing {
                    // Refresh completed
                    isRefreshing = false
                }
            }
        )
    }
    
    private var todaysHeroRecipe: Recipe? {
        let hour = Calendar.current.component(.hour, from: Date())
        let allRecipes = Array(recipes)
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        
        var filteredRecipes: [Recipe]
        
        switch hour {
        case 5...11:
            // Breakfast recipes
            filteredRecipes = allRecipes.filter { recipe in
                let name = recipe.name?.lowercased() ?? ""
                return name.contains("tea") || name.contains("bread") ||
                name.contains("porridge") || name.contains("pancake") ||
                name.contains("koko") || name.contains("bofrot") ||
                recipe.prepTime + recipe.cookTime <= 20
            }
        case 12...14:
            // Lunch recipes
            filteredRecipes = allRecipes.filter { recipe in
                let totalTime = recipe.prepTime + recipe.cookTime
                return totalTime > 20 && totalTime <= 45
            }
        case 17...21:
            // Dinner recipes
            filteredRecipes = allRecipes.filter { recipe in
                let name = recipe.name?.lowercased() ?? ""
                return name.contains("soup") || name.contains("stew") ||
                name.contains("rice") || name.contains("fufu")
            }
        default:
            // Quick bites
            filteredRecipes = allRecipes.filter { recipe in
                recipe.prepTime + recipe.cookTime <= 30
            }
        }
        
        // If no filtered recipes, use all recipes
        if filteredRecipes.isEmpty {
            filteredRecipes = allRecipes
        }
        
        // Pick recipe based on day of year
        guard !filteredRecipes.isEmpty else { return nil }
        let index = (dayOfYear - 1) % filteredRecipes.count
        return filteredRecipes[index]
    }
    
    private var heroRecipeSubtitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5...11:
            return "Perfect for breakfast"
        case 12...14:
            return "Great for lunch"
        case 17...21:
            return "Tonight's dinner inspiration"
        default:
            return "Quick and easy option"
        }
    }
    
    private var todayDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: Date()).uppercased()
    }
    
    private var todayDayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: Date())
    }
    
    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init() {
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Time-based greeting
                greetingSection
                
                // Search bar
                searchSection
                    .padding(.top, 16)
                
                if isSearching {
                    // SEARCH MODE: Only show search results
                    if searchResults.isEmpty {
                        searchResultsSection
                            .padding(.top, 24)
                    } else {
                        searchResultsSection
                            .padding(.top, 24)
                    }
                } else {
                    // BROWSE MODE: Show all sections
                    Group {
                        // Recipe of the Day Section
                        if selectedCategory == nil {
                            if recipes.isEmpty {
                                LoadingView(message: "Loading today's featured recipe...", style: .hero)
                                    .padding(.top, 32)
                            } else {
                                recipeOfTheDayHero
                                    .padding(.top, 32)
                                
                                // Smart recommendations
                                if recipes.isEmpty {
                                    recommendationsLoadingState
                                        .padding(.top, 28)
                                } else {
                                    smartRecommendationsSection
                                        .padding(.top, 28)
                                }
                            }
                        }
                        
                        // Categories section
                        if categories.isEmpty {
                            categoriesLoadingState
                                .padding(.top, selectedCategory == nil ? 24 : 20)
                        } else {
                            CategoriesSection
                                .padding(.top, selectedCategory == nil ? 24 : 20)
                        }
                        
                        // All recipes section
                        if recipes.isEmpty {
                            LoadingView(message: "Loading authentic Ghanaian recipes...", style: .cards)
                                .padding(.top, 16)
                        } else {
                            filteredRecipesSection
                                .padding(.top, 16)
                        }
                    }
                }
            }
            .padding(.top, 8)
        }
        .refreshable {
            await performRefresh()
        }
        .navigationBarHidden(true)
        .overlay(
            // Refresh indicator
            VStack {
                if isRefreshing {
                    HStack(spacing: 12) {
                        PulsingCircle()
                            .frame(width: 16, height: 16)
                        
                        Text("Refreshing recipes...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.top, 8)
                }
                
                Spacer()
            }
                .allowsHitTesting(false)
        )
        //TODO: justynx debugging delete
//#if DEBUG
//        .overlay(
//            VStack {
//                HStack {
//                    Spacer()
//                    Button("🔄") {
//                        let seeder = RecipeSeeder(context: viewContext)
//                        UserDefaults.standard.removeObject(forKey: "lastSeededVersion")
//                        seeder.seedDefaultRecipesIfNeeded()
//                        print("🌱 Debug: Re-seeded recipes")
//                    }
//                    .padding()
//                    .background(Color.red.opacity(0.7))
//                    .foregroundColor(.white)
//                    .clipShape(Circle())
//                }
//                .padding()
//                Spacer()
//            }
//        )
//#endif
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color("SectionBackground").opacity(0.3),
                    Color("CardBackground").opacity(0.1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .onAppear {
//#if DEBUG
//            let count = try? viewContext.count(for: Recipe.fetchRequest())
//            print("📊 Recipe count: \(count ?? 0)")
//            
//            let version = UserDefaults.standard.string(forKey: "lastSeededVersion") ?? "none"
//            print("📱 Last seeded version: \(version)")
//#endif
        }
        .toast(position: .top)
        .sheet(isPresented: $showingRecipeSubmission) {
            RecipeSubmissionView(prefilledRecipeName: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }
    
    // MARK: - Recipe of the Day Hero
    private var recipeOfTheDayHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recipe of the Day")
                        .displaySmall()
                        .foregroundColor(.primary)
                    
                    Text(heroRecipeSubtitle)
                        .bodyMedium()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Day indicator
                VStack {
                    Text(todayDayName)
                        .labelSmall()
                        .foregroundColor(Color("GhanaGold"))
                    
                    Text(todayDayNumber)
                        .headingLarge()
                        .foregroundColor(Color("GhanaGold"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color("GhanaGold").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color("GhanaGold").opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .padding(.horizontal, 24)
            
            // Hero recipe card
            if let heroRecipe = todaysHeroRecipe {
                NavigationLink {
                    RecipeDetailView(recipe: heroRecipe, viewModel: DataManager.shared.recipeViewModel)
                } label: {
                    SimpleHeroCard(recipe: heroRecipe)
                }
                .buttonStyle(.plain)
                .onTapGesture {
                    HapticFeedbackManager.shared.recipeTapped()
                    if let recipeId = heroRecipe.id {
                        UserDefaults.standard.addRecentlyViewedRecipe(recipeId)
                    }
                }
                .padding(.horizontal, 24)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 32))
                        .foregroundColor(.secondary)
                    
                    Text("No recipe selected for today")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 24)
            }
        }
    }
    
    // MARK: - Hero Card Component
    struct SimpleHeroCard: View {
        let recipe: Recipe
        @State private var isPressed = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Image section
                ZStack(alignment: .bottomLeading) {
                    if let imageName = recipe.imageName, !imageName.isEmpty {
                        AsyncImageView.asset(imageName)
                            .frame(height: 180)
                            .clipped()
                    } else {
                        AsyncImageView.placeholder(
                            color: Color("GhanaGold").opacity(0.3),
                            text: recipe.name
                        )
                        .frame(height: 180)
                    }
                    
                    // Gradient overlay
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 120)
                    
                    // Overlay content
                    VStack(alignment: .leading, spacing: 12) {
                        // Category and difficulty badges
                        HStack(spacing: 8) {
                            if !recipe.categoryName.isEmpty && recipe.categoryName != "Uncategorized" {
                                CategoryBadge(
                                    name: recipe.categoryName,
                                    color: Color(hex: recipe.categoryColorHex)
                                )
                            }
                            
                            if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                                DifficultyBadge(difficulty: difficulty)
                            }
                            
                            Spacer()
                            
                            // Favorite indicator
                            if recipe.isFavorite {
                                ZStack {
                                    Circle()
                                        .fill(.red.opacity(0.2))
                                        .frame(width: 36, height: 36)
                                        .blur(radius: 6)
                                    
                                    Image(systemName: "heart.fill")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 32, height: 32)
                                        .background(
                                            Circle()
                                                .fill(.red)
                                                .shadow(color: .red.opacity(0.5), radius: 4, x: 0, y: 2)
                                        )
                                }
                            }
                        }
                        
                        // Recipe title
                        Text(recipe.name ?? "Unknown Recipe")
                            .font(.system(size: 24, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                    .padding(20)
                }
                .cornerRadius(24, corners: [.topLeft, .topRight])
                
                // Info section
                VStack(alignment: .leading, spacing: 16) {
                    // Description
                    if let description = recipe.recipeDescription, !description.isEmpty {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(3)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    // Metadata section
                    HStack(spacing: 0) {
                        // Time metadata
                        if recipe.prepTime > 0 || recipe.cookTime > 0 {
                            MetadataItem(
                                icon: "clock.fill",
                                value: "\(recipe.prepTime + recipe.cookTime)",
                                unit: "min",
                                color: .blue
                            )
                            
                            if recipe.servings > 0 {
                                Divider()
                                    .frame(height: 40)
                                    .padding(.horizontal, 16)
                            }
                        }
                        
                        // Servings metadata
                        if recipe.servings > 0 {
                            MetadataItem(
                                icon: "person.2.fill",
                                value: "\(recipe.servings)",
                                unit: recipe.servings == 1 ? "serving" : "servings",
                                color: .orange
                            )
                        }
                        
                        Spacer()
                        
                        // Call to action indicator
                        HStack(spacing: 8) {
                            Text("Start Cooking")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color("GhanaGold"))
                            
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(Color("GhanaGold"))
                        }
                    }
                }
                .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color("GhanaGold").opacity(0.4),
                                        Color("KenteGold").opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
            )
            .shadow(
                color: isPressed ? Color("GhanaGold").opacity(0.3) : Color.black.opacity(0.15),
                radius: isPressed ? 12 : 20,
                x: 0,
                y: isPressed ? 6 : 10
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isPressed)
        }
    }
    
    struct CategoryBadge: View {
        let name: String
        let color: Color
        
        var body: some View {
            Text(name)
                .badgeText()
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(color)
                        .shadow(color: color.opacity(0.4), radius: 2, x: 0, y: 1)
                )
        }
    }
    
    struct DifficultyBadge: View {
        let difficulty: String
        
        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: "speedometer")
                    .font(.system(size: 10))
                Text(difficulty)
                    .badgeText()
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    struct MetadataItem: View {
        let icon: String
        let value: String
        let unit: String
        let color: Color
        
        var body: some View {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(value)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Greeting Section
    private var greetingSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                // Twi greeting with cultural context
                VStack(alignment: .leading, spacing: 4) {
                    Text(timeBasedTwiGreeting)
                        .cultural()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, Color("GhanaGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                }
                
                // Cultural context subtitle
                Text(culturalContextSubtitle)
                    .bodyLarge()
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Time of day icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                timeOfDayColor.opacity(0.1),
                                .clear
                            ],
                            center: .center,
                            startRadius: 5,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(timeOfDayColor.opacity(0.4), lineWidth: 2)
                    )
                    .shadow(color: timeOfDayColor.opacity(0.3), radius: 6, x: 0, y: 3)
                
                Image(systemName: timeOfDayIcon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(timeOfDayColor)
                    .symbolEffect(.variableColor.iterative, options: .repeat(.periodic(delay: 3.0)))
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
    
    // MARK: - Computed Properties
    private var timeBasedTwiGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5...11:
            return "Maakye!"
        case 12...17:
            return "Maaha!"
        default:
            return "Maadwo!"
        }
    }
    
    private var culturalContextSubtitle: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let isWeekend = Calendar.current.isDateInWeekend(Date())
        
        switch hour {
        case 5...11:
            return isWeekend ?
            "Perfect for tea bread or bofrot" :
            "Ready for koko or porridge?"
        case 12...17:
            return isWeekend ?
            "Time for jollof or waakye" :
            "What delicious dish awaits?"
        default:
            return isWeekend ?
            "Evening soup and fufu time" :
            "Perfect for a warm meal"
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        HStack(spacing: 12) {
            // Search field
            HStack(spacing: 14) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(searchText.isEmpty ? .secondary : Color("GhanaGold"))
                    .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
                
                TextField("Search recipes...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .bodyMedium()
                    .submitLabel(.search)
                
                if !searchText.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            searchText = ""
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                searchText.isEmpty ?
                                Color.gray.opacity(0.2) :
                                    Color("GhanaGold").opacity(0.4),
                                lineWidth: 1.5
                            )
                            .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
                    )
            )
            .shadow(
                color: searchText.isEmpty ?
                Color.black.opacity(0.05) :
                    Color("GhanaGold").opacity(0.1),
                radius: searchText.isEmpty ? 2 : 4,
                x: 0,
                y: searchText.isEmpty ? 1 : 2
            )
            .animation(.easeInOut(duration: 0.2), value: searchText.isEmpty)
            
            // Filter button
            Button(action: {
                // TODO: justynx Implement filter functionality
            }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            .frame(width: 48, height: 48)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .padding(.horizontal, 24)
    }
    
    private var searchResultsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Search results header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Search Results")
                        .displaySmall()
                        .foregroundColor(.primary)
                    
                    Text("Found \(searchResults.count) recipe\(searchResults.count == 1 ? "" : "s") for \"\(searchText.trimmingCharacters(in: .whitespacesAndNewlines))\"")
                        .bodyMedium()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Clear search button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        searchText = ""
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "xmark")
                            .font(.system(size: 12, weight: .medium))
                        Text("Clear")
                            .labelMedium() 
                    }
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Capsule()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
            .padding(.horizontal, 24)
            
            // Search results or empty state
            if searchResults.isEmpty {
                searchEmptyState
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(searchResults, id: \.self) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                        } label: {
                            RecipeCard(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                        .onTapGesture {
                            HapticFeedbackManager.shared.recipeTapped()
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
    }
    
    private var searchResults: [Recipe] {
        let trimmedSearch = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSearch.isEmpty else { return [] }
        
        return recipes.filter { recipe in
            let nameMatch = recipe.name?.localizedCaseInsensitiveContains(trimmedSearch) ?? false
            let descMatch = recipe.recipeDescription?.localizedCaseInsensitiveContains(trimmedSearch) ?? false
            return nameMatch || descMatch
        }
    }
    
    // Search Empty State
    private var searchEmptyState: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                
                Text("No recipes found")
                    .font(.headline)
                
                Text("Try a different search term or check the spelling")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            recipeSubmissionPrompt
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
    }
    
    // MARK: - Smart Recommendations Section
    private var smartRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommended for You")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(recommendationsSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Refresh button
                //TODO: justynx readd this later
                //                Button(action: {
                //                    refreshRecommendations()
                //                }) {
                //                    Image(systemName: "arrow.clockwise")
                //                        .font(.system(size: 16, weight: .medium))
                //                        .foregroundColor(.secondary)
                //                        .frame(width: 32, height: 32)
                //                        .background(
                //                            Circle()
                //                                .fill(.ultraThinMaterial)
                //                                .overlay(
                //                                    Circle()
                //                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                //                                )
                //                        )
                //                }
            }
            .padding(.horizontal, 24)
            
            // Horizontal scroll of recommendations
            if stableRecommendations.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { index in
                            RecommendationCardSkeleton()
                                .opacity(1.0 - (Double(index) * 0.1))
                                .animation(
                                    .easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.3),
                                    value: true
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                }
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(stableRecommendations, id: \.self) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                            } label: {
                                CuratedCard(recipe: recipe)
                            }
                            .buttonStyle(.plain)
                            .onTapGesture {
                                HapticFeedbackManager.shared.recipeTapped()
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
        .onAppear {
            if !recipes.isEmpty && stableRecommendations.isEmpty {
                loadRecommendations()
            }
        }
        .onChange(of: recipes.count) { _, newCount in
            if newCount > 0 && stableRecommendations.isEmpty {
                loadRecommendations()
            }
        }
    }
    
    private func loadRecommendations() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.3)) {
                stableRecommendations = generatePersonalizedRecommendations()
            }
        }
    }
    
    // Refresh recommendations
    private func refreshRecommendations() {
        let newDayRecipe = generateNewHeroRecipe()
        
        withAnimation(.easeInOut(duration: 0.3)) {
            stableRecommendations = generatePersonalizedRecommendations()
        }
    }
    
    private func generatePersonalizedRecommendations() -> [Recipe] {
        let recentlyViewed = UserDefaults.standard.stringArray(forKey: "recentlyViewedRecipes") ?? []
        let allRecipes = Array(recipes)
        
        if recentlyViewed.isEmpty {
            let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
            var generator = SystemRandomNumberGenerator()
            
            let shuffledRecipes = allRecipes.shuffled(using: &generator)
            let startIndex = (dayOfYear * 3) % max(1, allRecipes.count - 5)
            let endIndex = min(startIndex + 5, allRecipes.count)
            
            return Array(shuffledRecipes[startIndex..<endIndex])
        }
        
        let recentRecipes = recentlyViewed.compactMap { id in
            allRecipes.first { $0.id == id }
        }
        
        let recentCategories = Set(recentRecipes.flatMap { $0.categoryArray })
        
        let behaviorBasedRecipes = allRecipes.filter { recipe in
            !recentlyViewed.contains(recipe.id ?? "") &&
            !Set(recipe.categoryArray).intersection(recentCategories).isEmpty
        }
        
        if behaviorBasedRecipes.isEmpty {
            let randomRecipes = allRecipes.filter { !recentlyViewed.contains($0.id ?? "") }
            return Array(randomRecipes.prefix(5))
        }
        
        return Array(behaviorBasedRecipes.prefix(5))
    }
    
    private var recommendationsSubtitle: String {
        let recentlyViewed = UserDefaults.standard.stringArray(forKey: "recentlyViewedRecipes") ?? []
        return recentlyViewed.isEmpty ? "Discover something new" : "Based on your cooking history"
    }
    
    // MARK: - Categories Section
    private var CategoriesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedCategory == nil ? "Browse by Category" : "Categories")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(categorySubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Clear filter button
                if selectedCategory != nil {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            selectedCategory = nil
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: "xmark")
                                .font(.system(size: 12, weight: .medium))
                            Text("Clear")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Capsule()
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            HapticFeedbackManager.shared.categorySelected()
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
    
    private var filteredRecipesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipeSectionTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    if let selectedCategory = selectedCategory {
                        Text("Showing \(filteredRecipes.count) \(selectedCategory.name?.lowercased() ?? "recipe")\(filteredRecipes.count == 1 ? "" : "s")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("\(recipes.count) traditional recipes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Recipe count badge
                Text("\(filteredRecipes.count)")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(selectedCategory == nil ? .secondary : categoryColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(selectedCategory == nil ? Color(.systemGray5) : categoryColor.opacity(0.15))
                            .overlay(
                                Capsule()
                                    .stroke(selectedCategory == nil ? Color.clear : categoryColor.opacity(0.3), lineWidth: 1)
                            )
                    )
            }
            .padding(.horizontal, 24)
            
            if filteredRecipes.isEmpty {
                categoryEmptyState
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(filteredRecipes, id: \.self) { recipe in
                        NavigationLink {
                            RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                        } label: {
                            RecipeCard(recipe: recipe)
                        }
                        .buttonStyle(.plain)
                        .onTapGesture {
                            HapticFeedbackManager.shared.recipeTapped()
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
    }
    
    private var filteredRecipes: [Recipe] {
        if let selectedCategory = selectedCategory {
            return recipes.filter { recipe in
                recipe.categoryArray.contains(selectedCategory)
            }
        }
        return Array(recipes)
    }
    
    private var recipeSectionTitle: String {
        if let selectedCategory = selectedCategory {
            return selectedCategory.name ?? "Recipes"
        }
        return "All Recipes"
    }
    
    private var categorySubtitle: String {
        if selectedCategory != nil {
            return "Tap to filter recipes"
        }
        return "Explore Ghanaian cuisine"
    }
    
    private var categoryColor: Color {
        guard let selectedCategory = selectedCategory else { return Color("GhanaGold") }
        
        switch selectedCategory.name?.lowercased() {
        case "soups":
            return Color("SoupTeal")
        case "stews":
            return Color("StewOrange")
        case "rice dishes":
            return Color("RiceGold")
        case "street food":
            return Color("StreetGreen")
        case "breakfast":
            return Color("BreakfastOrange")
        case "desserts":
            return Color("DessertPink")
        case "drinks":
            return Color("DrinkBlue")
        case "sides":
            return Color("SidesBrown")
        default:
            return Color("GhanaGold")
        }
    }
    
    private var categoryEmptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: getCategoryIcon(selectedCategory?.name))
                .font(.system(size: 40))
                .foregroundColor(categoryColor.opacity(0.6))
            
            Text("No \(selectedCategory?.name?.lowercased() ?? "recipes") yet")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Check back soon for traditional Ghanaian \(selectedCategory?.name?.lowercased() ?? "recipes")!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, 24)
    }
    
    private func getCategoryIcon(_ categoryName: String?) -> String {
        switch categoryName?.lowercased() {
        case "soups":
            return "drop.circle.fill"
        case "stews":
            return "flame.fill"
        case "rice dishes":
            return "circle.grid.3x3.fill"
        case "street food":
            return "cart.fill"
        case "breakfast":
            return "sun.horizon.fill"
        case "desserts":
            return "heart.circle.fill"
        case "drinks":
            return "cup.and.saucer.fill"
        case "sides":
            return "square.stack.3d.down.right.fill"
        default:
            return "fork.knife"
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
                
                Text("\(recipes.count) recipes")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            
            LazyVStack(spacing: 16) {
                ForEach(recipes, id: \.self) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                    } label: {
                        RecipeCard(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                    .onTapGesture {
                        HapticFeedbackManager.shared.recipeTapped()
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
    
    // MARK: - Recipe Submission Prompt
    private var recipeSubmissionPrompt: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color("GhanaGold"))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Didn't find \"\(searchText.trimmingCharacters(in: .whitespacesAndNewlines))\"?")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        Text("Help us add it to our collection!")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                
                // Suggest recipe button
                Button(action: {
                    showingRecipeSubmission = true
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 14, weight: .semibold))
                        
                        Text("Suggest This Recipe")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("GhanaGold"), Color("KenteGold")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color("GhanaGold").opacity(0.3), radius: 6, x: 0, y: 3)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .accessibilityLabel("Suggest recipe: \(searchText)")
                .accessibilityHint("Opens form to suggest this recipe with the name pre-filled")
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("GhanaGold").opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
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
    
    private var recommendationsLoadingState: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recommended for You")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Discovering personalized suggestions...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            // Horizontal scroll of recommendation skeletons
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<4, id: \.self) { index in
                        RecommendationCardSkeleton()
                            .opacity(1.0 - (Double(index) * 0.1))
                            .animation(
                                .easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                                value: true
                            )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    private var categoriesLoadingState: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Browse by Category")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Loading traditional cuisine categories...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<5, id: \.self) { index in
                        CategoryCardSkeleton()
                            .animation(
                                .easeInOut(duration: 1.2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: true
                            )
                    }
                }
                .padding(.horizontal, 24)
            }
        }
    }
    
    /// Performs the refresh operation
    private func performRefresh() async {
        await MainActor.run {
            isRefreshing = true
        }
        
        // Add haptic feedback
        HapticFeedbackManager.shared.refreshStarted()
        
        // Simulate refresh operations
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        await MainActor.run {
            // Refresh recommendations
            refreshRecommendations()
            
            // Clear and reload stable recommendations
            stableRecommendations = []
            loadRecommendations()
            
            // Add some visual feedback
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isRefreshing = false
            }
            
            // Success haptic
            HapticFeedbackManager.shared.refreshCompleted()
        }
    }
    
    /// Custom refresh indicator overlay
    private var refreshIndicatorOverlay: some View {
        VStack {
            if isRefreshing {
                HStack(spacing: 12) {
                    PulsingCircle()
                        .frame(width: 16, height: 16)
                    
                    Text("Refreshing recipes...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 8)
            }
            
            Spacer()
        }
    }
    
    /// Generates a new hero recipe (could be random or based on time)
    private func generateNewHeroRecipe() -> Recipe? {
        let allRecipes = Array(recipes)
        guard !allRecipes.isEmpty else { return nil }
        
        // Use current time + random factor for variety
        let timeBasedSeed = Int(Date().timeIntervalSince1970) % allRecipes.count
        return allRecipes[timeBasedSeed]
    }
    
    // MARK: - Skeleton Components
    struct RecommendationCardSkeleton: View {
        @State private var isShimmering = false
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Image skeleton
                ShimmerRectangle(height: 140, width: 200, cornerRadius: 20)
                
                // Content skeleton
                VStack(alignment: .leading, spacing: 8) {
                    ShimmerRectangle(height: 16, width: 150, cornerRadius: 6)
                    
                    HStack(spacing: 8) {
                        ShimmerRectangle(height: 12, width: 60, cornerRadius: 4)
                        ShimmerRectangle(height: 12, width: 40, cornerRadius: 4)
                        Spacer()
                    }
                }
                .padding(16)
            }
            .frame(width: 200)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
        }
    }
    
    struct CategoryCardSkeleton: View {
        @State private var isShimmering = false
        
        var body: some View {
            HStack(spacing: 12) {
                // Icon skeleton
                ShimmerRectangle(height: 32, width: 32, cornerRadius: 16)
                
                // Text skeleton
                ShimmerRectangle(height: 16, width: 80, cornerRadius: 6)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule()
                    .fill(Color(.systemGray6))
            )
        }
    }
}
