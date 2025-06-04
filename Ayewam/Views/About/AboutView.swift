import SwiftUI

struct AboutView: View {
    @State private var showCredits = false
    @State private var showingSubmissionView = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                // Hero section
                heroSection
                
                // Recipe Submission Card
                RecipeSubmissionCard(showingSubmissionView: $showingSubmissionView)
                
                // Feature highlights
                featureHighlights
                
                // Tip Jar Section
                tipJarSection
                
                // Ghana flag section
                ghanaFlagSection
                
                // Credits section
                creditsSection
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
        .toast(position: .top)
        .sheet(isPresented: $showingSubmissionView) {
            RecipeSubmissionView()
        }
    }
    
    // MARK: - Hero Section
    private var heroSection: some View {
        VStack(alignment: .center, spacing: 24) {
            ZStack {
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
    }
    
    // MARK: - Feature Highlights
    private var featureHighlights: some View {
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
    }
    
    // MARK: - Tip Jar Section
    private var tipJarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section header
            HStack(spacing: 12) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 20))
                    .foregroundColor(Color("GhanaGold"))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Support Our Mission")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.primary)
                    
                    Text("Help preserve Ghanaian culinary traditions")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            .padding(.bottom, 8)
            
            // Cultural introduction text
            VStack(alignment: .leading, spacing: 12) {
                Text("Ayewam was born from a love of authentic Ghanaian cuisine and a desire to share our rich culinary heritage with the world.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
                
                Text("Every traditional recipe tells a story—of family gatherings, cultural celebrations, and generations of culinary wisdom passed down through time.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            .padding(.bottom, 16)
            
            TipJarView()
            
            // Community impact statement
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "globe.africa.fill")
                        .font(.system(size: 16))
                        .foregroundColor(Color("ForestGreen"))
                    
                    Text("Community Impact")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
                
                Text("Your support helps us research new recipes, work with Ghanaian chefs and home cooks, and ensure that traditional cooking methods are accurately documented for future generations.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
            .padding(.top, 16)
            .padding(.horizontal, 4)
        }
    }
    
    // MARK: - Ghana Flag Section
    private var ghanaFlagSection: some View {
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
    }
    
    // MARK: - Credits Section
    private var creditsSection: some View {
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
}

// MARK: - Recipe Submission Card
struct RecipeSubmissionCard: View {
    @Binding var showingSubmissionView: Bool
    @State private var animateGradient = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 16) {
                ZStack {
                    // Animated background circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: animateGradient ?
                                    [Color("GhanaGold").opacity(0.2), Color("KenteGold").opacity(0.3)] :
                                    [Color("KenteGold").opacity(0.3), Color("GhanaGold").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)
                        .scaleEffect(animateGradient ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateGradient)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("GhanaGold"), Color("KenteGold")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.bounce, options: .repeat(.periodic(delay: 3.0)))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Help Us Grow Our Recipe Collection")
                        .headingLarge()
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text("Suggest traditional dishes you love")
                        .headingMedium()
                        .foregroundColor(.secondary)
            }
                
                Spacer()
            }
            
            // Description
            VStack(alignment: .leading, spacing: 12) {
                Text("Missing a recipe you cherish? Help us preserve Ghana's rich culinary heritage by suggesting traditional dishes you'd like to see in the app.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
                
                // Feature highlights
                VStack(alignment: .leading, spacing: 8) {
                    FeatureHighlight(
                        icon: "heart.fill",
                        text: "Preserve family recipes",
                        color: .red
                    )
                    
                    FeatureHighlight(
                        icon: "person.2.fill",
                        text: "Help the community discover new dishes",
                        color: .blue
                    )
                    
                    FeatureHighlight(
                        icon: "bell.fill",
                        text: "Get notified when your suggestions are added",
                        color: .orange
                    )
                }
                .padding(.top, 8)
            }
            
            // Call-to-action button
            Button(action: {
                showingSubmissionView = true
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Suggest a Recipe")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
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
            .accessibilityLabel("Suggest a recipe")
            .accessibilityHint("Opens form to suggest a traditional Ghanaian recipe")
        }
        .padding(24)
        .background(
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
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        .onAppear {
            animateGradient = true
        }
    }
}

// MARK: - Feature Highlight Component
struct FeatureHighlight: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(color)
                .frame(width: 20, height: 20)
            
            Text(text)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    NavigationView {
        AboutView()
    }
}
