//
//  Color+Extensions.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    // MARK: - Legacy Ghana Flag Colors (pointing to assets)
    static let ghRed = Color("WarmRed")
    static let ghYellow = Color("GhanaGold")
    static let ghGreen = Color("ForestGreen")
    
    // MARK: - Semantic Colors (hex-based - keep these)
    static let success = Color(hex: "#4CAF50")
    static let warning = Color(hex: "#FF9800")
    static let error = Color(hex: "#F44336")
    static let info = Color(hex: "#2196F3")
}

// MARK: - Asset Color Reference Guide
/*
 Available Asset Colors (use with Color("AssetName")):
 
 PRIMARY GHANA COLORS:
 - "GhanaGold"      - Ghana flag yellow
 - "ForestGreen"    - Ghana flag green
 - "WarmRed"        - Ghana flag red
 - "KenteGold"      - Traditional kente gold
 
 CATEGORY COLORS:
 - "SoupTeal"       - Soups category
 - "StewOrange"     - Stews category
 - "RiceGold"       - Rice dishes category
 - "StreetGreen"    - Street food category
 - "BreakfastOrange" - Breakfast category
 - "DessertPink"    - Desserts category
 - "DrinkBlue"      - Drinks category
 - "SidesBrown"     - Sides category
 
 SEMANTIC COLORS:
 - "TimerActive"    - Active cooking timers
 - "StepComplete"   - Completed cooking steps
 - "CookingProgress" - Cooking progress indicators
 - "FavoriteHeart"  - Favorite recipe heart
 
 SURFACE COLORS:
 - "CardBackground" - Card backgrounds
 - "SectionBackground" - Section backgrounds
 
 USAGE EXAMPLES:
 .foregroundColor(Color("GhanaGold"))
 .background(Color("SoupTeal"))
 .fill(Color("TimerActive"))
 */
