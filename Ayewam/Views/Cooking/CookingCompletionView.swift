//
//  CookingCompletionView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/21/25.
//

import SwiftUI

struct CookingCompletionView: View {
    let onDismiss: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Success icon
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.1))
                        .frame(width: 120, height: 120)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.green)
                }
                
                Text("Recipe Complete!")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Congratulations! You've successfully completed this recipe.")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                Button(action: onDismiss) {
                    Text("Back to Recipe")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 16)
                .padding(.horizontal, 32)
            }
            .padding(32)
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(32)
        }
    }
}

#Preview {
    CookingCompletionView(onDismiss: {})
}
