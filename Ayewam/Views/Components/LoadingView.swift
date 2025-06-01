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
        VStack(spacing: 32) {
            // Logo area
            AnimatedLoadingIcon()
            
            VStack(spacing: 12) {
                Text(message)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Preparing authentic recipes...")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .opacity(0.8)
            }
            
            LoadingDots()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
    
    // MARK: - Card Skeleton View
    private var cardSkeletonView: some View {
        LazyVStack(spacing: 16) {
            ForEach(0..<5, id: \.self) { index in
                EnhancedRecipeCardSkeleton()
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .animation(
                        .easeOut(duration: 0.6)
                        .delay(Double(index) * 0.1),
                        value: true
                    )
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 20)
    }
    
    // MARK: - Hero Skeleton View
    private var heroSkeletonView: some View {
        VStack(spacing: 28) {
            // Hero card skeleton
            VStack(alignment: .leading, spacing: 0) {
                ShimmerRectangle(height: 200, cornerRadius: 24)
                    .overlay(
                        VStack {
                            Spacer()
                            HStack {
                                VStack(alignment: .leading, spacing: 8) {
                                    ShimmerRectangle(height: 12, width: 80, cornerRadius: 6)
                                    ShimmerRectangle(height: 16, width: 120, cornerRadius: 8)
                                }
                                Spacer()
                            }
                            .padding(20)
                        }
                    )
                
                VStack(alignment: .leading, spacing: 16) {
                    ShimmerRectangle(height: 24, width: 200, cornerRadius: 8)
                    ShimmerRectangle(height: 14, width: 280, cornerRadius: 6)
                    
                    HStack(spacing: 16) {
                        ShimmerRectangle(height: 32, width: 80, cornerRadius: 16)
                        ShimmerRectangle(height: 32, width: 100, cornerRadius: 16)
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
                ForEach(0..<3, id: \.self) { index in
                    ShimmerRectangle(height: 44, width: 120, cornerRadius: 22)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.3),
                            value: true
                        )
                }
                Spacer()
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .onAppear {
            // Trigger animations
        }
    }
    
    // MARK: - Enhanced Minimal Loading View
    private var minimalLoadingView: some View {
        HStack(spacing: 12) {
            PulsingCircle()
                .frame(width: 16, height: 16)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

// MARK: - Loading Components

struct AnimatedLoadingIcon: View {
    @State private var isRotating = false
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        ZStack {
            // Outer ring
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color("GhanaGold"), Color("KenteGold")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 4
                )
                .frame(width: 80, height: 80)
                .scaleEffect(scale)
                .rotationEffect(.degrees(isRotating ? 360 : 0))
            
            // Inner elements
            VStack(spacing: 4) {
                Image(systemName: "fork.knife")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(Color("GhanaGold"))
                
                Text("Ayewam")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color("GhanaGold"))
            }
            .scaleEffect(scale)
        }
        .onAppear {
            withAnimation(.linear(duration: 3.0).repeatForever(autoreverses: false)) {
                isRotating = true
            }
            
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

struct LoadingDots: View {
    @State private var animatingDots = [false, false, false]
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color("GhanaGold"))
                    .frame(width: 8, height: 8)
                    .scaleEffect(animatingDots[index] ? 1.3 : 0.8)
                    .opacity(animatingDots[index] ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.6)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: animatingDots[index]
                    )
            }
        }
        .onAppear {
            for i in 0..<3 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.2) {
                    animatingDots[i] = true
                }
            }
        }
    }
}

struct PulsingCircle: View {
    @State private var isPulsing = false
    
    var body: some View {
        Circle()
            .fill(Color("GhanaGold"))
            .scaleEffect(isPulsing ? 1.2 : 0.8)
            .opacity(isPulsing ? 0.6 : 1.0)
            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isPulsing)
            .onAppear {
                isPulsing = true
            }
    }
}

// MARK: - Recipe Card Skeleton
struct EnhancedRecipeCardSkeleton: View {
    @State private var shimmerOffset: CGFloat = -300
    
    var body: some View {
        HStack(spacing: 16) {
            // Image skeleton
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray5))
                .frame(width: 100, height: 100)
                .overlay(shimmerOverlay)
            
            // Content skeleton
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    // Title skeleton
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(.systemGray5))
                        .frame(height: 18)
                        .frame(maxWidth: .infinity)
                        .overlay(shimmerOverlay)
                    
                    // Description skeleton
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 14)
                        .frame(width: 120)
                        .overlay(shimmerOverlay)
                }
                
                Spacer()
                
                // Metadata skeleton
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 24)
                        .overlay(shimmerOverlay)
                    
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray5))
                        .frame(width: 70, height: 24)
                        .overlay(shimmerOverlay)
                    
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .frame(minHeight: 100)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        .onAppear {
            startShimmerAnimation()
        }
    }
    
    private var shimmerOverlay: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(
                LinearGradient(
                    colors: [
                        Color.clear,
                        Color.white.opacity(0.6),
                        Color.clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(x: shimmerOffset)
            .animation(.linear(duration: 1.5).repeatForever(autoreverses: false), value: shimmerOffset)
    }
    
    private func startShimmerAnimation() {
        shimmerOffset = 300
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
                                Color.white.opacity(0.6),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(cornerRadius)
                    .offset(x: shimmerOffset)
                    .animation(
                        .linear(duration: 1.8)
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
