//
//  IngredientPanelView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import SwiftUI

struct IngredientPanelView: View {
    let ingredients: [Ingredient]
    let onClose: () -> Void
    
    @State private var checkedIngredients: Set<String> = []
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Recipe Ingredients")
                        .headingMedium()
                        .foregroundColor(.primary)
                    
                    Text("\(ingredients.count) ingredients • Tap to check off")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            
            // Ingredients list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(ingredients, id: \.self) { ingredient in
                        ingredientRow(ingredient)
                    }
                }
            }
            .frame(maxHeight: 300)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("SoupTeal").opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
    }
    
    private func ingredientRow(_ ingredient: Ingredient) -> some View {
        let ingredientId = ingredient.name ?? ""
        let isChecked = checkedIngredients.contains(ingredientId)
        
        return Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                if isChecked {
                    checkedIngredients.remove(ingredientId)
                } else {
                    checkedIngredients.insert(ingredientId)
                }
            }
        }) {
            HStack(spacing: 12) {
                // Checkbox
                ZStack {
                    Circle()
                        .fill(isChecked ? Color("SoupTeal") : Color(.systemGray5))
                        .frame(width: 24, height: 24)
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                // Ingredient info
                VStack(alignment: .leading, spacing: 2) {
                    HStack {
                        Text(formatIngredientQuantity(ingredient))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(isChecked ? .secondary : .primary)
                            .strikethrough(isChecked)
                        
                        Text(ingredient.name ?? "Unknown")
                            .font(.system(size: 15))
                            .foregroundColor(isChecked ? .secondary : .primary)
                            .strikethrough(isChecked)
                    }
                    
                    if let notes = ingredient.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                            .italic()
                    }
                }
                
                Spacer()
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
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
}

#Preview {
    let context = PersistenceController.preview.container.viewContext
    let mockRecipe = MockData.previewRecipe(in: context)
    let ingredients = Array(mockRecipe.ingredients as? Set<Ingredient> ?? [])
    
    ZStack {
        Color(.systemGroupedBackground)
            .ignoresSafeArea()
        
        IngredientPanelView(
            ingredients: ingredients,
            onClose: {}
        )
        .padding()
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    let showInfo: Bool
    
    @State private var expanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main ingredient info
            HStack(alignment: .top, spacing: 12) {
                Circle()
                    .fill(Color.blue)
                    .frame(width: 8, height: 8)
                    .padding(.top, 6)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(formatIngredientQuantity(ingredient))
                            .fontWeight(.medium)
                        
                        Text(ingredient.name ?? "")
                    }
                    
                    if let notes = ingredient.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if showInfo {
                    Button(action: { expanded.toggle() }) {
                        Image(systemName: expanded ? "info.circle.fill" : "info.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            // Expanded info section
            if showInfo && expanded, let info = getIngredientInfo(ingredient.name ?? "") {
                HStack {
                    Spacer().frame(width: 20)  // Indent
                    
                    Text(info)
                        .font(.caption)
                        .foregroundColor(.blue)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                        )
                }
            }
        }
        .padding(.vertical, 4)
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
    
    // This would normally come from a database
    private func getIngredientInfo(_ name: String) -> String? {
        let lowerName = name.lowercased()
        
        if lowerName.contains("palm oil") {
            return "Substitute: Red palm oil can be replaced with sunflower oil with a bit of tomato paste for color."
        } else if lowerName.contains("shito") {
            return "Info: Shito is a Ghanaian hot pepper sauce made with dried fish, shrimp, and spices."
        } else if lowerName.contains("garden egg") {
            return "Substitute: African eggplants (garden eggs) can be replaced with small Italian eggplants."
        } else if lowerName.contains("kontomire") {
            return "Info: Kontomire is cocoyam leaves. Substitute with collard greens or spinach."
        } else if lowerName.contains("fufu") {
            return "Info: Traditional fufu is made by pounding cassava and plantain. Instant versions are also available."
        } else if lowerName.contains("kenkey") {
            return "Info: Kenkey is a fermented corn dough. You can sometimes find it in African markets or make it with masa harina."
        } else if lowerName.contains("groundnut") || lowerName.contains("peanut") {
            return "Info: Groundnut paste is a crucial ingredient in many Ghanaian dishes. Unsweetened peanut butter is a good substitute."
        } else if lowerName.contains("smoked fish") {
            return "Substitute: If smoked fish is unavailable, use canned smoked herring or mackerel."
        } else if lowerName.contains("dawadawa") {
            return "Info: Dawadawa is a fermented locust bean condiment. Miso paste can be used as a substitute though the flavor will differ."
        }
        
        return nil
    }
}
