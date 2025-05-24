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
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: tabIcon(for: index))
                            .font(.system(size: 24, weight: .regular))
                            .foregroundColor(selectedTab == index ? .accentColor : Color(.systemGray))
                        
                        Text(tabTitle(for: index))
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(selectedTab == index ? .accentColor : Color(.systemGray))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .contentShape(Rectangle())
            }
        }
        .padding(.top, 8)
        .background(
            Rectangle()
                .fill(.regularMaterial)
                .overlay(
                    Rectangle()
                        .stroke(Color(.separator), lineWidth: 0.5)
                        .frame(height: 0.5),
                    alignment: .top
                )
        )
        .ignoresSafeArea(.container, edges: .bottom)
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
    @Previewable @State var selectedTab = 0
    
    VStack {
        Spacer()
        TabBar(selectedTab: $selectedTab)
    }
    .background(Color(.systemGroupedBackground))
}
