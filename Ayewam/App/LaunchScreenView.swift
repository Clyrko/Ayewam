//
//  LaunchScreenView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 6/1/25.
//


import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var textOpacity = 0.0
    @State private var subtitleOffset: CGFloat = 20

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack(alignment: .center, spacing: 16) {
                    // App name
                    Text("Ayewam")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .opacity(textOpacity)
                        .scaleEffect(isAnimating ? 1.0 : 0.8)

                    // Subtitle
                    Text("Authentic Ghanaian Recipes")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                        .opacity(textOpacity)
                        .offset(y: subtitleOffset)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                ZStack {
                    LinearGradient(
                        colors: [
                            Color("GhanaGold"),
                            Color("KenteGold").opacity(0.8),
                            Color("GhanaGold")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    Circle()
                        .fill(Color("KenteGold").opacity(0.1))
                        .frame(width: geometry.size.width * 1.5)
                        .blur(radius: 60)
                        .offset(x: -geometry.size.width * 0.3, y: -geometry.size.height * 0.2)

                    Circle()
                        .fill(Color.white.opacity(0.05))
                        .frame(width: geometry.size.width * 1.2)
                        .blur(radius: 40)
                        .offset(x: geometry.size.width * 0.4, y: geometry.size.height * 0.3)
                }
            )
        }
        .onAppear {
            // Animate the launch screen elements
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
                textOpacity = 1.0
            }

            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                subtitleOffset = 0
            }
        }
    }
}

// MARK: - Preview
#Preview {
    LaunchScreenView()
}
