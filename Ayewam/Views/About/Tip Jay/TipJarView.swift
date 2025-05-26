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
            // Cultural icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color("GhanaGold").opacity(0.2), Color("KenteGold").opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .scaleEffect(tipStore.hasEverTipped ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: tipStore.hasEverTipped)
                
                Text("🫖")
                    .font(.system(size: 28))
                    .symbolEffect(.bounce, options: .repeat(.periodic(delay: 3.0)))
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Preserve Our Heritage")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.primary)
                
                Text(headerSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            Text("🇬🇭")
                .font(.system(size: 24))
        }
    }
    
    private var headerSubtitle: String {
        if tipStore.hasEverTipped {
            return "Medaase for supporting Ghanaian cuisine! (\(tipStore.tipCount) tip\(tipStore.tipCount == 1 ? "" : "s"))"
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
            
            disclaimerText
        }
    }
    
    private var missionStatement: some View {
        VStack(spacing: 8) {
            Text("Made with love in Accra, Ghana 🇬🇭")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color("GhanaGold"))
            
            Text("Your support helps preserve traditional recipes and share authentic Ghanaian cuisine with the world.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
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
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                    if showThankYou {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            showThankYou = false
                        }
                    }
                }
            }
            
            if tipStore.tipCount > 1 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        isExpanded = false
                    }
                }
            }
            
        case .failed(let error):
            print("🚨 Tip purchase failed: \(error.localizedDescription)")
            
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
    
    var body: some View {
        Button(action: {
            Task {
                await tipStore.purchase(product)
            }
        }) {
            VStack(spacing: 12) {
                VStack(spacing: 6) {
                    Text(tipStore.tipEmoji(for: product))
                        .font(.system(size: 32))
                    
                    Text(product.formattedPrice)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                // Name and description
                VStack(spacing: 4) {
                    Text(tipStore.tipOptionName(for: product))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(tipStore.tipOptionDescription(for: product))
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isPressed ? Color("GhanaGold").opacity(0.1) : Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                Color("GhanaGold").opacity(isPressed ? 0.6 : 0.3),
                                lineWidth: isPressed ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .overlay(loadingOverlay)
        }
        .disabled(isLoading || !tipStore.isAvailable)
        .buttonStyle(.plain)
        .onTapGesture {
            // Haptic feedback
            let impact = UIImpactFeedbackGenerator(style: .medium)
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
    
    private var loadingOverlay: some View {
        Group {
            if isLoading {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color("GhanaGold")))
                    )
            }
        }
    }
}

// MARK: - Thank You View Component

struct ThankYouView: View {
    let message: String
    let product: Product?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Celebration animation
            VStack(spacing: 8) {
                Text("🎉")
                    .font(.system(size: 40))
                    .symbolEffect(.bounce, options: .repeat(.continuous))
                
                Text(message)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            
            // Product acknowledgment
            if let product = product {
                Text("Thank you for your \(product.formattedPrice) contribution!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Heritage message
            Text("Your support helps preserve Ghana's rich culinary heritage for future generations.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Dismiss button
            Button("Continue", action: onDismiss)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color("GhanaGold"), Color("KenteGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
                .padding(.top, 8)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color("GhanaGold").opacity(0.4), lineWidth: 2)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 16, x: 0, y: 8)
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
