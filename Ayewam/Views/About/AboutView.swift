//
//  AboutView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/24/25.
//

import SwiftUI

struct AboutView: View {
    @State private var showCredits = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                // Hero section
                VStack(alignment: .center, spacing: 24) {
                    ZStack {
                        // Animated background circles
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.ghGreen.opacity(0.15), Color.ghYellow.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 140, height: 140)
                            .scaleEffect(1.0)
                            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: true)
                        
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.ghRed.opacity(0.1), Color.ghYellow.opacity(0.1)],
                                    startPoint: .bottomLeading,
                                    endPoint: .topTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .scaleEffect(0.9)
                            .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: true)
                        
                        Image(systemName: "book.closed.fill")
                            .font(.system(size: 52))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.ghGreen, Color.ghYellow, Color.ghRed],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.bounce, options: .repeat(.periodic(delay: 3.0)))
                    }
                    
                    VStack(spacing: 12) {
                        Text("Ayewam")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, .primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Authentic Ghanaian Recipes")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 8)
                
                // Feature highlights
                VStack(spacing: 20) {
                    ModernFeatureCard(
                        title: "About Ayewam",
                        description: "Ayewam is your guide to authentic Ghanaian cuisine, offering traditional recipes with step-by-step instructions. Explore the rich culinary heritage of Ghana through our carefully curated collection of dishes.",
                        icon: "info.circle.fill",
                        gradientColors: [.blue, .cyan]
                    )
                    
                    ModernFeatureCard(
                        title: "Smart Cooking",
                        description: "Experience guided cooking with integrated timers, step-by-step instructions, and personalized recipe recommendations based on your preferences and cooking history.",
                        icon: "brain.head.profile",
                        gradientColors: [.purple, .pink]
                    )
                    
                    ModernFeatureCard(
                        title: "Ghanaian Cuisine",
                        description: "Discover the rich flavors of Ghana with our collection of traditional stews, soups, and one-pot dishes. Learn about key ingredients like plantains, cassava, yams, and aromatic spices.",
                        icon: "globe.africa.fill",
                        gradientColors: [.green, .mint]
                    )
                }
                
                // Ghana flag section
                VStack(alignment: .leading, spacing: 20) {
                    HStack(spacing: 12) {
                        Image(systemName: "flag.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.orange, .red],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        Text("Republic of Ghana")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    
                    // Animated Ghana flag
                    HStack(spacing: 0) {
                        Color.ghRed
                        Color.ghYellow
                        Color.ghGreen
                    }
                    .frame(height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.4), Color.white.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    
                    Text("The colors represent the mineral wealth (gold), forests and agriculture (green), and the blood of those who fought for independence (red).")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
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
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
                
                Spacer(minLength: 40)
                
                // Credits section
                VStack(spacing: 16) {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showCredits.toggle()
                        }
                    }) {
                        VStack(spacing: 8) {
                            Text("Made with ❤️ in Ghana")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 4) {
                                Text("Tap to view credits")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                
                                Image(systemName: showCredits ? "chevron.up" : "chevron.down")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    
                    if showCredits {
                        VStack(spacing: 8) {
                            Text("Version 1.0")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text("© 2025 Justyn Adusei-Prempeh")
                                .font(.system(size: 14))
                                .foregroundColor(Color(UIColor.tertiaryLabel))

                            Text("Built with SwiftUI & Core Data")
                                .font(.system(size: 12))
                                .foregroundColor(Color(UIColor.quaternaryLabel))
                        }
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 100)
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
        }
        .navigationTitle("About")
        .background(
            LinearGradient(
                colors: [
                    Color(.systemBackground),
                    Color(.systemGray6).opacity(0.2),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
