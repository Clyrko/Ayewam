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
    @State private var showingRecipeSubmission = false
    
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
            return Color("BreakfastOrange")
        case 12...17:
            return Color("GhanaGold")
        case 18...20:
            return Color("WarmRed")
        default:
            return Color("DrinkBlue")
        }
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
                
                // Recipe of the Day Section
                recipeOfTheDayHero
                
                // Smart recommendations
                smartRecommendationsSection
                
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
                loadSmartRecommendations()
                
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
        .toast(position: .top)
        .sheet(isPresented: $showingRecipeSubmission) {
            RecipeSubmissionView(prefilledRecipeName: searchText.trimmingCharacters(in: .whitespacesAndNewlines))
        }
    }

    // MARK: - Simple Recipe of the Day Hero
    private var recipeOfTheDayHero: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recipe of the Day")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text(heroRecipeSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Day indicator
                VStack {
                    Text(todayDayName)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color("GhanaGold"))
                    
                    Text(todayDayNumber)
                        .font(.system(size: 20, weight: .bold))
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
    
    // MARK: - Simple Hero Card Component
    struct SimpleHeroCard: View {
        let recipe: Recipe
        
        var body: some View {
            HStack(spacing: 16) {
                // Recipe image
                if let imageName = recipe.imageName, !imageName.isEmpty {
                    AsyncImageView.asset(imageName, cornerRadius: 16)
                        .frame(width: 80, height: 80)
                        .clipped()
                } else {
                    AsyncImageView.placeholder(
                        color: Color("GhanaGold").opacity(0.3),
                        text: recipe.name,
                        cornerRadius: 16
                    )
                    .frame(width: 80, height: 80)
                }
                
                // Recipe info
                VStack(alignment: .leading, spacing: 8) {
                    Text(recipe.name ?? "Unknown Recipe")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if let description = recipe.recipeDescription, !description.isEmpty {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    HStack(spacing: 16) {
                        if recipe.prepTime > 0 || recipe.cookTime > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(.blue)
                                
                                Text("\(recipe.prepTime + recipe.cookTime) min")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                            HStack(spacing: 4) {
                                Image(systemName: "speedometer")
                                    .font(.system(size: 12))
                                    .foregroundColor(.orange)
                                
                                Text(difficulty)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Spacer()
                        
                        if recipe.isFavorite {
                            Image(systemName: "heart.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color("GhanaGold").opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
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
                            .stroke(Color("GhanaGold").opacity(0.3), lineWidth: 1)
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
                    .foregroundColor(Color("ForestGreen"))
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
                            .foregroundColor(Color("WarmRed"))
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
                    .stroke(Color("GhanaGold").opacity(0.2), lineWidth: 1)
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
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color("GhanaGold"), Color("KenteGold")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            
                            Image(systemName: "sparkles")
                                .font(.title3)
                                .foregroundColor(Color("CookingProgress"))
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
            
            if filteredRecipes.isEmpty {
                emptyRecipeState
            } else {
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
    }
    
    // MARK: - Empty Recipe State
    private var emptyRecipeState: some View {
        VStack(spacing: 24) {
            // Empty state icon and text
            VStack(spacing: 16) {
                Image(systemName: "text.book.closed")
                    .font(.system(size: 50))
                    .foregroundColor(.secondary)
                
                Text("No recipes found")
                    .font(.headline)
                
                Text(emptyStateDescription)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 16) {
                // Recipe submission button (only show if searching)
                if !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    recipeSubmissionPrompt
                }
                
                // Clear filters button (only show if filters are active)
                if selectedCategory != nil || !searchText.isEmpty {
                    Button("Clear Filters") {
                        selectedCategory = nil
                        searchText = ""
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.blue)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
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
    
    private var emptyStateDescription: String {
        if selectedCategory != nil || !searchText.isEmpty {
            return "Try adjusting your filters or search terms"
        } else {
            return "Check back later for new recipes"
        }
    }
}
