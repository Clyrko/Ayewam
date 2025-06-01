//
//  View+Extensions.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/20/25.
//

import SwiftUI

extension View {
    // MARK: - Conditional Modifier
    /// Apply a modifier conditionally
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    // MARK: - Card Style
    /// Apply a standard card style to the view
    func cardStyle(
        cornerRadius: CGFloat = 12,
        shadowRadius: CGFloat = 4,
        shadowOpacity: Double = 0.1
    ) -> some View {
        self
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color(.systemBackground))
                    .shadow(
                        color: Color.black.opacity(shadowOpacity),
                        radius: shadowRadius,
                        x: 0,
                        y: 2
                    )
            )
    }
    
    // MARK: - Hidden Modifier
    /// Hide a view based on a condition
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        if shouldHide {
            self.hidden()
        } else {
            self
        }
    }
    
    // MARK: - Read Size
    /// Read the size of a view and report it via the size binding
    func readSize(onChange: @escaping (CGSize) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: SizePreferenceKey.self, value: geometryProxy.size)
            }
        )
        .onPreferenceChange(SizePreferenceKey.self, perform: onChange)
    }
    
    // MARK: - Placeholder
    /// Add a placeholder to a TextField
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
    
    // MARK: - Haptic Feedback on Tap
    /// Add haptic feedback to a button or tappable view
    func hapticTap(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.onTapGesture {
            switch style {
            case .light:
                HapticFeedbackManager.shared.lightImpact()
            case .medium:
                HapticFeedbackManager.shared.mediumImpact()
            case .heavy:
                HapticFeedbackManager.shared.heavyImpact()
            @unknown default:
                HapticFeedbackManager.shared.mediumImpact()
            }
        }
    }
    
    // MARK: - Corner Radius with Specific Corners
    /// Apply corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    // MARK: - Press Events
    /// Add press and release event handlers
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self.simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in onPress() }
                .onEnded { _ in onRelease() }
        )
    }
}

// MARK: - Preference Keys
struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}

// MARK: - Custom Shapes
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
