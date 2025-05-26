//
//  ToastNotificationSystem.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import SwiftUI

struct ToastMessage: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String?
    let type: ToastType
    let duration: TimeInterval
    let icon: String?
    let action: ToastAction?
    
    init(
        title: String,
        message: String? = nil,
        type: ToastType = .info,
        duration: TimeInterval = 4.0,
        icon: String? = nil,
        action: ToastAction? = nil
    ) {
        self.title = title
        self.message = message
        self.type = type
        self.duration = duration
        self.icon = icon ?? type.defaultIcon
        self.action = action
    }
    
    static func == (lhs: ToastMessage, rhs: ToastMessage) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Toast Types

enum ToastType {
    case success
    case error
    case warning
    case info
    
    var defaultIcon: String {
        switch self {
        case .success:
            return "checkmark.circle.fill"
        case .error:
            return "xmark.circle.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .success:
            return .green
        case .error:
            return .red
        case .warning:
            return .orange
        case .info:
            return .blue
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .success:
            return Color.green.opacity(0.1)
        case .error:
            return Color.red.opacity(0.1)
        case .warning:
            return Color.orange.opacity(0.1)
        case .info:
            return Color.blue.opacity(0.1)
        }
    }
}

// MARK: - Toast Action

struct ToastAction {
    let title: String
    let action: () -> Void
    
    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }
}

// MARK: - Toast Position
enum ToastPosition {
    case top
    case center
    case bottom
    
    var alignment: Alignment {
        switch self {
        case .top:
            return .top
        case .center:
            return .center
        case .bottom:
            return .bottom
        }
    }
    
    var edge: Edge {
        switch self {
        case .top:
            return .top
        case .center:
            return .leading
        case .bottom:
            return .bottom
        }
    }
}

// MARK: - Toast Manager
@MainActor
class ToastManager: ObservableObject {
    @Published private(set) var currentToast: ToastMessage?
    @Published private(set) var isShowing = false
    
    private var hideTask: Task<Void, Never>?
    
    static let shared = ToastManager()
    
    private init() {}
    
    /// Show a toast message
    func show(_ toast: ToastMessage) {
        hideTask?.cancel()
        
        if isShowing {
            hideCurrentToast()
        }
        
        currentToast = toast
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isShowing = true
        }
        
        hideTask = Task {
            try? await Task.sleep(nanoseconds: UInt64(toast.duration * 1_000_000_000))
            
            guard !Task.isCancelled else { return }
            
            hideCurrentToast()
        }
    }
    
    /// Show a success toast
    func showSuccess(
        title: String,
        message: String? = nil,
        duration: TimeInterval = 4.0,
        action: ToastAction? = nil
    ) {
        let toast = ToastMessage(
            title: title,
            message: message,
            type: .success,
            duration: duration,
            action: action
        )
        show(toast)
    }
    
    /// Show an error toast
    func showError(
        title: String,
        message: String? = nil,
        duration: TimeInterval = 5.0,
        action: ToastAction? = nil
    ) {
        let toast = ToastMessage(
            title: title,
            message: message,
            type: .error,
            duration: duration,
            action: action
        )
        show(toast)
    }
    
    /// Show a warning toast
    func showWarning(
        title: String,
        message: String? = nil,
        duration: TimeInterval = 4.0,
        action: ToastAction? = nil
    ) {
        let toast = ToastMessage(
            title: title,
            message: message,
            type: .warning,
            duration: duration,
            action: action
        )
        show(toast)
    }
    
    /// Show an info toast
    func showInfo(
        title: String,
        message: String? = nil,
        duration: TimeInterval = 4.0,
        action: ToastAction? = nil
    ) {
        let toast = ToastMessage(
            title: title,
            message: message,
            type: .info,
            duration: duration,
            action: action
        )
        show(toast)
    }
    
    /// Hide the current toast
    func hide() {
        hideTask?.cancel()
        hideCurrentToast()
    }
    
    private func hideCurrentToast() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isShowing = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentToast = nil
        }
    }
}

// MARK: - Toast View

struct ToastView: View {
    let toast: ToastMessage
    let position: ToastPosition
    let onDismiss: () -> Void
    
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 16) {
                // Icon
                if let icon = toast.icon {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(toast.type.iconColor)
                        .frame(width: 28, height: 28)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    Text(toast.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    if let message = toast.message {
                        Text(message)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                
                Spacer()
                
                // Dismiss button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 20, height: 20)
                        .background(
                            Circle()
                                .fill(Color(.systemGray5))
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Action button
            if let action = toast.action {
                HStack {
                    Spacer()
                    
                    Button(action: {
                        action.action()
                        onDismiss()
                    }) {
                        Text(action.title)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(toast.type.iconColor)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(toast.type.backgroundColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(toast.type.iconColor.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 8)
        )
        .padding(.horizontal, 16)
        .offset(y: dragOffset.height)
        .scaleEffect(isDragging ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
        .gesture(
            DragGesture()
                .onChanged { value in
                    if position == .top && value.translation.height < 0 {
                        dragOffset = value.translation
                        isDragging = true
                    }
                    else if position == .bottom && value.translation.height > 0 {
                        dragOffset = value.translation
                        isDragging = true
                    }
                }
                .onEnded { value in
                    let threshold: CGFloat = 50
                    
                    if (position == .top && value.translation.height < -threshold) ||
                        (position == .bottom && value.translation.height > threshold) {
                        // Dismiss if dragged far enough
                        onDismiss()
                    } else {
                        // Snap back
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            dragOffset = .zero
                            isDragging = false
                        }
                    }
                }
        )
    }
}

// MARK: - Toast Container View Modifier

struct ToastViewModifier: ViewModifier {
    let position: ToastPosition
    @StateObject private var toastManager = ToastManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: position.alignment) {
                if toastManager.isShowing,
                   let toast = toastManager.currentToast {
                    ToastView(
                        toast: toast,
                        position: position,
                        onDismiss: {
                            toastManager.hide()
                        }
                    )
                    .transition(
                        .move(edge: position.edge)
                        .combined(with: .opacity)
                        .combined(with: .scale(scale: 0.9, anchor: position.alignment.unitPoint))
                    )
                    .zIndex(1000)
                }
            }
    }
}

// MARK: - View Extension

extension View {
    func toast(position: ToastPosition = .top) -> some View {
        modifier(ToastViewModifier(position: position))
    }
}

// MARK: - UnitPoint Extension

private extension Alignment {
    var unitPoint: UnitPoint {
        switch self {
        case .top:
            return .top
        case .bottom:
            return .bottom
        case .center:
            return .center
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .topLeading:
            return .topLeading
        case .topTrailing:
            return .topTrailing
        case .bottomLeading:
            return .bottomLeading
        case .bottomTrailing:
            return .bottomTrailing
        default:
            return .center
        }
    }
}

extension ToastManager {
    /// Show recipe submission success toast
    func showRecipeSubmissionSuccess() {
        showSuccess(
            title: "Suggestion Submitted!",
            message: "Thanks! Your suggestion helps preserve Ghanaian culinary traditions. You'll be notified when recipes are added in future app updates.",
            duration: 4.0
        )
    }
    
    /// Show recipe submission error toast
    func showRecipeSubmissionError(_ error: String) {
        showError(
            title: "Submission Failed",
            message: error,
            duration: 5.0,
            action: ToastAction(title: "Retry") {
                print("Retry requested from toast")
            }
        )
    }
    
    /// Show network error toast
    func showNetworkError() {
        showError(
            title: "Network Error",
            message: "Please check your internet connection and try again.",
            duration: 5.0,
            action: ToastAction(title: "Retry") {
                // This would trigger a retry
                print("Network retry requested")
            }
        )
    }
}

// MARK: - Preview Support

#if DEBUG
struct ToastPreviewContent: View {
    @StateObject private var toastManager = ToastManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Toast Notification System")
                .font(.title)
                .padding()
            
            VStack(spacing: 16) {
                Button("Show Success Toast") {
                    toastManager.showRecipeSubmissionSuccess()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Show Error Toast") {
                    toastManager.showRecipeSubmissionError("Failed to submit recipe suggestion. Please try again.")
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
                Button("Show Warning Toast") {
                    toastManager.showWarning(
                        title: "Recipe Already Exists",
                        message: "This recipe has already been suggested by another user."
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
                
                Button("Show Info Toast") {
                    toastManager.showInfo(
                        title: "Tip",
                        message: "You can suggest up to 5 recipes per day.",
                        action: ToastAction(title: "Got it") {
                            print("User acknowledged tip")
                        }
                    )
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
            }
            
            Spacer()
        }
        .toast(position: .top)
    }
}

#Preview {
    ToastPreviewContent()
}
#endif
