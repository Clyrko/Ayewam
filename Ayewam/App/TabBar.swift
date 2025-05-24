//
//  TabBar.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/23/25.
//

import SwiftUI

struct TabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<4) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 6) {
                        // Icon with smooth selection indicator
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 20, weight: selectedTab == index ? .semibold : .medium))
                            .foregroundColor(selectedTab == index ? .accentColor : .secondary)
                            .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selectedTab)
                        
                        // Tab title with smart visibility
                        Text(tabTitle(for: index))
                            .font(.system(size: 11, weight: selectedTab == index ? .semibold : .medium))
                            .foregroundColor(selectedTab == index ? .accentColor : .secondary)
                            .opacity(selectedTab == index ? 1.0 : 0.8)
                            .scaleEffect(selectedTab == index ? 1.0 : 0.95)
                            .animation(.easeInOut(duration: 0.2), value: selectedTab)
                        
                        // Clean selection indicator
                        Circle()
                            .fill(selectedTab == index ? Color.accentColor : Color.clear)
                            .frame(width: 4, height: 4)
                            .scaleEffect(selectedTab == index ? 1.0 : 0.5)
                            .opacity(selectedTab == index ? 1.0 : 0.0)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedTab)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .contentShape(Rectangle()) // Better tap area
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            // Clean background with subtle blur
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .overlay(
                    // Subtle border
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color(.separator).opacity(0.5), lineWidth: 0.5)
                )
        )
        .shadow(
            color: Color.black.opacity(0.08),
            radius: 12,
            x: 0,
            y: 6
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 34)
    }
    
    // MARK: - Helper Methods
    private func tabIcon(for index: Int) -> String {
        switch index {
        case 0: return "book.closed.fill"
        case 1: return "square.grid.2x2.fill"
        case 2: return "heart.fill"
        case 3: return "info.circle.fill"
        default: return "questionmark"
        }
    }
    
    private func tabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Recipes"
        case 1: return "Categories"
        case 2: return "Favorites"
        case 3: return "About"
        default: return ""
        }
    }
}

#Preview {
    @State var selectedTab = 0
    
    return VStack {
        Spacer()
        TabBar(selectedTab: $selectedTab)
    }
    .background(Color(.systemGroupedBackground))
}
