//
//  CardComponents.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/24/25.
//

import SwiftUI

// MARK: - Curated Card
struct CuratedCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottomLeading) {
                if let imageName = recipe.imageName, !imageName.isEmpty {
                    AsyncImageView.asset(imageName, cornerRadius: 20)
                        .frame(width: 200, height: 140)
                        .clipped()
                } else {
                    AsyncImageView.placeholder(
                        color: Color.accentColor.opacity(0.3),
                        text: recipe.name,
                        cornerRadius: 20
                    )
                    .frame(width: 200, height: 140)
                }
                
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 60)
                .clipShape(
                    UnevenRoundedRectangle(
                        cornerRadii: .init(
                            topLeading: 0,
                            bottomLeading: 20,
                            bottomTrailing: 20,
                            topTrailing: 0
                        )
                    )
                )
                
                // Time badge
                if recipe.prepTime > 0 || recipe.cookTime > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 10))
                        
                        Text("\(recipe.prepTime + recipe.cookTime) min")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                    )
                    .padding(12)
                }
            }
            
            // Recipe info
            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.name ?? "Unknown Recipe")
                    .font(.system(size: 16, weight: .bold))
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                HStack(spacing: 8) {
                    if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                        Text(difficulty)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color(.systemGray6))
                            )
                    }
                    
                    Spacer()
                    
                    if recipe.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(16)
        }
        .frame(width: 200)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

// MARK: - Recipe Card
struct RecipeCard: View {
    let recipe: Recipe
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Recipe image section
            ZStack(alignment: .topTrailing) {
                if let imageName = recipe.imageName, !imageName.isEmpty {
                    AsyncImageView.asset(imageName)
                        .frame(width: 100, height: 100)
                        .clipped()
                } else {
                    AsyncImageView.placeholder(
                        color: Color("GhanaGold").opacity(0.3),
                        text: recipe.name
                    )
                    .frame(width: 100, height: 100)
                }
                
                // Favorite heart
                if recipe.isFavorite {
                    ZStack {
                        // Glow effect
                        Circle()
                            .fill(.red.opacity(0.3))
                            .frame(width: 28, height: 28)
                            .blur(radius: 4)
                        
                        // Heart icon
                        Image(systemName: "heart.fill")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(
                                Circle()
                                    .fill(.red)
                                    .shadow(color: .red.opacity(0.4), radius: 2, x: 0, y: 1)
                            )
                    }
                    .offset(x: -8, y: 8)
                }
            }
            .cornerRadius(16, corners: [.topLeft, .bottomLeft])
            
            // Recipe info section
            VStack(alignment: .leading, spacing: 8) {
                VStack(alignment: .leading, spacing: 4) {
                    // Recipe name
                    Text(recipe.name ?? "Unknown Recipe")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Description
                    if let description = recipe.recipeDescription, !description.isEmpty {
                        Text(description)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 12) {
                        if recipe.prepTime > 0 || recipe.cookTime > 0 {
                            MetadataChip(
                                icon: "clock.fill",
                                text: "\(recipe.prepTime + recipe.cookTime) min",
                                color: .blue
                            )
                        }
                        
                        if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                            MetadataChip(
                                icon: "speedometer",
                                text: difficulty,
                                color: .orange
                            )
                        }
                        
                        Spacer()
                    }
                    
                    HStack(spacing: 12) {
                        if recipe.servings > 0 {
                            HStack(spacing: 3) {
                                Image(systemName: "person.2")
                                    .font(.system(size: 10))
                                    .foregroundColor(.secondary)
                                
                                Text("\(recipe.servings)")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if !recipe.categoryName.isEmpty && recipe.categoryName != "Uncategorized" {
                            HStack(spacing: 3) {
                                Circle()
                                    .fill(Color(hex: recipe.categoryColorHex))
                                    .frame(width: 6, height: 6)
                                
                                Text(recipe.categoryName)
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(
            color: isPressed ? Color.black.opacity(0.15) : Color.black.opacity(0.08),
            radius: isPressed ? 8 : 12,
            x: 0,
            y: isPressed ? 3 : 6
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onTapGesture {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        }
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
    }
}

// MARK: - Metadata Chip Component
struct MetadataChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(color.opacity(0.1))
                .overlay(
                    Capsule()
                        .stroke(color.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
}

// MARK: - Category Card
struct ModernCategoryCard: View {
    let category: Category
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: categoryIcon(for: category.name ?? ""))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : categoryAssetColor(for: category.name ?? ""))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(isSelected ? categoryAssetColor(for: category.name ?? "") : categoryAssetColor(for: category.name ?? "").opacity(0.1))
                )
            
            Text(category.name ?? "Unknown")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .lineLimit(1)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(isSelected ? categoryAssetColor(for: category.name ?? "") : Color(.systemGray6))
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : Color("GhanaGold").opacity(0.3), lineWidth: 1)
                )
        )
        .shadow(
            color: isSelected ? categoryAssetColor(for: category.name ?? "").opacity(0.3) : Color.black.opacity(0.05),
            radius: isSelected ? 8 : 4,
            x: 0,
            y: isSelected ? 4 : 2
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isSelected)
    }
    
    private func categoryIcon(for categoryName: String) -> String {
        switch categoryName.lowercased() {
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
    
    private func categoryAssetColor(for categoryName: String) -> Color {
        switch categoryName.lowercased() {
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
}

// MARK: - Modern Favorite Card
struct ModernFavoriteCard: View {
    let recipe: Recipe
    let onRemove: () -> Void
    @State private var isRemoving = false
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 16) {
            // Recipe image
            ZStack(alignment: .topTrailing) {
                if let imageName = recipe.imageName, !imageName.isEmpty {
                    AsyncImageView.asset(imageName, cornerRadius: 18)
                        .frame(width: 90, height: 90)
                        .clipped()
                } else {
                    AsyncImageView.placeholder(
                        color: Color.red.opacity(0.3),
                        text: recipe.name,
                        cornerRadius: 18
                    )
                    .frame(width: 90, height: 90)
                }
                
                // Favorite indicator with glow effect
                Circle()
                    .fill(.red)
                    .frame(width: 24, height: 24)
                    .overlay(
                        Image(systemName: "heart.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    )
                    .shadow(color: .red.opacity(0.4), radius: 4, x: 0, y: 2)
                    .offset(x: 4, y: -4)
                    .scaleEffect(isRemoving ? 0.8 : 1.0)
                    .animation(.spring(response: 0.4, dampingFraction: 0.6), value: isRemoving)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                Text(recipe.name ?? "Unknown Recipe")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                if let description = recipe.recipeDescription, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                        .lineSpacing(1)
                }
                
                // Recipe metadata
                HStack(spacing: 16) {
                    if recipe.prepTime > 0 || recipe.cookTime > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.blue)
                            
                            Text("\(recipe.prepTime + recipe.cookTime) min")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.blue.opacity(0.1))
                        )
                    }
                    
                    if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "speedometer")
                                .font(.system(size: 12))
                                .foregroundColor(.orange)
                            
                            Text(difficulty)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.1))
                        )
                    }
                    
                    Spacer()
                }
            }
            
            Spacer()
            
            // Remove button with haptic feedback
            Button(action: {
                let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                impactFeedback.impactOccurred()
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isRemoving = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    onRemove()
                }
            }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.red)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                    .opacity(isRemoving ? 0.5 : 1.0)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        isPressed = false
                    }
                }
            }
        }
        .padding(20)
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
        .scaleEffect(isRemoving ? 0.95 : 1.0)
        .opacity(isRemoving ? 0.7 : 1.0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: isRemoving)
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
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
