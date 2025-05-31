//
//  RecipeDetailView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI
import CoreData

struct RecipeDetailView: View {
    let recipe: Recipe
    @ObservedObject var viewModel: RecipeViewModel
    @State private var activeTab = 0
    @State private var showCookingMode = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showHeaderBackground = false
    @State private var favoriteScale: CGFloat = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Recipe Header
                    enhancedRecipeHeaderView
                        .background(
                            GeometryReader { headerGeometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: headerGeometry.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                    
                    // Recipe title panel
                    enhancedRecipeTitlePanel
                    
                    // Enhanced Recipe info tabs
                    VStack(alignment: .leading, spacing: 20) {
                        // Enhanced tab selector
                        enhancedTabSelector
                        
                        // Enhanced tab content
                        enhancedTabContent
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .coordinateSpace(name: "scroll")
            .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                scrollOffset = value
                withAnimation(.easeInOut(duration: 0.2)) {
                    showHeaderBackground = value < -50
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if showHeaderBackground {
                    Text(recipe.name ?? "Recipe")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .transition(.opacity)
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                        toggleFavorite()
                        favoriteScale = 1.3
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            favoriteScale = 1.0
                        }
                    }
                }) {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(recipe.isFavorite ? Color("FavoriteHeart") : .gray)
                        .font(.system(size: 18, weight: .semibold))
                        .scaleEffect(favoriteScale)
                        .animation(.spring(response: 0.4, dampingFraction: 0.6), value: favoriteScale)
                }
            }
        }
        .toolbarBackground(showHeaderBackground ? .visible : .hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $showCookingMode) {
            NavigationView {
                CookingView(viewModel: CookingViewModel(recipe: recipe))
            }
        }
    }
    
    // MARK: - Enhanced Recipe Header
    private var enhancedRecipeHeaderView: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageName = recipe.imageName, !imageName.isEmpty {
                AsyncImageView.asset(
                    imageName,
                    contentMode: .fill
                )
                .frame(height: 200)
                .clipped()
                .overlay(
                    // Enhanced gradient overlay
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color.black.opacity(0.3),
                            Color.black.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            } else {
                let placeholderColor = recipe.categoryObject?.colorHex != nil ?
                    Color(hex: recipe.categoryObject!.colorHex!) :
                    Color("GhanaGold").opacity(0.3)
                
                AsyncImageView.placeholder(
                    color: placeholderColor,
                    text: recipe.name
                )
                .frame(height: 300)
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.clear,
                            placeholderColor.opacity(0.3),
                            placeholderColor.opacity(0.7)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            // Category and difficulty badges overlay
            VStack {
                HStack {
                    if let category = recipe.categoryObject, let categoryName = category.name {
                        CategoryBadge(
                            name: categoryName,
                            color: Color(hex: category.colorHex ?? "#767676")
                        )
                    }
                    
                    if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                        DifficultyBadge(difficulty: difficulty)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 100)
                
                Spacer()
            }
        }
    }
    
    // MARK: - Enhanced Recipe Title Panel
    private var enhancedRecipeTitlePanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recipe Name with enhanced typography
            Text(recipe.name ?? "Unknown Recipe")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.primary, Color("GhanaGold")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineLimit(3)
            
            // Quick stats with enhanced design
            HStack(spacing: 20) {
                if recipe.prepTime > 0 || recipe.cookTime > 0 {
                    QuickStatCard(
                        icon: "clock.fill",
                        value: "\(recipe.prepTime + recipe.cookTime)",
                        unit: "min",
                        color: .blue
                    )
                }
                
                if recipe.servings > 0 {
                    QuickStatCard(
                        icon: "person.2.fill",
                        value: "\(recipe.servings)",
                        unit: recipe.servings == 1 ? "serving" : "servings",
                        color: .green
                    )
                }
                
                if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                    QuickStatCard(
                        icon: "speedometer",
                        value: difficulty,
                        unit: "level",
                        color: .orange
                    )
                }
                
                Spacer()
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
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
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .offset(y: -30)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Enhanced Tab Selector
    private var enhancedTabSelector: some View {
        HStack(spacing: 0) {
            EnhancedTabButton(
                title: "Overview",
                icon: "info.circle.fill",
                isActive: activeTab == 0
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    activeTab = 0
                }
            }
            
            EnhancedTabButton(
                title: "Ingredients",
                icon: "list.bullet",
                isActive: activeTab == 1
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    activeTab = 1
                }
            }
            
            EnhancedTabButton(
                title: "Steps",
                icon: "number.circle.fill",
                isActive: activeTab == 2
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    activeTab = 2
                }
            }
        }
        .padding(.top, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
    
    // MARK: - Enhanced Tab Content
    private var enhancedTabContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch activeTab {
            case 0:
                enhancedOverviewTab
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            case 1:
                enhancedIngredientsTab
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            case 2:
                enhancedStepsTab
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            default:
                EmptyView()
            }
        }
        .padding(.top, 16)
        .animation(.easeInOut(duration: 0.3), value: activeTab)
    }
    
    // MARK: - Enhanced Overview Tab
    private var enhancedOverviewTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Description with enhanced styling
            if let description = recipe.recipeDescription, !description.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("GhanaGold"))
                        
                        Text("About This Dish")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                    }
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("GhanaGold").opacity(0.2), lineWidth: 1)
                        )
                )
            }
            
            // Enhanced preparation info
            VStack(alignment: .leading, spacing: 16) {
                Text("Preparation Details")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    // Enhanced prep time card
                    PrepTimeCard(
                        icon: "timer",
                        title: "Prep Time",
                        value: "\(recipe.prepTime)",
                        unit: "min",
                        color: .blue
                    )
                    
                    // Enhanced cook time card
                    PrepTimeCard(
                        icon: "flame.fill",
                        title: "Cook Time",
                        value: "\(recipe.cookTime)",
                        unit: "min",
                        color: .orange
                    )
                }
            }
            
            // Enhanced Start Cooking Button
            Button(action: {
                showCookingMode = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Start Cooking")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 18)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [Color("GhanaGold"), Color("KenteGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color("GhanaGold").opacity(0.4), radius: 12, x: 0, y: 6)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
    }
    
    // MARK: - Enhanced Ingredients Tab
    private var enhancedIngredientsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("GhanaGold"))
                
                Text("Ingredients")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("for \(recipe.servings) \(recipe.servings == 1 ? "serving" : "servings")")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
            }
            
            if !sortedIngredients.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(Array(sortedIngredients.enumerated()), id: \.element) { index, ingredient in
                        EnhancedIngredientCard(ingredient: ingredient)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.05),
                                value: sortedIngredients.count
                            )
                    }
                }
            } else {
                EmptyStateView(
                    icon: "list.bullet",
                    title: "No Ingredients",
                    message: "Ingredient list not available for this recipe"
                )
            }
        }
    }
    
    // MARK: - Enhanced Steps Tab
    private var enhancedStepsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Image(systemName: "number.circle.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("GhanaGold"))
                
                Text("Cooking Steps")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(sortedSteps.count) steps")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
            }
            
            if !sortedSteps.isEmpty {
                LazyVStack(spacing: 16) {
                    ForEach(Array(sortedSteps.enumerated()), id: \.element) { index, step in
                        EnhancedStepCard(step: step, stepNumber: index + 1)
                            .transition(.asymmetric(
                                insertion: .scale(scale: 0.9).combined(with: .opacity),
                                removal: .scale(scale: 0.9).combined(with: .opacity)
                            ))
                            .animation(
                                .spring(response: 0.5, dampingFraction: 0.7)
                                .delay(Double(index) * 0.1),
                                value: sortedSteps.count
                            )
                    }
                }
            } else {
                EmptyStateView(
                    icon: "number.circle",
                    title: "No Steps",
                    message: "Cooking instructions not available for this recipe"
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func toggleFavorite() {
        viewModel.toggleFavorite(recipe)
    }
    
    private func formatIngredientQuantity(_ ingredient: Ingredient) -> String {
        let quantityString: String
        if ingredient.quantity == 0 {
            quantityString = ""
        } else if ingredient.quantity.truncatingRemainder(dividingBy: 1) == 0 {
            quantityString = "\(Int(ingredient.quantity))"
        } else {
            quantityString = String(format: "%.1f", ingredient.quantity)
        }
        
        if let unit = ingredient.unit, !unit.isEmpty {
            return quantityString + " " + unit
        } else {
            return quantityString
        }
    }
    
    // MARK: - Computed Properties
    private var sortedIngredients: [Ingredient] {
        guard let ingredients = recipe.ingredients as? Set<Ingredient> else { return [] }
        return ingredients.sorted { $0.orderIndex < $1.orderIndex }
    }
    
    private var sortedSteps: [Step] {
        guard let steps = recipe.steps as? Set<Step> else { return [] }
        return steps.sorted { $0.orderIndex < $1.orderIndex }
    }
}

// MARK: - Enhanced Supporting Components

struct CategoryBadge: View {
    let name: String
    let color: Color
    
    var body: some View {
        Text(name)
            .font(.system(size: 12, weight: .semibold))
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
                .font(.system(size: 12, weight: .semibold))
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

struct QuickStatCard: View {
    let icon: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(unit)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(height: 44)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(color.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

struct PrepTimeCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(spacing: 4) {
                Text("\(value) \(unit)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct EnhancedTabButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                    
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(isActive ? Color("GhanaGold") : .secondary)
                
                Rectangle()
                    .fill(isActive ? Color("GhanaGold") : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isActive ? Color("GhanaGold").opacity(0.1) : Color.clear)
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isActive)
    }
}

struct EnhancedIngredientCard: View {
    let ingredient: Ingredient
    
    var body: some View {
        HStack(spacing: 16) {
            // Quantity section
            VStack(alignment: .trailing, spacing: 2) {
                if ingredient.quantity > 0 {
                    Text(formatQuantity(ingredient.quantity))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                if let unit = ingredient.unit, !unit.isEmpty {
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 60, alignment: .trailing)
            
            // Ingredient info
            VStack(alignment: .leading, spacing: 4) {
                Text(ingredient.name ?? "Unknown")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if let notes = ingredient.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .italic()
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private func formatQuantity(_ quantity: Double) -> String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity))"
        } else {
            return String(format: "%.1f", quantity)
        }
    }
}

struct EnhancedStepCard: View {
    let step: Step
    let stepNumber: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Step header
            HStack {
                ZStack {
                    Circle()
                        .fill(Color("GhanaGold"))
                        .frame(width: 32, height: 32)
                    
                    Text("\(stepNumber)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Text("Step \(stepNumber)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                if step.duration > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "timer")
                            .font(.system(size: 12))
                            .foregroundColor(.blue)
                        
                        Text("\(step.duration) min")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.blue)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.1))
                    )
                }
            }
            
            // Step instruction
            Text(step.instruction ?? "No instruction available")
                .font(.body)
                .foregroundColor(.primary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Step image
            if let imageName = step.imageName, !imageName.isEmpty {
                AsyncImageView.asset(
                    imageName,
                    contentMode: .fill,
                    cornerRadius: 12
                )
                .frame(height: 180)
                .clipped()
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("GhanaGold").opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Preview
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let recipe = MockData.previewRecipe(in: PersistenceController.preview.container.viewContext)
        let viewModel = DataManager.shared.recipeViewModel
        
        NavigationView {
            RecipeDetailView(recipe: recipe, viewModel: viewModel)
        }
    }
}
