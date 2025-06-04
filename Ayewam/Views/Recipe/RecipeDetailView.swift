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
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        // Recipe Header
                        recipeHeaderView
                            .background(
                                GeometryReader { headerGeometry in
                                    Color.clear.preference(
                                        key: ScrollOffsetPreferenceKey.self,
                                        value: headerGeometry.frame(in: .named("scroll")).minY
                                    )
                                }
                            )
                        
                        // Recipe title panel
                        recipeTitlePanel
                        
                        // Recipe info tabs
                        VStack(alignment: .leading, spacing: 20) {
                            // Tab selector
                            tabSelector
                            
                            // Tab content
                            tabContent
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120)
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
            
            floatingStartCookingButton
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
                    HapticFeedbackManager.shared.recipeFavorited()
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
    
    // MARK: - Recipe Header
    private var recipeHeaderView: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageName = recipe.imageName, !imageName.isEmpty {
                AsyncImageView.asset(
                    imageName,
                    contentMode: .fill
                )
                .frame(height: 200)
                .clipped()
                .overlay(
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
    
    // MARK: - Recipe Title Panel
    private var recipeTitlePanel: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Recipe Name
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
            
            // Quick stats
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
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(
                title: "Overview",
                icon: "info.circle.fill",
                isActive: activeTab == 0
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    activeTab = 0
                }
            }
            
            TabButton(
                title: "Ingredients",
                icon: "list.bullet",
                isActive: activeTab == 1
            ) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    activeTab = 1
                }
            }
            
            TabButton(
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
    
    // MARK: - Tab Content
    private var tabContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch activeTab {
            case 0:
                overviewTab
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            case 1:
                ingredientsTab
                    .transition(.asymmetric(
                        insertion: .move(edge: .leading).combined(with: .opacity),
                        removal: .move(edge: .trailing).combined(with: .opacity)
                    ))
            case 2:
                stepsTab
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
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Description
            if let description = recipe.recipeDescription, !description.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "text.alignleft")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("GhanaGold"))
                        
                        Text("About This Dish")
                            .headingMedium()
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
            
            // Preparation info
            VStack(alignment: .leading, spacing: 16) {
                Text("Preparation Details")
                    .headingMedium()
                    .foregroundColor(.primary)
                
                HStack(spacing: 16) {
                    // Prep time card
                    PrepTimeCard(
                        icon: "timer",
                        title: "Prep Time",
                        value: "\(recipe.prepTime)",
                        unit: "min",
                        color: .blue
                    )
                    
                    // Cook time card
                    PrepTimeCard(
                        icon: "flame.fill",
                        title: "Cook Time",
                        value: "\(recipe.cookTime)",
                        unit: "min",
                        color: .orange
                    )
                }
            }
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.orange)
                    
                    Text("Chef's Tips")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("• Fresh ingredients make all the difference in authentic Ghanaian cooking")
                    Text("• Take your time with the prep - it's the foundation of great flavor")
                    Text("• Don't rush the cooking process - let the flavors develop naturally")
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
    
    private var floatingStartCookingButton: some View {
        VStack {
            Spacer()
            
            HStack {
                Spacer()
                
                Button(action: {
                    showCookingMode = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 18, weight: .semibold))
                        
                        Text("Start Cooking")
                            .font(.system(size: 17, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color("GhanaGold"), Color("KenteGold")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color("GhanaGold").opacity(0.4), radius: 16, x: 0, y: 8)
                    )
                }
                .buttonStyle(ScaleButtonStyle())
                .scaleEffect(1.0)
                .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showCookingMode)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 34)
        }
    }

    
    // MARK: - Ingredients Tab
    private var ingredientsTab: some View {
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
                        IngredientCard(ingredient: ingredient)
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
    
    // MARK: - Steps Tab
    private var stepsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header with cooking time estimate
            stepsHeader
            
            if !sortedSteps.isEmpty {
                LazyVStack(spacing: 16) {
                    ForEach(Array(sortedSteps.enumerated()), id: \.element) { index, step in
                        ModernStepCard(
                            step: step,
                            stepNumber: index + 1,
                            totalSteps: sortedSteps.count,
                            estimatedTotalTime: totalCookingTime
                        )
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.9).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.7)
                            .delay(Double(index) * 0.05),
                            value: sortedSteps.count
                        )
                    }
                }
            } else {
                EmptyStateView(
                    icon: "list.number",
                    title: "No Cooking Steps",
                    message: "This recipe doesn't have detailed cooking steps available yet."
                )
            }
        }
    }
    
    // MARK: - Steps Header
    private var stepsHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.number")
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
        }
    }

    // MARK: - Modern Step Card Component
    struct ModernStepCard: View {
        let step: Step
        let stepNumber: Int
        let totalSteps: Int
        let estimatedTotalTime: Int32
        
        @State private var isExpanded = false
        @State private var showIngredientHighlights = false
        
        private var hasTimer: Bool {
            step.duration > 0
        }
        
        private var estimatedStartTime: String {
            // Calculate when this step might start based on previous steps
            let previousStepsTime = calculatePreviousStepsTime()
            let minutes = Int(previousStepsTime) / 60
            
            if minutes == 0 {
                return "Start immediately"
            } else if minutes < 60 {
                return "After ~\(minutes) min"
            } else {
                let hours = minutes / 60
                let remainingMinutes = minutes % 60
                return "After ~\(hours)h \(remainingMinutes)m"
            }
        }
        
        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                // Step header
                stepHeader
                
                // Main instruction content
                instructionContent
                
                // Timer and additional info section
                if hasTimer || !stepIngredients.isEmpty {
                    additionalInfoSection
                }
            }
            .padding(20)
            .background(stepCardBackground)
            .onTapGesture {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }
        }
        
        // MARK: - Step Header
        private var stepHeader: some View {
            HStack(alignment: .top, spacing: 16) {
                // Step number with progress indicator
                stepNumberIndicator
                
                VStack(alignment: .leading, spacing: 8) {
                    // Step title and timing
                    HStack {
                        Text("Step \(stepNumber)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if hasTimer {
                            timerBadge
                        }
                    }
                    
                    // Estimated timing
                    if stepNumber > 1 {
                        Text(estimatedStartTime)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray6))
                            )
                    }
                }
            }
            .padding(.bottom, 16)
        }
        
        private var stepNumberIndicator: some View {
            ZStack {
                // Progress ring
                Circle()
                    .stroke(Color("GhanaGold").opacity(0.2), lineWidth: 3)
                    .frame(width: 44, height: 44)
                
                Circle()
                    .trim(from: 0, to: CGFloat(stepNumber) / CGFloat(totalSteps))
                    .stroke(
                        LinearGradient(
                            colors: [Color("GhanaGold"), Color("KenteGold")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                
                // Step number
                Text("\(stepNumber)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Color("GhanaGold"))
            }
        }
        
        private var timerBadge: some View {
            HStack(spacing: 4) {
                Image(systemName: "timer")
                    .font(.system(size: 12))
                
                Text(formatStepDuration(step.duration))
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(Color("TimerActive"))
                    .shadow(color: Color("TimerActive").opacity(0.3), radius: 2, x: 0, y: 1)
            )
        }
        
        // MARK: - Instruction Content
        private var instructionContent: some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(step.instruction ?? "No instruction available")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Expand/collapse indicator for additional info
                if hasTimer || !stepIngredients.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                            
                            Text(isExpanded ? "Less details" : "More details")
                                .font(.system(size: 13, weight: .medium))
                            
                            if !stepIngredients.isEmpty && !isExpanded {
                                Text("• \(stepIngredients.count) ingredients")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                        .foregroundColor(Color("GhanaGold"))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        
        // MARK: - Additional Info Section
        private var additionalInfoSection: some View {
            Group {
                if isExpanded {
                    VStack(alignment: .leading, spacing: 16) {
                        Divider()
                            .padding(.vertical, 4)
                        
                        // Step-specific ingredients
                        if !stepIngredients.isEmpty {
                            stepIngredientsSection
                        }
                        
                        // Cooking tips
                        cookingTipsSection
                    }
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .top)))
                }
            }
        }
        
        private var stepIngredientsSection: some View {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color("SoupTeal"))
                    
                    Text("Ingredients for this step")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                LazyVStack(alignment: .leading, spacing: 6) {
                    ForEach(stepIngredients, id: \.self) { ingredient in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(Color("SoupTeal"))
                                .frame(width: 6, height: 6)
                            
                            if ingredient.quantity > 0 {
                                Text(formatIngredientQuantity(ingredient))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.primary)
                            }
                            
                            Text(ingredient.name ?? "Unknown")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            if let notes = ingredient.notes, !notes.isEmpty {
                                Text("(\(notes))")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                                    .italic()
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("SoupTeal").opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color("SoupTeal").opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        private var cookingTipsSection: some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    
                    Text("Pro Tips")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(getCookingTips(), id: \.self) { tip in
                        HStack(alignment: .top, spacing: 8) {
                            Text("•")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                                .padding(.top, 1)
                            
                            Text(tip)
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }
                    }
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.orange.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        
        // MARK: - Background
        private var stepCardBackground: some View {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color("GhanaGold").opacity(0.2), Color("GhanaGold").opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
        
        // MARK: - Helper Methods
        private func calculatePreviousStepsTime() -> Int32 {
            // This would need access to all previous steps to calculate cumulative time
            // For now, return a simple estimate based on step number
            return Int32((stepNumber - 1) * 5 * 60) // Assume 5 minutes per previous step
        }
        
        private func formatStepDuration(_ duration: Int32) -> String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            
            if minutes > 0 && seconds > 0 {
                return "\(minutes)m \(seconds)s"
            } else if minutes > 0 {
                return "\(minutes)m"
            } else {
                return "\(seconds)s"
            }
        }
        
        private func formatDetailedDuration(_ duration: Int32) -> String {
            let minutes = Int(duration) / 60
            let seconds = Int(duration) % 60
            
            if minutes > 0 && seconds > 0 {
                return "\(minutes) minutes \(seconds) seconds"
            } else if minutes > 0 {
                return "\(minutes) minute\(minutes == 1 ? "" : "s")"
            } else {
                return "\(seconds) second\(seconds == 1 ? "" : "s")"
            }
        }
        
        private func formatIngredientQuantity(_ ingredient: Ingredient) -> String {
            let quantityString: String
            if ingredient.quantity == 0 {
                return ""
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
        
        private var stepIngredients: [Ingredient] {
            // This would analyze the step instruction to find mentioned ingredients
            // For now, return empty array - you'd implement the ingredient detection logic
            return []
        }
        
        private func getCookingTips() -> [String] {
            var tips: [String] = []
            
            // Add timer-specific tips
            if hasTimer {
                tips.append("Set a timer to avoid overcooking")
                tips.append("Keep an eye on the food during the last minute")
            }
            
            // Add step-specific tips based on keywords in instruction
            if let instruction = step.instruction?.lowercased() {
                if instruction.contains("fry") || instruction.contains("sauté") {
                    tips.append("Heat the oil properly before adding ingredients")
                }
                if instruction.contains("stir") {
                    tips.append("Stir gently to avoid breaking delicate ingredients")
                }
                if instruction.contains("boil") {
                    tips.append("Watch for the rolling boil, then reduce heat")
                }
                if instruction.contains("season") || instruction.contains("salt") {
                    tips.append("Taste as you go - you can always add more seasoning")
                }
            }
            
            // Default tip if no specific ones apply
            if tips.isEmpty {
                tips.append("Take your time and follow the instruction carefully")
            }
            
            return tips
        }
    }

    // MARK: - Helper Methods
    private func toggleFavorite() {
        viewModel.toggleFavorite(recipe)
    }
    
    private var totalCookingTime: Int32 {
        recipe.prepTime + recipe.cookTime
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

// MARK: - Supporting Components
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

struct TabButton: View {
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

struct IngredientCard: View {
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
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
            }
            .frame(minWidth: 60, alignment: .trailing)
            
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

struct StepCard: View {
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
