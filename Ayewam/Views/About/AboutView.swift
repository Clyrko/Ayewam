import SwiftUI

struct AboutView: View {
    @State private var showCredits = false
    @State private var showingSubmissionView = false
    @State private var animatingHero = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                // Hero section
                heroSection
                
                // Recipe Submission Card
                RecipeSubmissionCard(showingSubmissionView: $showingSubmissionView)
                
                // About Section
                aboutContentSection
                
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
        VStack(alignment: .center, spacing: 28) {
            // App icon
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color("GhanaGold").opacity(0.15),
                                Color("KenteGold").opacity(0.08),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 30,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)
                    .scaleEffect(animatingHero ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: animatingHero)
                
                // Main icon background
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [Color("GhanaGold").opacity(0.4), Color("KenteGold").opacity(0.2)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                    )
                    .shadow(color: Color("GhanaGold").opacity(0.2), radius: 12, x: 0, y: 6)
                
                // App icon
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color("GhanaGold"), Color("KenteGold"), Color("ForestGreen")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, options: .repeat(.periodic(delay: 4.0)))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
            
            // App branding
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("Ayewam")
                        .brand()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.primary, Color("GhanaGold")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("🇬🇭")
                        .font(.system(size: 32))
                        .symbolEffect(.pulse, options: .repeat(.periodic(delay: 5.0)))
                }
                
                VStack(spacing: 4) {
                    Text("Authentic Ghanaian Recipes")
                        .headingMedium()
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("Preserving culinary heritage, one recipe at a time")
                        .bodyMedium()
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .italic()
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .onAppear {
            animatingHero = true
        }
    }
    
    // MARK: - Feature Highlights
    private var aboutContentSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Section header
            VStack(alignment: .leading, spacing: 8) {
                Text("About Ayewam")
                    .displaySmall()
                    .foregroundColor(.primary)
                
                Text("Your gateway to authentic Ghanaian cuisine")
                    .bodyLarge()
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 24)
            
            // Main about card
            VStack(alignment: .leading, spacing: 20) {
                // Mission statement
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color("ForestGreen").opacity(0.1))
                                .frame(width: 50, height: 50)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color("ForestGreen"))
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Our Mission")
                                .headingMedium()
                                .foregroundColor(.primary)
                            
                            Text("Preserving Ghana's culinary heritage")
                                .bodySmall()
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    
                    Text("Ayewam connects you with authentic Ghanaian recipes passed down through generations. From bustling Accra markets to quiet village kitchens, we bring traditional flavors and cooking techniques to your home.")
                        .bodyMedium()
                        .foregroundColor(.primary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Feature highlights grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 16) {
                    FeatureHighlightCard(
                        icon: "brain.head.profile",
                        title: "Smart Cooking",
                        description: "AI-powered recommendations and guided cooking",
                        color: Color("GhanaGold")
                    )
                    
                    FeatureHighlightCard(
                        icon: "timer",
                        title: "Perfect Timing",
                        description: "Multi-timer system for complex dishes",
                        color: Color("TimerActive")
                    )
                    
                    FeatureHighlightCard(
                        icon: "globe.africa.fill",
                        title: "Authentic Recipes",
                        description: "Traditional dishes from all regions",
                        color: Color("ForestGreen")
                    )
                    
                    FeatureHighlightCard(
                        icon: "sparkles",
                        title: "Cultural Context",
                        description: "Learn the stories behind each dish",
                        color: Color("WarmRed")
                    )
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(
                                LinearGradient(
                                    colors: [Color("ForestGreen").opacity(0.2), Color("GhanaGold").opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
            .padding(.horizontal, 24)
        }
    }
    
    struct FeatureHighlightCard: View {
        let icon: String
        let title: String
        let description: String
        let color: Color
        
        var body: some View {
            VStack(alignment: .leading, spacing: 12) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .headingSmall()
                        .foregroundColor(.primary)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(color.opacity(0.15), lineWidth: 1)
                    )
            )
            .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
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
