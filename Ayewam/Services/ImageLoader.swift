//
//  ImageLoader.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import Foundation
import SwiftUI
import Combine

/// Service for loading and caching images
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    @Published var error: Error?
    
    private var cancellable: AnyCancellable?
    private static let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - Image Loading Methods
    
    /// Load an image from an asset name, URL, or file path
    func loadImage(from source: ImageSource) {
        reset()
        isLoading = true
        
        switch source {
        case .asset(let name):
            loadFromAsset(name: name)
        case .url(let urlString):
            loadFromURL(urlString: urlString)
        case .filePath(let path):
            loadFromFilePath(path: path)
        case .placeholder(let color, let text):
            createPlaceholder(color: color, text: text)
        }
    }
    
    /// Cancel any pending image loading operation
    func cancel() {
        cancellable?.cancel()
        cancellable = nil
        isLoading = false
    }
    
    /// Reset the loader state
    func reset() {
        cancel()
        image = nil
        error = nil
    }
    
    // MARK: - Private Loading Methods
    
    /// Load image from asset catalog
    private func loadFromAsset(name: String) {
        // Check cache first
        let cacheKey = NSString(string: "asset-\(name)")
        if let cachedImage = Self.imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        // Load from asset catalog
        if let uiImage = UIImage(named: name) {
            Self.imageCache.setObject(uiImage, forKey: cacheKey)
            self.image = uiImage
        } else {
            self.error = ImageLoaderError.assetNotFound
        }
        
        self.isLoading = false
    }
    
    /// Load image from URL
    private func loadFromURL(urlString: String) {
        // Check cache first
        let cacheKey = NSString(string: urlString)
        if let cachedImage = Self.imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        // Validate URL
        guard let url = URL(string: urlString) else {
            self.error = ImageLoaderError.invalidURL
            self.isLoading = false
            return
        }
        
        // Load from URL
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] image in
                guard let self = self else { return }
                
                if let image = image {
                    Self.imageCache.setObject(image, forKey: cacheKey)
                    self.image = image
                } else {
                    self.error = ImageLoaderError.invalidImageData
                }
                
                self.isLoading = false
            }
    }
    
    /// Load image from file path
    private func loadFromFilePath(path: String) {
        // Check cache first
        let cacheKey = NSString(string: "file-\(path)")
        if let cachedImage = Self.imageCache.object(forKey: cacheKey) {
            self.image = cachedImage
            self.isLoading = false
            return
        }
        
        // Load from file
        if let uiImage = UIImage(contentsOfFile: path) {
            Self.imageCache.setObject(uiImage, forKey: cacheKey)
            self.image = uiImage
        } else {
            self.error = ImageLoaderError.fileNotFound
        }
        
        self.isLoading = false
    }
    
    /// Create a placeholder image
    private func createPlaceholder(color: Color, text: String?) {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 200))
        let uiImage = renderer.image { context in
            // Fill background
            let backgroundColor = UIColor(color)
            backgroundColor.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 200, height: 200))
            
            // Draw text if provided
            if let text = text, !text.isEmpty {
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 70, weight: .bold),
                    .foregroundColor: UIColor.white.withAlphaComponent(0.7),
                    .paragraphStyle: paragraphStyle
                ]
                
                let string = String(text.prefix(1))
                let attributedString = NSAttributedString(string: string, attributes: attributes)
                let stringRect = CGRect(x: 0, y: 50, width: 200, height: 100)
                attributedString.draw(in: stringRect)
            }
        }
        
        self.image = uiImage
        self.isLoading = false
    }
}

// MARK: - Supporting Types

/// Source types for images
enum ImageSource {
    case asset(name: String)          // From asset catalog
    case url(string: String)          // From a URL
    case filePath(path: String)       // From a file path
    case placeholder(color: Color, text: String?) // Generate a placeholder
}

/// Errors that can occur during image loading
enum ImageLoaderError: Error {
    case assetNotFound
    case invalidURL
    case invalidImageData
    case fileNotFound
    
    var localizedDescription: String {
        switch self {
        case .assetNotFound:
            return "Image asset not found."
        case .invalidURL:
            return "Invalid image URL."
        case .invalidImageData:
            return "Invalid image data."
        case .fileNotFound:
            return "Image file not found."
        }
    }
}
