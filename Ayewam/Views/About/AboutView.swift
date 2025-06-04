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
                recipeSubmissionSection
                
                // About Section
                aboutContentSection
                
                // Tip Jar Section
                tipJarSection
                
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
    
    // MARK: - About Section
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
                    GridItem(.fixed(150), spacing: 12),
                    GridItem(.fixed(150), spacing: 12)
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
                        icon: "globe",
                        title: "Authentic",
                        description: "Traditional dishes from all regions",
                        color: Color("ForestGreen")
                    )
                    
                    FeatureHighlightCard(
                        icon: "sparkles",
                        title: "Cultural",
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
        }
    }
    
    // MARK: - Recipe Submission Card
    private var recipeSubmissionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color("GhanaGold").opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color("GhanaGold"), Color("KenteGold")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .symbolEffect(.bounce, options: .repeat(.periodic(delay: 4.0)))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Help Us Grow")
                        .headingLarge()
                        .foregroundColor(.primary)
                    
                    Text("Suggest traditional dishes you love")
                        .bodyMedium()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Submission card
            VStack(alignment: .leading, spacing: 20) {
                Text("Missing a cherished family recipe? Help preserve Ghana's culinary heritage by sharing dishes you'd love to see in Ayewam.")
                    .bodyMedium()
                    .foregroundColor(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Call-to-action button
                Button(action: {
                    showingSubmissionView = true
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Suggest a Recipe")
                            .labelLarge()
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
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
                                    colors: [Color("GhanaGold").opacity(0.2), Color("KenteGold").opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Tip Jar Section
    private var tipJarSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section header
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color("WarmRed").opacity(0.1))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 28))
                        .foregroundColor(Color("WarmRed"))
                        .symbolEffect(.pulse, options: .repeat(.periodic(delay: 3.0)))
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("Support Our Mission")
                        .headingLarge()
                        .foregroundColor(.primary)
                    
                    Text("Help preserve Ghanaian culinary traditions")
                        .bodyMedium()
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            // Cultural heritage message
            VStack(alignment: .leading, spacing: 16) {
                Text("Every traditional recipe tells a story of family gatherings, cultural celebrations, and generations of culinary wisdom. Your support helps preserve Ghana's rich heritage for future generations.")
                    .bodyMedium()
                    .foregroundColor(.primary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Tip jar component
                TipJarView()
            }
        }
    }
    
    // MARK: - Credits Section
    private var creditsSection: some View {
        VStack(spacing: 24) {
            // Main credits card
            VStack(spacing: 20) {
                // Ghana pride header
                HStack(spacing: 12) {
                    Text("🇬🇭")
                        .font(.system(size: 32))
                        .symbolEffect(.pulse, options: .repeat(.periodic(delay: 4.0)))
                    
                    VStack(spacing: 4) {
                        Text("Made with ❤️ in Ghana")
                            .headingMedium()
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.primary, Color("WarmRed")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                        
                        Text("Preserving culture through technology")
                            .bodySmall()
                            .foregroundColor(.secondary)
                            .italic()
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showCredits.toggle()
                        }
                    }) {
                        Image(systemName: showCredits ? "chevron.up" : "chevron.down")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                }
                
                // Expandable credits
                if showCredits {
                    VStack(spacing: 12) {
                        Divider()
                            .overlay(Color("GhanaGold").opacity(0.3))
                        
                        VStack(spacing: 8) {
                            Text("Version 1.0")
                                .labelMedium()
                                .foregroundColor(.primary)
                            
                            Text("© 2025 Justyn Adusei-Prempeh")
                                .bodySmall()
                                .foregroundColor(.secondary)
                            
                            Text("Built with SwiftUI & Core Data")
                                .captionSmall()
                                .foregroundColor(Color(UIColor.tertiaryLabel))
                        }
                    }
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [Color("WarmRed").opacity(0.2), Color("GhanaGold").opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 100)
    }
}

// MARK: - Feature Highlights
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
                    .lineLimit(2)
                    .frame(height: 40, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 80)
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
