//
//  AppLaunchNotificationSystem.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - App Launch Notification Model
struct AppLaunchNotification: Identifiable, Codable {
    let id: UUID
    let type: NotificationType
    let title: String
    let message: String
    let actionText: String?
    let actionType: ActionType?
    let approvedRecipes: [ApprovedRecipeInfo]
    let appVersion: String
    let createdDate: Date
    
    enum NotificationType: String, Codable {
        case recipeApproval = "recipe_approval"
        case appUpdate = "app_update"
        case announcement = "announcement"
    }
    
    enum ActionType: String, Codable {
        case viewRecipes = "view_recipes"
        case dismiss = "dismiss"
        case openSettings = "open_settings"
    }
    
    init(
        id: UUID = UUID(),
        type: NotificationType,
        title: String,
        message: String,
        actionText: String? = nil,
        actionType: ActionType? = nil,
        approvedRecipes: [ApprovedRecipeInfo] = [],
        appVersion: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    ) {
        self.id = id
        self.type = type
        self.title = title
        self.message = message
        self.actionText = actionText
        self.actionType = actionType
        self.approvedRecipes = approvedRecipes
        self.appVersion = appVersion
        self.createdDate = Date()
    }
}

// MARK: - Approved Recipe Info
struct ApprovedRecipeInfo: Identifiable, Codable {
    let id: String
    let name: String
    let submissionDate: Date
    let approvalDate: Date
    let recipeId: String?
    
    init(from submission: RecipeSubmission, recipeId: String? = nil) {
        self.id = submission.id
        self.name = submission.recipeName
        self.submissionDate = submission.submissionDate
        self.approvalDate = Date()
        self.recipeId = recipeId
    }
}

// MARK: - App Launch Notification Manager
@MainActor
class AppLaunchNotificationManager: ObservableObject {
        
    @Published var pendingNotifications: [AppLaunchNotification] = []
    @Published var currentNotification: AppLaunchNotification?
    @Published var isShowingNotification = false
        
    private let repository: RecipeSubmissionRepository
    private var cancellables = Set<AnyCancellable>()
    
    // UserDefaults keys
    private enum UserDefaultsKeys {
        static let lastCheckedVersion = "LastCheckedAppVersion"
        static let lastNotificationCheck = "LastNotificationCheckDate"
        static let shownNotificationIDs = "ShownNotificationIDs"
        static let pendingNotifications = "PendingNotifications"
    }

    init(repository: RecipeSubmissionRepository = RecipeSubmissionRepository()) {
        self.repository = repository
        setupNotificationChecking()
    }

    static let shared = AppLaunchNotificationManager()
    
    // MARK: - Public Methods
    /// Check for new notifications on app launch
    func checkForNotifications() async {
        print("🔔 Checking for app launch notifications...")
        
        // Check for version-based notifications
        await checkVersionBasedNotifications()
        
        // Check for approved recipe notifications
//        await checkApprovedRecipeNotifications()
        
        // Show pending notifications
        showNextNotification()
    }
    
    /// Show the next pending notification
    func showNextNotification() {
        guard !pendingNotifications.isEmpty,
              currentNotification == nil,
              !isShowingNotification else {
            return
        }
        
        let notification = pendingNotifications.removeFirst()
        currentNotification = notification
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isShowingNotification = true
        }
        
        markNotificationAsShown(notification.id)
    }
    
    /// Dismiss current notification
    func dismissCurrentNotification() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isShowingNotification = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.currentNotification = nil
            
            self.showNextNotification()
        }
    }
    
    func handleNotificationAction(_ notification: AppLaunchNotification) {
        guard let actionType = notification.actionType else {
            dismissCurrentNotification()
            return
        }
        
        switch actionType {
        case .viewRecipes:
            // Navigate to recipes view
            NotificationCenter.default.post(
                name: .navigateToRecipes,
                object: notification.approvedRecipes
            )
            
        case .openSettings:
            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsUrl)
            }
            
        case .dismiss:
            break
        }
        
        dismissCurrentNotification()
    }
    
    /// Clear all pending notifications
    func clearAllNotifications() {
        pendingNotifications.removeAll()
        savePendingNotifications()
    }
    
    /// Test notification
    func addTestNotification() {
        // Create a mock submission first
        let mockSubmission = RecipeSubmission(
            id: "test-1",
            recipeName: "Test Grandmother's Jollof",
            additionalDetails: "Special family recipe",
            submissionDate: Date().addingTimeInterval(-86400 * 7),
            userID: "test-user",
            status: .approved,
            approvedRecipeID: "jollof_rice"
        )
        
        let testRecipe = ApprovedRecipeInfo(from: mockSubmission, recipeId: "jollof_rice")
        
        let notification = AppLaunchNotification(
            type: .recipeApproval,
            title: "Your Recipe Suggestion Was Added! 🎉",
            message: "We've added \"Test Grandmother's Jollof\" to the app based on your suggestion. Thank you for helping preserve Ghanaian culinary traditions!",
            actionText: "View Recipe",
            actionType: .viewRecipes,
            approvedRecipes: [testRecipe]
        )
        
        addNotification(notification)
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationChecking() {
        loadPendingNotifications()
        
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                Task {
                    await self?.checkForNotifications()
                }
            }
            .store(in: &cancellables)
    }
    
    private func checkVersionBasedNotifications() async {
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let lastCheckedVersion = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastCheckedVersion)
        
        // If this is a new version, create appropriate notifications
        if lastCheckedVersion != currentVersion {
            print("🔔 New app version detected: \(currentVersion)")
            
            // Create version update notification
            let notification = AppLaunchNotification(
                type: .appUpdate,
                title: "Welcome to Ayewam \(currentVersion)! 🎊",
                message: "New recipes, improved cooking features, and better suggestions are now available. Thank you for helping us grow our Ghanaian recipe collection!",
                actionText: "Explore",
                actionType: .dismiss
            )
            
            addNotification(notification)
            
            // Update last checked version
            UserDefaults.standard.set(currentVersion, forKey: UserDefaultsKeys.lastCheckedVersion)
        }
    }
    
    //TODO: justynx icloudkit v2
//    private func checkApprovedRecipeNotifications() async {
//        let lastCheckDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastNotificationCheck) as? Date ?? Date.distantPast
//        
//        do {
//            // Fetch approved submissions since last check
//            let approvedSubmissions = try await repository.fetchApprovedSubmissions(since: lastCheckDate)
//            
//            if !approvedSubmissions.isEmpty {
//                print("🔔 Found \(approvedSubmissions.count) newly approved recipes")
//                
//                // Group by user if needed, but for now create one notification per approval
//                for submission in approvedSubmissions {
//                    let approvedRecipe = ApprovedRecipeInfo(from: submission)
//                    
//                    let notification = AppLaunchNotification(
//                        type: .recipeApproval,
//                        title: "Your Recipe Suggestion Was Added! 🎉",
//                        message: "We've added \"\(submission.recipeName)\" to the app based on your suggestion. Thank you for helping preserve Ghanaian culinary traditions!",
//                        actionText: "View Recipe",
//                        actionType: .viewRecipes,
//                        approvedRecipes: [approvedRecipe]
//                    )
//                    
//                    addNotification(notification)
//                }
//            }
//            
//            // Update last check date
//            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastNotificationCheck)
//            
//        } catch {
//            print("🔔 Failed to check for approved recipes: \(error)")
//        }
//    }
    
    private func addNotification(_ notification: AppLaunchNotification) {
        pendingNotifications.append(notification)
        savePendingNotifications()
    }
    
    private func markNotificationAsShown(_ id: UUID) {
        var shownIDs = UserDefaults.standard.stringArray(forKey: UserDefaultsKeys.shownNotificationIDs) ?? []
        shownIDs.append(id.uuidString)
        UserDefaults.standard.set(shownIDs, forKey: UserDefaultsKeys.shownNotificationIDs)
    }
    
    private func savePendingNotifications() {
        if let encoded = try? JSONEncoder().encode(pendingNotifications) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.pendingNotifications)
        }
    }
    
    private func loadPendingNotifications() {
        guard let data = UserDefaults.standard.data(forKey: UserDefaultsKeys.pendingNotifications),
              let notifications = try? JSONDecoder().decode([AppLaunchNotification].self, from: data) else {
            return
        }
        
        pendingNotifications = notifications
    }
}

// MARK: - Notification View

struct AppLaunchNotificationView: View {
    let notification: AppLaunchNotification
    let onAction: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack(spacing: 16) {
                notificationIcon
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(notification.title)
                        .headingMedium()
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    if !notification.approvedRecipes.isEmpty {
                        Text("\(notification.approvedRecipes.count) recipe\(notification.approvedRecipes.count == 1 ? "" : "s") added")
                            .font(.subheadline)
                            .foregroundColor(Color("GhanaGold"))
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // Close button
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 24, height: 24)
                        .background(
                            Circle()
                                .fill(Color(.systemGray5))
                        )
                }
                .buttonStyle(.plain)
            }
            
            // Message
            Text(notification.message)
                .font(.body)
                .foregroundColor(.secondary)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
            
            // Approved recipes list (if any)
            if !notification.approvedRecipes.isEmpty {
                approvedRecipesList
            }
            
            // Action buttons
            HStack(spacing: 12) {
                if let actionText = notification.actionText {
                    Button(action: onAction) {
                        HStack(spacing: 8) {
                            Image(systemName: actionIcon)
                                .font(.system(size: 14, weight: .semibold))
                            
                            Text(actionText)
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [Color("GhanaGold"), Color("KenteGold")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                }
                
                Button("Later", action: onDismiss)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .buttonStyle(ScaleButtonStyle())
                
                Spacer()
            }
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [Color("GhanaGold").opacity(0.3), Color("KenteGold").opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
    }
    
    private var notificationIcon: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("GhanaGold").opacity(0.2), Color("KenteGold").opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 50, height: 50)
            
            Image(systemName: notification.type == .recipeApproval ? "checkmark.circle.fill" : "sparkles")
                .font(.system(size: 24))
                .foregroundColor(Color("GhanaGold"))
        }
    }
    
    private var actionIcon: String {
        switch notification.actionType {
        case .viewRecipes:
            return "book.fill"
        case .openSettings:
            return "gear"
        case .dismiss, .none:
            return "checkmark"
        }
    }
    
    private var approvedRecipesList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Newly Added:")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            ForEach(notification.approvedRecipes.prefix(3)) { recipe in
                HStack(spacing: 12) {
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color("GhanaGold"))
                        .frame(width: 20)
                    
                    Text(recipe.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Text("New")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(Color.green)
                        )
                }
                .padding(.vertical, 4)
            }
            
            if notification.approvedRecipes.count > 3 {
                Text("+ \(notification.approvedRecipes.count - 3) more recipes")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6).opacity(0.5))
        )
    }
}

// MARK: - View Modifier

struct AppLaunchNotificationModifier: ViewModifier {
    @StateObject private var notificationManager = AppLaunchNotificationManager.shared
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if notificationManager.isShowingNotification,
                   let notification = notificationManager.currentNotification {
                    ZStack {
                        Color.black.opacity(0.4)
                            .ignoresSafeArea()
                            .onTapGesture {
                                notificationManager.dismissCurrentNotification()
                            }
                        
                        AppLaunchNotificationView(
                            notification: notification,
                            onAction: {
                                notificationManager.handleNotificationAction(notification)
                            },
                            onDismiss: {
                                notificationManager.dismissCurrentNotification()
                            }
                        )
                        .padding(.horizontal, 24)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.8).combined(with: .opacity),
                            removal: .scale(scale: 0.9).combined(with: .opacity)
                        ))
                    }
                    .zIndex(1000)
                }
            }
            .onAppear {
                Task {
                    await notificationManager.checkForNotifications()
                }
            }
    }
}

// MARK: - View Extension

extension View {
    /// Add app launch notification support
    func appLaunchNotifications() -> some View {
        modifier(AppLaunchNotificationModifier())
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let navigateToRecipes = Notification.Name("navigateToRecipes")
}

// MARK: - Preview Support

#if DEBUG
#Preview {
    let testNotification = AppLaunchNotification(
        type: .recipeApproval,
        title: "Your Recipe Suggestion Was Added! 🎉",
        message: "We've added \"Grandmother's Special Jollof\" to the app based on your suggestion. Thank you for helping preserve Ghanaian culinary traditions!",
        actionText: "View Recipe",
        actionType: .viewRecipes,
        approvedRecipes: [
            ApprovedRecipeInfo(
                from: RecipeSubmission(
                    id: "test-1",
                    recipeName: "Grandmother's Special Jollof",
                    submissionDate: Date().addingTimeInterval(-86400 * 7),
                    userID: "test-user",
                    status: .approved,
                    approvedRecipeID: "jollof_rice"
                ),
                recipeId: "jollof_rice"
            )
        ]
    )
    
    Color(.systemBackground)
        .overlay {
            AppLaunchNotificationView(
                notification: testNotification,
                onAction: { print("Action tapped") },
                onDismiss: { print("Dismissed") }
            )
            .padding()
        }
}
#endif
