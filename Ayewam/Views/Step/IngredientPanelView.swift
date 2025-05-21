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
    
    @State private var showAllSubstitutions: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Ingredients")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            
            // Ingredient tip
            tipView
            
            // Show all substitutions toggle
            if hasAnySubstitution {
                Toggle(isOn: $showAllSubstitutions) {
                    Text("Show all ingredient info")
                        .font(.subheadline)
                }
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            }
            
            // Divider
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(height: 1)
                .padding(.vertical, 8)
            
            // Ingredients list
            if !ingredients.isEmpty {
                ForEach(ingredients, id: \.self) { ingredient in
                    IngredientRow(
                        ingredient: ingredient,
                        showInfo: showAllSubstitutions || shouldShowInfo(for: ingredient)
                    )
                }
            } else {
                Text("No ingredients available")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
        .padding(.top, 16)
    }
    
    private var tipView: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.title3)
            
            Text("Ghanaian dishes often use fresh ingredients. If an ingredient is unavailable, see our suggestions for substitutions.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.yellow.opacity(0.1))
        )
    }
    
    private var hasAnySubstitution: Bool {
        return ingredients.contains { getIngredientInfo($0.name ?? "") != nil }
    }
    
    private func shouldShowInfo(for ingredient: Ingredient) -> Bool {
        return getIngredientInfo(ingredient.name ?? "") != nil
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
