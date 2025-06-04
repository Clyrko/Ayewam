//
//  Typography.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 6/1/25.
//

import SwiftUI

enum Typography {
    
    // MARK: - Display Styles (Largest)
    /// Hero recipe titles, main app branding
    static let displayLarge = Font.custom("SF Pro Display", size: 34, relativeTo: .largeTitle)
        .weight(.black)
    
    /// Recipe names in detail view, major headings
    static let displayMedium = Font.custom("SF Pro Display", size: 28, relativeTo: .title)
        .weight(.bold)
    
    /// Section titles, category names
    static let displaySmall = Font.custom("SF Pro Display", size: 24, relativeTo: .title2)
        .weight(.bold)
    
    // MARK: - Heading Styles
    /// Card titles, step headers
    static let headingLarge = Font.system(size: 20, weight: .bold, design: .rounded)
        .scaledFont()
    
    /// Subsection headers, ingredient group titles
    static let headingMedium = Font.system(size: 18, weight: .semibold, design: .default)
        .scaledFont()
    
    /// Small headers, metadata labels
    static let headingSmall = Font.system(size: 16, weight: .semibold, design: .default)
        .scaledFont()
    
    // MARK: - Body Styles
    /// Primary body text, recipe descriptions
    static let bodyLarge = Font.system(size: 16, weight: .regular, design: .default)
        .scaledFont()
    
    /// Secondary body text, ingredient lists
    static let bodyMedium = Font.system(size: 15, weight: .regular, design: .default)
        .scaledFont()
    
    /// Compact body text, dense information
    static let bodySmall = Font.system(size: 14, weight: .regular, design: .default)
        .scaledFont()
    
    // MARK: - Label Styles
    /// Button text, important labels
    static let labelLarge = Font.system(size: 16, weight: .semibold, design: .default)
        .scaledFont()
    
    /// Form labels, tab titles
    static let labelMedium = Font.system(size: 14, weight: .semibold, design: .default)
        .scaledFont()
    
    /// Small labels, badges
    static let labelSmall = Font.system(size: 12, weight: .semibold, design: .default)
        .scaledFont()
    
    // MARK: - Caption Styles
    /// Metadata, timestamps, secondary info
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
        .scaledFont()
    
    /// Very small text, legal, fine print
    static let captionSmall = Font.system(size: 11, weight: .regular, design: .default)
        .scaledFont()
    
    // MARK: - Specialized Styles
    /// Monospace numbers, timers, measurements
    static let monospaceNumbers = Font.system(size: 18, weight: .semibold, design: .monospaced)
        .scaledFont()
    
    /// Large timer displays
    static let timerLarge = Font.system(size: 28, weight: .bold, design: .monospaced)
        .scaledFont()
    
    /// Code snippets, precise data (if needed)
    static let code = Font.system(size: 14, weight: .regular, design: .monospaced)
        .scaledFont()
    
    // MARK: - Cultural/Branded Styles
    /// Twi greetings, cultural text
    static let cultural = Font.custom("SF Pro Display", size: 28, relativeTo: .title)
        .weight(.bold)
    
    /// App name, special branding moments
    static let brand = Font.custom("SF Pro Display", size: 48, relativeTo: .largeTitle)
        .weight(.black)
}

// MARK: - Font Extension for Dynamic Type Support
extension Font {
    /// Ensures font scales properly with accessibility settings
    func scaledFont() -> Font {
        return self
    }
}

// MARK: - Typography Metrics
enum TypographyMetrics {
    /// Line spacing multipliers for different text sizes
    static let displayLineSpacing: CGFloat = 1.1
    static let headingLineSpacing: CGFloat = 1.2
    static let bodyLineSpacing: CGFloat = 1.4
    static let captionLineSpacing: CGFloat = 1.3
    
    /// Letter spacing (tracking) values
    static let tightTracking: CGFloat = -0.5
    static let normalTracking: CGFloat = 0
    static let looseTracking: CGFloat = 0.5
    static let wideTracking: CGFloat = 1.0
}

// MARK: - Accessibility Helpers
enum AccessibilityTypography {
    /// Check if user prefers larger text
    static var prefersLargerText: Bool {
        let category = UIApplication.shared.preferredContentSizeCategory
        return category >= .accessibilityMedium
    }
    
    /// Check if user is using largest accessibility sizes
    static var usesAccessibilitySize: Bool {
        let category = UIApplication.shared.preferredContentSizeCategory
        return category >= .accessibilityLarge
    }
    
    /// Minimum touch target size (44pt per Apple guidelines)
    static let minimumTouchTarget: CGFloat = 44
    
    /// Recommended minimum line height for readability
    static let minimumLineHeight: CGFloat = 22
}
