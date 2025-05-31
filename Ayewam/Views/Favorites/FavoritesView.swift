//
//  FavoritesView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/24/25.
//

import SwiftUI

struct FavoritesView: View {
    @ObservedObject private var viewModel = DataManager.shared.favoriteViewModel
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header section
                    if !viewModel.isLoading && !viewModel.favoriteRecipes.isEmpty {
                        favoritesHeaderSection
                    }
                    
                    // Content section
                    if viewModel.isLoading {
                        favoritesLoadingState
                    } else if let errorMessage = viewModel.errorMessage {
                        ErrorView(errorMessage: errorMessage) {
                            viewModel.loadFavorites()
                        }
                    } else if viewModel.favoriteRecipes.isEmpty {
                        enhancedEmptyFavoritesView
                    } else {
                        enhancedFavoritesListView
                    }
                }
                .padding(.top, 20)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color("FavoriteHeart").opacity(0.02),
                        Color(.systemBackground)
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
    }
    
    private var modernEmptyFavoritesView: some View {
        VStack(spacing: 24) {
            //Empty state
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
            
            // Call-to-action button
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
                //Header with count and animation
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
                    
                    // Animated heart count
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
            .padding(.bottom, 100)
        }
    }
    
    private var favoritesHeaderSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(Color("FavoriteHeart"))
                            .symbolEffect(.bounce, options: .repeat(.periodic(delay: 3.0)))
                        
                        Text("Your Favorites")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, Color("FavoriteHeart")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    }
                    
                    Text("Recipes you've saved for later")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Favorites count badge
                VStack(spacing: 4) {
                    Text("\(viewModel.favoriteRecipes.count)")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(Color("FavoriteHeart"))
                    
                    Text(viewModel.favoriteRecipes.count == 1 ? "recipe" : "recipes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color("FavoriteHeart").opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color("FavoriteHeart").opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Quick stats
            if !viewModel.favoriteRecipes.isEmpty {
                favoritesStatsView
            }
        }
        .padding(.horizontal, 24)
        .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.favoriteRecipes.count)
    }

    private var favoritesStatsView: some View {
        HStack(spacing: 20) {
            // Average cook time
            let avgTime = viewModel.favoriteRecipes.reduce(0) { $0 + $1.prepTime + $1.cookTime } / max(1, Int32(viewModel.favoriteRecipes.count))
            
            StatCard(
                icon: "clock.fill",
                title: "Avg Time",
                value: "\(avgTime) min",
                color: .blue
            )
            
            // Categories count
            let categoryCount = Set(viewModel.favoriteRecipes.flatMap { $0.categoryArray }).count
            
            StatCard(
                icon: "square.grid.2x2.fill",
                title: "Categories",
                value: "\(categoryCount)",
                color: Color("GhanaGold")
            )
            
            // Difficulty spread
            let difficulties = Set(viewModel.favoriteRecipes.compactMap { $0.difficulty }).count
            
            StatCard(
                icon: "speedometer",
                title: "Difficulties",
                value: "\(difficulties)",
                color: .orange
            )
            
            Spacer()
        }
    }

    private var enhancedFavoritesListView: some View {
        LazyVStack(spacing: 16) {
            ForEach(Array(viewModel.favoriteRecipes.enumerated()), id: \.element) { index, recipe in
                NavigationLink {
                    RecipeDetailView(recipe: recipe, viewModel: DataManager.shared.recipeViewModel)
                } label: {
                    EnhancedFavoriteCard(
                        recipe: recipe,
                        onRemove: {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                viewModel.toggleFavorite(recipe)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .move(edge: .trailing).combined(with: .opacity)
                ))
                .animation(
                    .spring(response: 0.5, dampingFraction: 0.7)
                    .delay(Double(index) * 0.05),
                    value: viewModel.favoriteRecipes.count
                )
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 100)
    }

    private var enhancedEmptyFavoritesView: some View {
        VStack(spacing: 32) {
            // Animated heart icon
            ZStack {
                Circle()
                    .fill(Color("FavoriteHeart").opacity(0.1))
                    .frame(width: 120, height: 120)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
                
                Image(systemName: "heart.slash")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(Color("FavoriteHeart").opacity(0.6))
                    .symbolEffect(.bounce, options: .repeat(.periodic(delay: 3.0)))
            }
            
            VStack(spacing: 16) {
                Text("No Favorites Yet")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                
                VStack(spacing: 12) {
                    Text("Start building your collection of favorite Ghanaian recipes")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                    
                    Text("Tap the ❤️ on any recipe to save it here")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule()
                                .fill(Color(.systemGray6))
                        )
                }
            }
            
            // Call to action
            Button(action: {
                // Post notification to switch to home tab
                NotificationCenter.default.post(name: .switchToHomeTab, object: nil)
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "heart.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                    
                    Text("Discover Recipes")
                        .font(.system(size: 17, weight: .semibold))
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color("FavoriteHeart"), Color("FavoriteHeart").opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color("FavoriteHeart").opacity(0.3), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 40)
        .padding(.vertical, 60)
    }

    private var favoritesLoadingState: some View {
        VStack(spacing: 24) {
            // Header skeleton
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    ShimmerRectangle(height: 24, width: 180, cornerRadius: 8)
                    ShimmerRectangle(height: 14, width: 220, cornerRadius: 6)
                }
                
                Spacer()
                
                ShimmerRectangle(height: 60, width: 80, cornerRadius: 16)
            }
            .padding(.horizontal, 24)
            
            // Cards skeleton
            LazyVStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { index in
                    FavoriteCardSkeleton()
                        .opacity(1.0 - (Double(index) * 0.1))
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: true
                        )
                }
            }
            .padding(.horizontal, 24)
        }
    }

    // MARK: - Supporting Components

    struct StatCard: View {
        let icon: String
        let title: String
        let value: String
        let color: Color
        
        var body: some View {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
                
                Text(value)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }

    struct EnhancedFavoriteCard: View {
        let recipe: Recipe
        let onRemove: () -> Void
        @State private var isPressed = false
        @State private var showingRemoveConfirmation = false
        
        var body: some View {
            HStack(spacing: 16) {
                // Recipe image with favorite overlay
                ZStack(alignment: .topTrailing) {
                    if let imageName = recipe.imageName, !imageName.isEmpty {
                        AsyncImageView.asset(imageName, cornerRadius: 18)
                            .frame(width: 100, height: 100)
                            .clipped()
                    } else {
                        AsyncImageView.placeholder(
                            color: Color("FavoriteHeart").opacity(0.3),
                            text: recipe.name,
                            cornerRadius: 18
                        )
                        .frame(width: 100, height: 100)
                    }
                    
                    // Animated favorite indicator
                    ZStack {
                        Circle()
                            .fill(Color("FavoriteHeart").opacity(0.2))
                            .frame(width: 32, height: 32)
                            .blur(radius: 4)
                        
                        Circle()
                            .fill(Color("FavoriteHeart"))
                            .frame(width: 26, height: 26)
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color("FavoriteHeart").opacity(0.4), radius: 3, x: 0, y: 2)
                    }
                    .offset(x: 4, y: -4)
                    .symbolEffect(.pulse, options: .repeat(.periodic(delay: 4.0)))
                }
                
                // Recipe content
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(recipe.name ?? "Unknown Recipe")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .lineLimit(2)
                        
                        if let description = recipe.recipeDescription, !description.isEmpty {
                            Text(description)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                                .lineSpacing(1)
                        }
                    }
                    
                    // Recipe metadata
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
                }
                
                // Remove button
                Button(action: {
                    showingRemoveConfirmation = true
                }) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("FavoriteHeart"))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color("FavoriteHeart").opacity(0.1))
                                .overlay(
                                    Circle()
                                        .stroke(Color("FavoriteHeart").opacity(0.3), lineWidth: 1)
                                )
                        )
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
                .pressEvents {
                    isPressed = true
                } onRelease: {
                    isPressed = false
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
                                    colors: [Color("FavoriteHeart").opacity(0.2), Color.clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            .confirmationDialog(
                "Remove from Favorites",
                isPresented: $showingRemoveConfirmation,
                titleVisibility: .visible
            ) {
                Button("Remove", role: .destructive) {
                    onRemove()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Remove \"\(recipe.name ?? "this recipe")\" from your favorites?")
            }
        }
    }

    struct FavoriteCardSkeleton: View {
        var body: some View {
            HStack(spacing: 16) {
                // Image skeleton
                ShimmerRectangle(height: 100, width: 100, cornerRadius: 18)
                
                // Content skeleton
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        ShimmerRectangle(height: 18, width: 180, cornerRadius: 6)
                        ShimmerRectangle(height: 14, width: 140, cornerRadius: 4)
                    }
                    
                    HStack(spacing: 12) {
                        ShimmerRectangle(height: 12, width: 60, cornerRadius: 6)
                        ShimmerRectangle(height: 12, width: 70, cornerRadius: 6)
                        Spacer()
                    }
                }
                
                // Button skeleton
                ShimmerRectangle(height: 44, width: 44, cornerRadius: 22)
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
    }
}

#Preview {
    NavigationView {
        FavoritesView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
