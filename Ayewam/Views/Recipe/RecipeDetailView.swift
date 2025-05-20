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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Recipe Image or Placeholder
                ZStack(alignment: .bottom) {
                    // Image placeholder or actual image
                    recipeHeaderView
                    
                    // Recipe title panel overlapping the image
                    recipeTitlePanel
                }
                
                // Recipe info tabs
                VStack(alignment: .leading, spacing: 20) {
                    // Tab selector
                    tabSelector
                    
                    // Tab content
                    tabContent
                }
                .padding()
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { toggleFavorite() }) {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(recipe.isFavorite ? .red : .gray)
                }
            }
        }
    }
    
    // MARK: - Recipe Header
    private var recipeHeaderView: some View {
        ZStack {
            if let imageName = recipe.imageName, !imageName.isEmpty {
                Color.gray.opacity(0.3) // Placeholder until actual image loading is implemented
            } else {
                Color.gray.opacity(0.3)
            }
            
            // Placeholder text if no image
            if recipe.imageName == nil || recipe.imageName?.isEmpty == true {
                Text(String(recipe.name?.prefix(1) ?? "R"))
                    .font(.system(size: 60))
                    .foregroundColor(.white)
            }
        }
        .frame(height: 250)
    }
    
    // MARK: - Recipe Title Panel
    private var recipeTitlePanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Recipe Name
            Text(recipe.name ?? "Unknown Recipe")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // Recipe metadata
            HStack(spacing: 16) {
                // Cook time
                Label("\(recipe.prepTime + recipe.cookTime) min", systemImage: "clock")
                    .font(.subheadline)
                
                // Difficulty
                if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                    Label(difficulty, systemImage: "speedometer")
                        .font(.subheadline)
                }
                
                // Servings
                if recipe.servings > 0 {
                    Label("\(recipe.servings) serving\(recipe.servings > 1 ? "s" : "")", systemImage: "person.2")
                        .font(.subheadline)
                }
            }
            .foregroundColor(.secondary)
            
            // Region
            if let region = recipe.region, !region.isEmpty {
                Label("Region: \(region)", systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .offset(y: 40)
        .padding(.horizontal, 16)
    }
    
    // MARK: - Tab Selector
    private var tabSelector: some View {
        HStack(spacing: 0) {
            TabButton(title: "Overview", isActive: activeTab == 0) {
                activeTab = 0
            }
            TabButton(title: "Ingredients", isActive: activeTab == 1) {
                activeTab = 1
            }
            TabButton(title: "Steps", isActive: activeTab == 2) {
                activeTab = 2
            }
        }
        .padding(.top, 24)
    }
    
    // MARK: - Tab Content
    private var tabContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch activeTab {
            case 0:
                overviewTab
            case 1:
                ingredientsTab
            case 2:
                stepsTab
            default:
                EmptyView()
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Overview Tab
    private var overviewTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let description = recipe.recipeDescription, !description.isEmpty {
                Text("About this dish")
                    .font(.headline)
                
                Text(description)
                    .foregroundColor(.secondary)
            }
            
            Divider()
            
            // Category info
            if let category = recipe.category, let name = category.name {
                HStack {
                    Text("Category:")
                        .fontWeight(.medium)
                    
                    Text(name)
                    
                    if let colorHex = category.colorHex {
                        Circle()
                            .fill(Color(hex: colorHex))
                            .frame(width: 12, height: 12)
                    }
                }
                .padding(.vertical, 4)
            }
            
            // Preparation Info
            Text("Preparation")
                .font(.headline)
                .padding(.top, 8)
            
            HStack(spacing: 16) {
                // Prep time
                VStack {
                    Text("\(recipe.prepTime) min")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("Prep Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
                
                // Cook time
                VStack {
                    Text("\(recipe.cookTime) min")
                        .font(.title3)
                        .fontWeight(.medium)
                    Text("Cook Time")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            }
        }
    }
    
    // MARK: - Ingredients Tab
    private var ingredientsTab: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let ingredients = recipe.ingredients as? Set<Ingredient>, !ingredients.isEmpty {
                Text("Ingredients for \(recipe.servings) serving\(recipe.servings > 1 ? "s" : "")")
                    .font(.headline)
                
                ForEach(sortedIngredients, id: \.self) { ingredient in
                    HStack(alignment: .top, spacing: 12) {
                        // Bullet point
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 8, height: 8)
                            .padding(.top, 6)
                        
                        // Ingredient details
                        VStack(alignment: .leading, spacing: 4) {
                            // Name and quantity
                            HStack {
                                Text(formatIngredientQuantity(ingredient))
                                    .fontWeight(.medium)
                                
                                Text(ingredient.name ?? "")
                            }
                            
                            // Notes (if any)
                            if let notes = ingredient.notes, !notes.isEmpty {
                                Text(notes)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No ingredients available")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    // MARK: - Steps Tab
    private var stepsTab: some View {
        VStack(alignment: .leading, spacing: 20) {
            if let steps = recipe.steps as? Set<Step>, !steps.isEmpty {
                Text("Cooking Instructions")
                    .font(.headline)
                
                ForEach(sortedSteps, id: \.self) { step in
                    stepView(step: step)
                }
            } else {
                Text("No cooking steps available")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    // MARK: - Helper Views
    private func stepView(step: Step) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Step header
            HStack {
                Text("Step \(step.orderIndex + 1)")
                    .font(.headline)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(16)
                
                if step.duration > 0 {
                    Spacer()
                    
                    Label("\(step.duration / 60) min", systemImage: "clock")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Step instruction
            Text(step.instruction ?? "")
                .padding(.vertical, 4)
            
            // Step image placeholder
            if let _ = step.imageName {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                    )
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
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
            quantityString = "\(ingredient.quantity)"
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

// MARK: - Tab Button Component
struct TabButton: View {
    let title: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isActive ? .semibold : .regular)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    VStack {
                        Spacer()
                        if isActive {
                            Rectangle()
                                .fill(Color.blue)
                                .frame(height: 3)
                        }
                    }
                )
        }
        .foregroundColor(isActive ? .primary : .secondary)
        .frame(maxWidth: .infinity)
    }
}

// For Preview
struct RecipeDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let fetchRequest: NSFetchRequest<Recipe> = Recipe.fetchRequest()
        let recipes = try? context.fetch(fetchRequest)
        
        if let recipe = recipes?.first {
            NavigationView {
                RecipeDetailView(
                    recipe: recipe,
                    viewModel: RecipeViewModel(repository: RecipeRepository(context: context))
                )
            }
        }
    }
}
