//
//  LoadingView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    let style: LoadingStyle
    
    enum LoadingStyle {
        case `default`
        case cards
        case hero
        case minimal
    }
    
    init(message: String = "Loading...", style: LoadingStyle = .default) {
        self.message = message
        self.style = style
    }
    
    var body: some View {
        Group {
            switch style {
            case .default:
                defaultLoadingView
            case .cards:
                cardSkeletonView
            case .hero:
                heroSkeletonView
            case .minimal:
                minimalLoadingView
            }
        }
    }
    
    // MARK: - Default Loading View
    private var defaultLoadingView: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color("GhanaGold").opacity(0.1))
                    .frame(width: 80, height: 80)
                    .scaleEffect(1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: true)
                
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color("GhanaGold")))
            }
            
            VStack(spacing: 8) {
                Text(message)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Preparing authentic recipes...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Card Skeleton View
    private var cardSkeletonView: some View {
        LazyVStack(spacing: 16) {
            ForEach(0..<6, id: \.self) { index in
                RecipeCardSkeleton()
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
        .padding(.top, 20)
    }
    
    // MARK: - Hero Skeleton View
    private var heroSkeletonView: some View {
        VStack(spacing: 24) {
            // Hero card skeleton
            VStack(alignment: .leading, spacing: 0) {
                ShimmerRectangle(height: 180, cornerRadius: 24)
                
                VStack(alignment: .leading, spacing: 12) {
                    ShimmerRectangle(height: 20, width: 180, cornerRadius: 8)
                    ShimmerRectangle(height: 14, width: 240, cornerRadius: 6)
                    
                    HStack(spacing: 12) {
                        ShimmerRectangle(height: 12, width: 60, cornerRadius: 4)
                        ShimmerRectangle(height: 12, width: 80, cornerRadius: 4)
                        Spacer()
                    }
                }
                .padding(20)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.horizontal, 24)
            
            // Category skeleton
            HStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { _ in
                    ShimmerRectangle(height: 40, width: 100, cornerRadius: 20)
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
    
    // MARK: - Minimal Loading View
    private var minimalLoadingView: some View {
        HStack(spacing: 12) {
            ProgressView()
                .scaleEffect(0.8)
                .progressViewStyle(CircularProgressViewStyle(tint: Color("GhanaGold")))
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Recipe Card Skeleton
struct RecipeCardSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Image skeleton
            ShimmerRectangle(height: 100, width: 100, cornerRadius: 16)
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    ShimmerRectangle(height: 16, width: 160, cornerRadius: 6)
                    ShimmerRectangle(height: 12, width: 120, cornerRadius: 4)
                }
                
                Spacer()
                
                HStack(spacing: 12) {
                    ShimmerRectangle(height: 10, width: 50, cornerRadius: 4)
                    ShimmerRectangle(height: 10, width: 60, cornerRadius: 4)
                    Spacer()
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
        )
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Shimmer Rectangle Component
struct ShimmerRectangle: View {
    let height: CGFloat
    var width: CGFloat?
    let cornerRadius: CGFloat
    
    @State private var shimmerOffset: CGFloat = -200
    
    var body: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .frame(height: height)
            .frame(width: width)
            .cornerRadius(cornerRadius)
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
                    .cornerRadius(cornerRadius)
                    .offset(x: shimmerOffset)
                    .animation(
                        .easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: shimmerOffset
                    )
            )
            .clipped()
            .onAppear {
                shimmerOffset = 200
            }
    }
}

// MARK: - Previews
#Preview("Default Loading") {
    LoadingView(message: "Loading recipes...", style: .default)
}

#Preview("Card Skeletons") {
    LoadingView(message: "Loading recipes...", style: .cards)
}

#Preview("Hero Skeleton") {
    LoadingView(message: "Loading recipes...", style: .hero)
}

#Preview("Minimal Loading") {
    LoadingView(message: "Loading...", style: .minimal)
}
