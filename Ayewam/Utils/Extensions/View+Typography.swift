//
//  View+Typography.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 6/1/25.
//

import SwiftUI

// MARK: - Typography View Extensions
extension View {
    
    // MARK: - Display Styles
    /// Apply display large typography (hero titles, app branding)
    func displayLarge() -> some View {
        self.font(Typography.displayLarge)
    }
    
    /// Apply display medium typography (recipe names, major headings)
    func displayMedium() -> some View {
        self.font(Typography.displayMedium)
    }
    
    /// Apply display small typography (section titles, category names)
    func displaySmall() -> some View {
        self.font(Typography.displaySmall)
    }
    
    // MARK: - Heading Styles
    /// Apply large heading typography (card titles, step headers)
    func headingLarge() -> some View {
        self.font(Typography.headingLarge)
    }
    
    /// Apply medium heading typography (subsection headers)
    func headingMedium() -> some View {
        self.font(Typography.headingMedium)
    }
    
    /// Apply small heading typography (small headers, metadata labels)
    func headingSmall() -> some View {
        self.font(Typography.headingSmall)
    }
    
    // MARK: - Body Styles
    /// Apply large body typography (primary descriptions)
    func bodyLarge() -> some View {
        self.font(Typography.bodyLarge)
            .lineSpacing(TypographyMetrics.bodyLineSpacing)
    }
    
    /// Apply medium body typography (secondary text, ingredient lists)
    func bodyMedium() -> some View {
        self.font(Typography.bodyMedium)
            .lineSpacing(TypographyMetrics.bodyLineSpacing)
    }
    
    /// Apply small body typography (compact information)
    func bodySmall() -> some View {
        self.font(Typography.bodySmall)
            .lineSpacing(TypographyMetrics.bodyLineSpacing)
    }
    
    // MARK: - Label Styles
    /// Apply large label typography (button text, important labels)
    func labelLarge() -> some View {
        self.font(Typography.labelLarge)
    }
    
    /// Apply medium label typography (form labels, tab titles)
    func labelMedium() -> some View {
        self.font(Typography.labelMedium)
    }
    
    /// Apply small label typography (badges, chips)
    func labelSmall() -> some View {
        self.font(Typography.labelSmall)
            .tracking(TypographyMetrics.looseTracking)
    }
    
    // MARK: - Caption Styles
    /// Apply caption typography (metadata, timestamps)
    func caption() -> some View {
        self.font(Typography.caption)
            .lineSpacing(TypographyMetrics.captionLineSpacing)
    }
    
    /// Apply small caption typography (fine print)
    func captionSmall() -> some View {
        self.font(Typography.captionSmall)
    }
    
    // MARK: - Specialized Styles
    /// Apply monospace number typography (timers, measurements)
    func monospaceNumbers() -> some View {
        self.font(Typography.monospaceNumbers)
    }
    
    /// Apply large timer typography (cooking timers)
    func timerLarge() -> some View {
        self.font(Typography.timerLarge)
    }
    
    /// Apply cultural typography (Twi greetings, special cultural moments)
    func cultural() -> some View {
        self.font(Typography.cultural)
            .tracking(TypographyMetrics.tightTracking)
    }
    
    /// Apply brand typography (app name, special branding)
    func brand() -> some View {
        self.font(Typography.brand)
            .tracking(TypographyMetrics.tightTracking)
    }
    
    // MARK: - Semantic Combinations
    /// Recipe card title styling
    func recipeCardTitle() -> some View {
        self.headingMedium()
            .foregroundColor(.primary)
            .lineLimit(2)
            .minimumScaleFactor(0.9)
    }
    
    /// Recipe description styling
    func recipeDescription() -> some View {
        self.bodyMedium()
            .foregroundColor(.secondary)
            .lineLimit(3)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    /// Step instruction styling
    func stepInstruction() -> some View {
        self.bodyLarge()
            .foregroundColor(.primary)
            .lineSpacing(4)
            .fixedSize(horizontal: false, vertical: true)
    }
    
    /// Metadata styling (time, difficulty, servings)
    func metadata() -> some View {
        self.caption()
            .foregroundColor(.secondary)
    }
    
    /// Button text styling
    func buttonText() -> some View {
        self.labelLarge()
            .foregroundColor(.white)
    }
    
    /// Tab title styling
    func tabTitle() -> some View {
        self.labelMedium()
            .fontWeight(.semibold)
    }
    
    /// Badge text styling
    func badgeText() -> some View {
        self.labelSmall()
            .foregroundColor(.white)
            .textCase(.uppercase)
    }
    
    /// Timer display styling
    func timerDisplay() -> some View {
        self.timerLarge()
            .foregroundColor(Color("TimerActive"))
            .monospacedDigit()
    }
    
    /// Error message styling
    func errorMessage() -> some View {
        self.bodyMedium()
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
    }
    
    /// Success message styling
    func successMessage() -> some View {
        self.bodyMedium()
            .foregroundColor(.green)
            .multilineTextAlignment(.center)
    }
    
    // MARK: - Accessibility Helpers
    /// Ensure minimum touch target size for accessibility
    func accessibleTouchTarget() -> some View {
        self.frame(minWidth: AccessibilityTypography.minimumTouchTarget,
                  minHeight: AccessibilityTypography.minimumTouchTarget)
    }
    
    /// Apply accessibility-friendly text styling
    func accessibleText() -> some View {
        self.modifier(AccessibleTextModifier())
    }
    
    /// Dynamic sizing based on accessibility preferences
    func adaptiveSize() -> some View {
        self.modifier(AdaptiveSizeModifier())
    }
}

// MARK: - Accessibility Modifiers
struct AccessibleTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .minimumScaleFactor(AccessibilityTypography.prefersLargerText ? 1.0 : 0.8)
            .allowsTightening(!AccessibilityTypography.usesAccessibilitySize)
            .lineLimit(AccessibilityTypography.usesAccessibilitySize ? nil : 3)
    }
}

struct AdaptiveSizeModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scaleEffect(AccessibilityTypography.prefersLargerText ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: AccessibilityTypography.prefersLargerText)
    }
}

// MARK: - Preview Helper
#if DEBUG
struct TypographyPreview: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Typography System")
                        .brand()
                    
                    Text("Display Styles")
                        .displaySmall()
                    
                    Text("Akwaaba! Welcome to Ayewam")
                        .cultural()
                    
                    Text("Jollof Rice with Chicken")
                        .displayMedium()
                    
                    Text("Heading Styles")
                        .displaySmall()
                    
                    Text("Traditional Recipe")
                        .headingLarge()
                    
                    Text("Ingredients")
                        .headingMedium()
                    
                    Text("Cooking Steps")
                        .headingSmall()
                }
                
                Group {
                    Text("Body Styles")
                        .displaySmall()
                    
                    Text("This is a traditional Ghanaian dish that brings families together around the dinner table.")
                        .recipeDescription()
                    
                    Text("Heat oil in a large pot over medium heat. Add onions and sauté until translucent.")
                        .stepInstruction()
                    
                    Text("Label & Caption Styles")
                        .displaySmall()
                    
                    Text("Start Cooking")
                        .buttonText()
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                    
                    Text("5 min • Easy • 4 servings")
                        .metadata()
                    
                    Text("Timer: 05:30")
                        .timerDisplay()
                }
            }
            .padding()
        }
    }
}

#Preview {
    TypographyPreview()
}
#endif
