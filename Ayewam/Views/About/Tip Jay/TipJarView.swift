//
//  TipJarView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import SwiftUI
import StoreKit

/// Main tip jar UI component for Ayewam
/// Culturally-sensitive design focused on preserving Ghanaian culinary heritage
struct TipJarView: View {
    @StateObject private var tipStore = TipStore()
    @State private var showThankYou = false
    @State private var lastPurchasedProduct: Product?
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header section
            tipJarHeader
            
            if isExpanded || !tipStore.hasEverTipped {
                tipOptionsSection
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            if tipStore.hasEverTipped {
                toggleButton
            }
        }
        .padding(24)
        .background(tipJarBackground)
        .overlay(thankYouOverlay)
        .onChange(of: tipStore.purchaseState) { _, newState in
            handlePurchaseStateChange(newState)
        }
        .onAppear {
            // Auto-expand if user has never tipped
            if !tipStore.hasEverTipped {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded = true
                }
            }
        }
    }
    
    // MARK: - Header Section
    private var tipJarHeader: some View {
        HStack(spacing: 16) {
            ZStack {
                // Outer glow ring
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("GhanaGold").opacity(0.1),
                                Color("KenteGold").opacity(0.05),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 20,
                            endRadius: 35
                        )
                    )
                    .frame(width: 70, height: 70)
                    .scaleEffect(tipStore.hasEverTipped ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: tipStore.hasEverTipped)
                
                // Main icon background
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("GhanaGold").opacity(0.2), Color("KenteGold").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color("GhanaGold").opacity(0.4), Color("KenteGold").opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .scaleEffect(tipStore.hasEverTipped ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: tipStore.hasEverTipped)
                
                // Cultural icon with enhanced styling
                Text("🫖")
                    .font(.system(size: 28))
                    .symbolEffect(.bounce, options: .repeat(.periodic(delay: 4.0)))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text("Preserve Our Heritage")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primary, Color("GhanaGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // Success indicator for repeat tippers
                    if tipStore.hasEverTipped && tipStore.tipCount > 2 {
                        Image(systemName: "star.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color("GhanaGold"))
                            .symbolEffect(.pulse, options: .repeat(.periodic(delay: 2.0)))
                    }
                }
                
                Text(headerSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .lineSpacing(1)
            }
            
            Spacer()
            
            // Enhanced Ghana flag with shadow
            Text("🇬🇭")
                .font(.system(size: 26))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                .symbolEffect(.pulse, options: .repeat(.periodic(delay: 5.0)))
        }
    }
    
    private var headerSubtitle: String {
        if tipStore.hasEverTipped {
            let tipCountText = tipStore.tipCount == 1 ? "tip" : "tips"
            let medaaseVariation = tipStore.tipCount > 3 ? "Medaase paa" : "Medaase"
            return "\(medaaseVariation) for supporting Ghanaian cuisine! (\(tipStore.tipCount) \(tipCountText))"
        } else {
            return "Help keep traditional recipes alive for future generations"
        }
    }
    
    // MARK: - Tip Options Section
    
    private var tipOptionsSection: some View {
        VStack(spacing: 16) {
            // Availability check
            if !tipStore.isAvailable {
                unavailableView
            } else if tipStore.isLoadingProducts {
                loadingView
            } else {
                availableTipsView
            }
        }
    }
    
    private var unavailableView: some View {
        VStack(spacing: 12) {
            Image(systemName: "network.slash")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
            
            Text("Tips temporarily unavailable")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Try Again") {
                Task {
                    await tipStore.loadProducts()
                }
            }
            .font(.system(size: 14, weight: .medium))
            .foregroundColor(Color("GhanaGold"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("GhanaGold")))
                .scaleEffect(1.2)
            
            Text("Loading tip options...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    private var availableTipsView: some View {
        VStack(spacing: 12) {
            // Cultural mission statement
            missionStatement
            
            // Tip options grid
            LazyVGrid(columns: gridColumns, spacing: 12) {
                ForEach(tipStore.products, id: \.id) { product in
                    TipOptionCard(
                        product: product,
                        tipStore: tipStore,
                        isLoading: isPurchasing(product)
                    )
                }
            }
            
            // Disclaimer
            disclaimerText
        }
    }
    
    private var missionStatement: some View {
        VStack(spacing: 12) {
            // Enhanced mission header with cultural elements
            HStack(spacing: 8) {
                Image(systemName: "heart.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(Color("WarmRed"))
                
                Text("Made with love in Accra, Ghana")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("GhanaGold"), Color("KenteGold")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                
                Text("🇬🇭")
                    .font(.system(size: 14))
            }
            
            // Enhanced mission description with better formatting
            VStack(spacing: 8) {
                Text("Your support helps preserve traditional recipes and share authentic Ghanaian cuisine with the world.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                
                // Cultural heritage emphasis
                HStack(spacing: 4) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color("ForestGreen"))
                    
                    Text("Preserving culture, one recipe at a time")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .italic()
                    
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color("ForestGreen"))
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("GhanaGold").opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("GhanaGold").opacity(0.2), lineWidth: 1)
                )
        )
        .padding(.bottom, 8)
    }
    
    private var disclaimerText: some View {
        Text("Tips support app development and cultural preservation research.")
            .font(.caption2)
            .foregroundColor(Color(UIColor.tertiaryLabel))
            .multilineTextAlignment(.center)
            .padding(.top, 8)
    }
    
    // MARK: - Toggle Button
    
    private var toggleButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        }) {
            HStack(spacing: 8) {
                Text(isExpanded ? "Hide Options" : "Show Tip Options")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color("GhanaGold"))
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(Color("GhanaGold"))
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
    }
    
    // MARK: - Background and Overlay
    
    private var tipJarBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color("GhanaGold").opacity(0.3), Color("KenteGold").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
    
    private var thankYouOverlay: some View {
        Group {
            if showThankYou {
                ThankYouView(
                    message: tipStore.getThankYouMessage(),
                    product: lastPurchasedProduct,
                    onDismiss: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showThankYou = false
                        }
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
            }
        }
    }
    
    // MARK: - Helper Properties
    
    private var gridColumns: [GridItem] {
        [
            GridItem(.flexible(), spacing: 8),
            GridItem(.flexible(), spacing: 8)
        ]
    }
    
    private func isPurchasing(_ product: Product) -> Bool {
        if case .purchasing(let purchasingProduct) = tipStore.purchaseState {
            return purchasingProduct.id == product.id
        }
        return false
    }
    
    // MARK: - Event Handlers
    
    private func handlePurchaseStateChange(_ newState: TipStore.PurchaseState) {
        switch newState {
        case .success(let product):
            lastPurchasedProduct = product
            
            // Show thank you with delay for better UX
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    showThankYou = true
                }
                
                // Auto-dismiss thank you after 4 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    if showThankYou {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showThankYou = false
                        }
                    }
                }
            }
            
            // Auto-collapse after successful tip (unless it's their first)
            if tipStore.tipCount > 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                }
            }
            
        case .failed(let error):
            print("🚨 Tip purchase failed: \(error.localizedDescription)")
            // Could show a subtle error state here, but we keep it graceful
            
        default:
            break
        }
    }
}

// MARK: - Tip Option Card Component

struct TipOptionCard: View {
    let product: Product
    let tipStore: TipStore
    let isLoading: Bool
    
    @State private var isPressed = false
    @State private var showShimmer = false
    
    var body: some View {
        Button(action: {
            // Enhanced haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            Task {
                await tipStore.purchase(product)
            }
        }) {
            VStack(spacing: 14) {
                // Enhanced emoji and price section
                VStack(spacing: 8) {
                    ZStack {
                        // Subtle glow effect behind emoji
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        tipEmojiColor.opacity(0.2),
                                        tipEmojiColor.opacity(0.05),
                                        Color.clear
                                    ],
                                    center: .center,
                                    startRadius: 5,
                                    endRadius: 20
                                )
                            )
                            .frame(width: 40, height: 40)
                        
                        Text(tipStore.tipEmoji(for: product))
                            .font(.system(size: 32))
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                    }
                    
                    // Enhanced price display
                    VStack(spacing: 2) {
                        Text(product.formattedPrice)
                            .font(.system(size: 19, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.primary, Color("GhanaGold")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        // Value indicator for larger tips
                        if let priceDouble = Double(product.price.description), priceDouble >= 4.99 {
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(Color("GhanaGold"))
                                
                                Text("Popular")
                                    .font(.system(size: 9, weight: .semibold))
                                    .foregroundColor(Color("GhanaGold"))
                                
                                Image(systemName: "star.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(Color("GhanaGold"))
                            }
                        }
                    }
                }
                
                // Enhanced name and description
                VStack(spacing: 6) {
                    Text(tipStore.tipOptionName(for: product))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text(tipStore.tipOptionDescription(for: product))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 130)
            .padding(18)
            .background(cardBackground)
            .overlay(shimmerOverlay)
            .overlay(loadingOverlay)
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: isPressed)
        }
        .disabled(isLoading || !tipStore.isAvailable)
        .buttonStyle(.plain)
        .pressEvents {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = true
            }
        } onRelease: {
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = false
            }
        }
        .onAppear {
            // Subtle shimmer effect on appear
            withAnimation(.easeInOut(duration: 1.5).delay(Double.random(in: 0...0.5))) {
                showShimmer = true
            }
        }
    }
    
    // MARK: - Card Styling
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(
                isPressed ?
                LinearGradient(
                    colors: [Color("GhanaGold").opacity(0.08), Color("KenteGold").opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                    LinearGradient(
                        colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.95)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(
                        LinearGradient(
                            colors: isPressed ?
                            [Color("GhanaGold").opacity(0.6), Color("KenteGold").opacity(0.3)] :
                                [Color("GhanaGold").opacity(0.3), Color("KenteGold").opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: isPressed ? 2 : 1.5
                    )
            )
            .shadow(
                color: isPressed ? Color("GhanaGold").opacity(0.2) : Color.black.opacity(0.08),
                radius: isPressed ? 8 : 6,
                x: 0,
                y: isPressed ? 4 : 3
            )
    }
    
    private var shimmerOverlay: some View {
        Group {
            if showShimmer && !isLoading {
                RoundedRectangle(cornerRadius: 18)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color.white.opacity(0.1),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(showShimmer ? 0.6 : 0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false), value: showShimmer)
            }
        }
    }
    
    private var loadingOverlay: some View {
        Group {
            if isLoading {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        VStack(spacing: 8) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color("GhanaGold")))
                                .scaleEffect(1.1)
                            
                            Text("Processing...")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    )
            }
        }
    }
    
    private var tipEmojiColor: Color {
        guard let priceDouble = Double(product.price.description) else {
            return Color("GhanaGold")
        }
        
        switch priceDouble {
        case 0.0...1.5:
            return Color("KenteGold")
        case 1.5...3.5:
            return Color("GhanaGold")
        case 3.5...6.0:
            return Color("WarmRed")
        default:
            return Color("ForestGreen")
        }
    }
}

// MARK: - Thank You View Component

struct ThankYouView: View {
    let message: String
    let product: Product?
    let onDismiss: () -> Void
    
    @State private var showConfetti = false
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Enhanced celebration section
            VStack(spacing: 12) {
                ZStack {
                    // Animated celebration background
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color("GhanaGold").opacity(0.2),
                                    Color("KenteGold").opacity(0.1),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 50
                            )
                        )
                        .frame(width: 100, height: 100)
                        .scaleEffect(animateContent ? 1.1 : 0.8)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateContent)
                    
                    // Multiple celebration emojis
                    VStack(spacing: 4) {
                        HStack(spacing: 8) {
                            Text("🎉")
                                .font(.system(size: 32))
                                .symbolEffect(.bounce, options: .repeat(.continuous))
                            
                            Text("🇬🇭")
                                .font(.system(size: 28))
                                .symbolEffect(.pulse, options: .repeat(.periodic(delay: 1.0)))
                        }
                        
                        Text("✨")
                            .font(.system(size: 20))
                            .symbolEffect(.variableColor, options: .repeat(.continuous))
                    }
                }
                
                // Enhanced thank you message
                VStack(spacing: 8) {
                    Text(message)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.primary, Color("GhanaGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                    
                    // Cultural subtitle
                    Text("🫖 Akwaaba to our heritage preservation mission! 🫖")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color("KenteGold"))
                        .multilineTextAlignment(.center)
                        .italic()
                }
            }
            
            // Enhanced product acknowledgment
            if let product = product {
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.green)
                        
                        Text("Thank you for your \(product.formattedPrice) contribution!")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.primary)
                    }
                    
                    // Show tip level achievement
                    if let priceDouble = Double(product.price.description) {
                        HStack(spacing: 6) {
                            achievementIcon(for: priceDouble)
                            
                            Text(achievementText(for: priceDouble))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color("GhanaGold").opacity(0.1))
                                .overlay(
                                    Capsule()
                                        .stroke(Color("GhanaGold").opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                }
            }
            
            // Enhanced heritage message
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("WarmRed"))
                    
                    Text("Preserving Culture Together")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("WarmRed"))
                }
                
                Text("Your support helps preserve Ghana's rich culinary heritage for future generations. Every traditional recipe tells a story of our ancestors and their wisdom.")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.horizontal, 8)
            }
            
            // Enhanced dismiss button
            Button(action: onDismiss) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.forward.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Continue Exploring")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color("GhanaGold"), Color("KenteGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .shadow(color: Color("GhanaGold").opacity(0.4), radius: 8, x: 0, y: 4)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.top, 8)
        }
        .padding(28)
        .background(thankYouBackground)
        .scaleEffect(animateContent ? 1.0 : 0.9)
        .opacity(animateContent ? 1.0 : 0.0)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.1)) {
                animateContent = true
            }
        }
    }
    
    private var thankYouBackground: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color("GhanaGold").opacity(0.05),
                                Color("KenteGold").opacity(0.03),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(
                        LinearGradient(
                            colors: [Color("GhanaGold").opacity(0.4), Color("KenteGold").opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.black.opacity(0.2), radius: 20, x: 0, y: 10)
    }
    
    private func achievementIcon(for amount: Double) -> some View {
        Group {
            switch amount {
            case 0.0...1.5:
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(Color("KenteGold"))
            case 1.5...3.5:
                Image(systemName: "book.fill")
                    .foregroundColor(Color("GhanaGold"))
            case 3.5...6.0:
                Image(systemName: "star.fill")
                    .foregroundColor(Color("WarmRed"))
            default:
                Image(systemName: "crown.fill")
                    .foregroundColor(Color("ForestGreen"))
            }
        }
        .font(.system(size: 12))
    }
    
    private func achievementText(for amount: Double) -> String {
            switch amount {
            case 0.0...1.5:
                return "Koko Supporter"
            case 1.5...3.5:
                return "Recipe Researcher"
            case 3.5...6.0:
                return "Heritage Guardian"
            default:
                return "Cultural Champion"
            }
        }
    }

// MARK: - Press Events Extension

extension View {
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Preview

#Preview("Default State") {
    ScrollView {
        VStack(spacing: 20) {
            TipJarView()
            
            Spacer(minLength: 100)
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}

#Preview("With Previous Tips") {
    ScrollView {
        VStack(spacing: 20) {
            TipJarView()
                .onAppear {
                    // Simulate having tipped before
                    UserDefaults.standard.set(true, forKey: "hasEverTipped")
                    UserDefaults.standard.set(2, forKey: "tipCount")
                    UserDefaults.standard.set(5.98, forKey: "totalTipsReceived")
                }
            
            Spacer(minLength: 100)
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
