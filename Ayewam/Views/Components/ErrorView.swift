//
//  ErrorView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI

struct ErrorView: View {
    let errorMessage: String
    let retryAction: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.1))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.red)
            }
            .padding(.bottom, 8)
            
            VStack(spacing: 12) {
                Text("Oops!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(errorMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal)
            }
            
            Button(action: retryAction) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Try Again")
                        .fontWeight(.medium)
                }
                .padding(.horizontal, 32)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.blue)
                        .shadow(color: Color.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                )
                .foregroundColor(.white)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.top, 8)
        }
        .padding(32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 5)
        )
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// Custom button style for scale effect on press
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ErrorView(
        errorMessage: "We couldn't load your recipes. Please check your connection and try again.",
        retryAction: { print("Retry tapped") }
    )
}
