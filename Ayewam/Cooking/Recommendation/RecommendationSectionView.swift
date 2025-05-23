//
//  RecommendationSectionView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/23/25.
//

import SwiftUI

// MARK: - Main Recommendation Section View
struct RecommendationSectionView: View {
    let section: RecommendationSection
    @State private var showReasoning = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section Header
            sectionHeader
            
            // Recipe Cards Scroll
            recipeCardsScroll
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showReasoning) {
            ReasoningSheet(section: section)
        }
    }
    
    private var sectionHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(section.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Smart suggestion indicator
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .opacity(0.8)
                }
                
                if let subtitle = section.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            // Info button for reasoning
            Button(action: { showReasoning = true }) {
                Image(systemName: "info.circle")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .opacity(0.7)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.horizontal, 20)
    }
    
    private var recipeCardsScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(section.recipes, id: \.self) { recipe in
                    NavigationLink {
                        RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                    } label: {
                        SmartSuggestionCard(recipe: recipe, sectionType: section.sectionType)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Smart Suggestion Card

struct SmartSuggestionCard: View {
    let recipe: Recipe
    let sectionType: RecommendationType
    @State private var hasBeenViewed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Recipe Image with Suggestion Badge
            ZStack(alignment: .topTrailing) {
                recipeImage
                suggestionBadge
            }
            
            // Recipe Info
            recipeInfo
        }
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .onAppear {
            trackSuggestionViewed()
        }
        .onTapGesture {
            trackSuggestionInteraction()
        }
    }
    
    private var recipeImage: some View {
        Group {
            if let imageName = recipe.imageName, !imageName.isEmpty {
                AsyncImageView.asset(imageName, cornerRadius: 16)
                    .frame(width: 180, height: 130)
                    .clipped()
            } else {
                AsyncImageView.placeholder(
                    color: Color.accentColor.opacity(0.3),
                    text: recipe.name,
                    cornerRadius: 16
                )
                .frame(width: 180, height: 130)
            }
        }
    }
    
    private var suggestionBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: badgeIcon)
                .font(.system(size: 10, weight: .medium))
            
            Text(badgeText)
                .font(.system(size: 10, weight: .medium))
        }
        .foregroundColor(.white)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            Capsule()
                .fill(badgeColor.opacity(0.9))
        )
        .padding(8)
    }
    
    private var recipeInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(recipe.name ?? "Unknown Recipe")
                .font(.headline)
                .fontWeight(.semibold)
                .lineLimit(1)
                .truncationMode(.tail)
                .foregroundColor(.primary)
                .frame(height: 22, alignment: .leading)
            
            // Recipe details - fixed height
            HStack(spacing: 8) {
                if recipe.prepTime > 0 || recipe.cookTime > 0 {
                    Label("\(recipe.prepTime + recipe.cookTime) min", systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let difficulty = recipe.difficulty, !difficulty.isEmpty {
                    Text("• \(difficulty)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .frame(height: 16)
            
            // Suggestion reason
            suggestionReasonText
                .frame(height: 14)
        }
        .padding(12)
        .frame(height: 80)
    }
    
    private var suggestionReasonText: some View {
        Group {
            switch sectionType {
            case .timeBased:
                Text("Perfect for now")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .italic()
                
            case .favoriteExpansion:
                Text("Like your favorites")
                    .font(.caption2)
                    .foregroundColor(.green)
                    .italic()
                
            case .skillProgression:
                Text("Build your skills")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .italic()
                
            case .culturalContext:
                Text("Traditional choice")
                    .font(.caption2)
                    .foregroundColor(.purple)
                    .italic()
                
            default:
                Text("Recommended")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
    
    // MARK: - Badge Properties
    private var badgeIcon: String {
        switch sectionType {
        case .timeBased: return "clock"
        case .favoriteExpansion: return "heart"
        case .skillProgression: return "arrow.up.circle"
        case .culturalContext: return "star"
        default: return "sparkles"
        }
    }
    
    private var badgeText: String {
        switch sectionType {
        case .timeBased: return "Now"
        case .favoriteExpansion: return "Similar"
        case .skillProgression: return "Learn"
        case .culturalContext: return "Traditional"
        default: return "Smart"
        }
    }
    
    private var badgeColor: Color {
        switch sectionType {
        case .timeBased: return .blue
        case .favoriteExpansion: return .green
        case .skillProgression: return .orange
        case .culturalContext: return .purple
        default: return .gray
        }
    }
    
    // MARK: - Tracking Methods
    private func trackSuggestionViewed() {
        guard !hasBeenViewed, let recipeId = recipe.id else { return }
        hasBeenViewed = true
        UserDefaults.standard.addRecentlyViewedRecipe(recipeId)
    }
    
    private func trackSuggestionInteraction() {
        guard let recipeId = recipe.id else { return }
        
        // Track that user interacted with this suggestion
        var interactions = UserDefaults.standard.array(forKey: "suggestionInteractions") as? [String] ?? []
        if !interactions.contains(recipeId) {
            interactions.append(recipeId)
            UserDefaults.standard.set(interactions, forKey: "suggestionInteractions")
        }
        
        // Add to recently viewed (will move to front if already exists)
        UserDefaults.standard.addRecentlyViewedRecipe(recipeId)
    }
}

// MARK: - Reasoning Sheet

struct ReasoningSheet: View {
    let section: RecommendationSection
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: sectionIcon)
                                .font(.title2)
                                .foregroundColor(sectionColor)
                            
                            Text(section.title)
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        if let subtitle = section.subtitle {
                            Text(subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Divider()
                    
                    // Why these recipes were suggested
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why we suggested these:")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text(section.reasoning)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    
                    Divider()
                    
                    // About smart suggestions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("About Smart Suggestions")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Our suggestions are based on:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            suggestionFactorRow(icon: "clock", text: "Current time and day of week")
                            suggestionFactorRow(icon: "heart", text: "Your favorite recipes")
                            suggestionFactorRow(icon: "chart.line.uptrend.xyaxis", text: "Your cooking progress")
                            suggestionFactorRow(icon: "globe.africa.fill", text: "Ghanaian cooking traditions")
                        }
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("Smart Suggestions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func suggestionFactorRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var sectionIcon: String {
        switch section.sectionType {
        case .timeBased: return "clock"
        case .favoriteExpansion: return "heart.circle"
        case .skillProgression: return "arrow.up.circle"
        case .culturalContext: return "star.circle"
        default: return "sparkles"
        }
    }
    
    private var sectionColor: Color {
        switch section.sectionType {
        case .timeBased: return .blue
        case .favoriteExpansion: return .green
        case .skillProgression: return .orange
        case .culturalContext: return .purple
        default: return .gray
        }
    }
}

// MARK: - Loading State View

struct RecommendationLoadingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header placeholder
            HStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 180, height: 24)
                
                Spacer()
            }
            .padding(.horizontal, 20)
            
            // Cards placeholder
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<3, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 180, height: 220)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .redacted(reason: .placeholder)
        .shimmering()
    }
}

// MARK: - Empty State View

struct RecommendationEmptyView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("Smart Suggestions Loading...")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("We're analyzing your preferences to suggest the perfect recipes.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - Shimmer Effect Extension

extension View {
    func shimmering() -> some View {
        self.modifier(ShimmerModifier())
    }
}

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.4),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .rotationEffect(.degrees(30))
                    .offset(x: phase)
                    .clipped()
            )
            .onAppear {
                withAnimation(
                    Animation.linear(duration: 1.5)
                        .repeatForever(autoreverses: false)
                ) {
                    phase = 400
                }
            }
    }
}
