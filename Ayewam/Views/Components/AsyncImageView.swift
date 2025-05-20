//
//  AsyncImageView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI

struct AsyncImageView: View {
    let source: ImageSource
    let contentMode: ContentMode
    let cornerRadius: CGFloat
    let placeholderColor: Color
    
    @StateObject private var loader = ImageLoader()
    
    init(
        source: ImageSource,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 0,
        placeholderColor: Color = Color.gray.opacity(0.3)
    ) {
        self.source = source
        self.contentMode = contentMode
        self.cornerRadius = cornerRadius
        self.placeholderColor = placeholderColor
    }
    
    var body: some View {
        ZStack {
            // Placeholder or error state
            if loader.image == nil {
                // Show placeholder until image loads
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(placeholderColor)
                    .overlay(
                        Group {
                            if loader.isLoading {
                                ProgressView()
                            } else if loader.error != nil {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            } else if case .placeholder(_, let text) = source {
                                if let textValue = text, !textValue.isEmpty {
                                    Text(String(textValue.prefix(1)))
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                } else {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.white)
                                }
                            } else {
                                Image(systemName: "photo")
                                    .font(.largeTitle)
                                    .foregroundColor(.white)
                            }
                        }
                    )
            }
            
            // Loaded image
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .cornerRadius(cornerRadius)
                    .transition(.opacity)
            }
        }
        .onAppear {
            loader.loadImage(from: source)
        }
        .onDisappear {
            loader.cancel()
        }
    }
}

// MARK: - Convenience initializers

extension AsyncImageView {
    /// Create an AsyncImageView from an asset name
    static func asset(
        _ name: String,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 0
    ) -> AsyncImageView {
        AsyncImageView(
            source: .asset(name: name),
            contentMode: contentMode,
            cornerRadius: cornerRadius
        )
    }
    
    /// Create an AsyncImageView from a URL string
    static func url(
        _ urlString: String,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 0
    ) -> AsyncImageView {
        AsyncImageView(
            source: .url(string: urlString),
            contentMode: contentMode,
            cornerRadius: cornerRadius
        )
    }
    
    /// Create a placeholder AsyncImageView with the first letter of the text
    static func placeholder(
        color: Color = Color.gray.opacity(0.3),
        text: String?,
        contentMode: ContentMode = .fill,
        cornerRadius: CGFloat = 0
    ) -> AsyncImageView {
        AsyncImageView(
            source: .placeholder(color: color, text: text),
            contentMode: contentMode,
            cornerRadius: cornerRadius
        )
    }
}

// MARK: - Preview

struct AsyncImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Asset image
            AsyncImageView.asset(
                "jollof_rice",
                contentMode: .fit,
                cornerRadius: 12
            )
            .frame(height: 150)
            
            // URL image (might not load in preview)
            AsyncImageView.url(
                "https://example.com/image.jpg",
                contentMode: .fit,
                cornerRadius: 12
            )
            .frame(height: 150)
            
            // Placeholder
            AsyncImageView.placeholder(
                color: Color.blue.opacity(0.3),
                text: "Jollof Rice",
                cornerRadius: 12
            )
            .frame(height: 150)
            
            // Error state (invalid asset)
            AsyncImageView.asset(
                "non_existent_image",
                contentMode: .fit,
                cornerRadius: 12
            )
            .frame(height: 150)
        }
        .padding()
    }
}
