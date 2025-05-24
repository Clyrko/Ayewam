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
        Group {
            if viewModel.isLoading {
                LoadingView(message: "Loading favorites...")
            } else if let errorMessage = viewModel.errorMessage {
                ErrorView(errorMessage: errorMessage) {
                    viewModel.loadFavorites()
                }
            } else if viewModel.favoriteRecipes.isEmpty {
                modernEmptyFavoritesView
            } else {
                modernFavoritesList
            }
        }
        .navigationTitle("Favorites")
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.3)
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
}

#Preview {
    NavigationView {
        FavoritesView()
    }
    .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
