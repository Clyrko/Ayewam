//
//  TipStore.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/26/25.
//

import Foundation
import StoreKit
import SwiftUI
import Combine

@MainActor
class TipStore: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchaseState: PurchaseState = .idle
    @Published var isLoadingProducts = false
    @Published var lastError: String?
    @Published var isAvailable = false
    private var transactionListener: Task<Void, Error>?
    
    /// Product IDs for tip options
    private let productIDs = [
        "ayewam.tip.small",
        "ayewam.tip.medium",
        "ayewam.tip.large",
        "ayewam.tip.huge"
    ]
    
    /// UserDefaults keys for tip tracking
    private enum UserDefaultsKeys {
        static let totalTipsReceived = "totalTipsReceived"
        static let tipCount = "tipCount"
        static let lastTipDate = "lastTipDate"
        static let hasEverTipped = "hasEverTipped"
    }
    
    // MARK: - Purchase States
    enum PurchaseState {
        case idle
        case purchasing(Product)
        case success(Product)
        case failed(Error)
        case unavailable
    }
    
    init() {
        transactionListener = configureTransactionListener()
        Task {
            await loadProducts()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    // MARK: - Public Methods
    /// Load available tip products from the App Store
    func loadProducts() async {
        await MainActor.run {
            isLoadingProducts = true
            lastError = nil
        }
        
        do {
            let storeProducts = try await Product.products(for: productIDs)
            
            await MainActor.run {
                // Sort products by price (ascending)
                self.products = storeProducts.sorted { $0.price < $1.price }
                self.isAvailable = !self.products.isEmpty
                self.isLoadingProducts = false
                
                print("🍲 TipStore: Loaded \(self.products.count) tip products")
            }
            
        } catch {
            await MainActor.run {
                self.handleError(error, context: "Loading products")
                self.isLoadingProducts = false
                self.isAvailable = false
            }
        }
    }
    
    /// Purchase a tip product
    func purchase(_ product: Product) async {
        await MainActor.run {
            purchaseState = .purchasing(product)
        }
        
        do {
            let result = try await product.purchase()
            
            await handlePurchaseResult(result, for: product)
            
        } catch {
            await MainActor.run {
                self.handleError(error, context: "Purchasing \(product.displayName)")
                self.purchaseState = .failed(error)
            }
        }
    }
    
    /// Get culturally appropriate tip option name
    func tipOptionName(for product: Product) -> String {
        guard let priceDouble = Double(product.price.description) else {
            return "Support the mission"
        }
        
        switch priceDouble {
        case 0.0...1.5:
            return "Buy me a koko"
        case 1.5...3.5:
            return "Fuel recipe research"
        case 3.5...6.0:
            return "Support the mission"
        default:
            return "Champion of culture"
        }
    }
    
    /// Get tip option description
    func tipOptionDescription(for product: Product) -> String {
        guard let priceDouble = Double(product.price.description) else {
            return "Help preserve Ghanaian culinary heritage"
        }
        
        switch priceDouble {
        case 0.0...1.5:
            return "A small gesture of appreciation"
        case 1.5...3.5:
            return "Support discovering new recipes"
        case 3.5...6.0:
            return "Help preserve culinary heritage"
        default:
            return "Become a cultural heritage champion"
        }
    }
    
    func tipEmoji(for product: Product) -> String {
        guard let priceDouble = Double(product.price.description) else {
            return "🫖"
        }
        
        switch priceDouble {
        case 0.0...1.5:
            return "🫖"
        case 1.5...3.5:
            return "🍲"
        case 3.5...6.0:
            return "⭐"
        default:
            return "🇬🇭"
        }
    }
    
    func resetPurchaseState() {
        purchaseState = .idle
    }
    
    // MARK: - Tip Tracking
    /// Total amount of tips received (for thank you messaging)
    var totalTipsReceived: Double {
        UserDefaults.standard.double(forKey: UserDefaultsKeys.totalTipsReceived)
    }
    
    /// Number of tips received
    var tipCount: Int {
        UserDefaults.standard.integer(forKey: UserDefaultsKeys.tipCount)
    }
    
    /// Whether user has ever tipped
    var hasEverTipped: Bool {
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasEverTipped)
    }
    
    /// Date of last tip (for spacing thank you messages)
    var lastTipDate: Date? {
        guard let timeInterval = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastTipDate) as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: timeInterval)
    }
    
    func getThankYouMessage() -> String {
        let messages = [
            "Medaase! 🇬🇭",
            "Your support preserves our heritage!",
            "Made with love in Accra, Ghana 🫖",
            "You're helping keep traditions alive! ⭐",
            "Ayekoo! (Well done!) 🍲",
            "Your kindness means the world! 🙏🏾"
        ]
        
        // Return different messages based on tip count
        if tipCount == 1 {
            return "Medaase! Your first tip means so much! 🇬🇭"
        } else if tipCount < 5 {
            return messages.randomElement() ?? "Medaase! 🇬🇭"
        } else {
            return "You're a true champion of Ghanaian culture! Medaase paa! 🇬🇭⭐"
        }
    }
    
    // MARK: - Private Methods
    
    /// Configure transaction listener for handling completed purchases
    private func configureTransactionListener() -> Task<Void, Error> {
        Task.detached { [weak self] in
            for await result in StoreKit.Transaction.updates {
                guard let self = self else { return }
                
                do {
                    let transaction = try await self.checkVerified(result)
                    await self.handleTransaction(transaction)
                    await transaction.finish()
                } catch {
                    await self.handleError(error, context: "Transaction listener")
                }
            }
        }
    }
    
    /// Handle purchase result
    private func handlePurchaseResult(_ result: Product.PurchaseResult, for product: Product) async {
        switch result {
        case .success(let verification):
            do {
                let transaction = try checkVerified(verification)
                await handleTransaction(transaction)
                await transaction.finish()
                
                await MainActor.run {
                    self.purchaseState = .success(product)
                }
                
            } catch {
                await MainActor.run {
                    self.handleError(error, context: "Verifying purchase")
                    self.purchaseState = .failed(error)
                }
            }
            
        case .pending:
            await MainActor.run {
                self.purchaseState = .idle
                print("🍲 TipStore: Purchase pending approval")
            }
            
        case .userCancelled:
            await MainActor.run {
                self.purchaseState = .idle
                print("🍲 TipStore: User cancelled purchase")
            }
            
        @unknown default:
            await MainActor.run {
                self.purchaseState = .idle
                print("🍲 TipStore: Unknown purchase result")
            }
        }
    }
    
    /// Handle completed transaction
    private func handleTransaction(_ transaction: StoreKit.Transaction) async {
        guard productIDs.contains(transaction.productID) else {
            print("🍲 TipStore: Unknown product ID: \(transaction.productID)")
            return
        }
        
        // Find the product to get price
        if let product = products.first(where: { $0.id == transaction.productID }) {
            let tipAmount = Double(truncating: product.price as NSNumber)
            await recordTip(amount: tipAmount)
        }
        
        print("🍲 TipStore: Tip received! Product: \(transaction.productID)")
    }
    
    /// Record a successful tip
    private func recordTip(amount: Double) async {
        await MainActor.run {
            let currentTotal = UserDefaults.standard.double(forKey: UserDefaultsKeys.totalTipsReceived)
            let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.tipCount)
            
            UserDefaults.standard.set(currentTotal + amount, forKey: UserDefaultsKeys.totalTipsReceived)
            UserDefaults.standard.set(currentCount + 1, forKey: UserDefaultsKeys.tipCount)
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: UserDefaultsKeys.lastTipDate)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasEverTipped)
            
            print("🍲 justynx TipStore: Recorded tip of $\(amount). Total: $\(currentTotal + amount)")
        }
    }
    
    /// Verify transaction authenticity
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw TipStoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    /// Handle errors gracefully without disrupting user experience
    private func handleError(_ error: Error, context: String) {
        let errorMessage = "TipStore error in \(context): \(error.localizedDescription)"
        print("🚨 \(errorMessage)")
        lastError = errorMessage
        
        if error is StoreKitError {
            isAvailable = false
            purchaseState = .unavailable
        }
    }
}

// MARK: - Error Types
extension TipStore {
    enum TipStoreError: LocalizedError {
        case failedVerification
        case productNotFound
        case purchaseInProgress
        
        var errorDescription: String? {
            switch self {
            case .failedVerification:
                return "Purchase verification failed"
            case .productNotFound:
                return "Tip option not found"
            case .purchaseInProgress:
                return "Another purchase is in progress"
            }
        }
    }
}

// MARK: - Convenience Extensions
extension TipStore.PurchaseState: Equatable {
    static func == (lhs: TipStore.PurchaseState, rhs: TipStore.PurchaseState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.unavailable, .unavailable):
            return true
        case (.purchasing(let lProduct), .purchasing(let rProduct)):
            return lProduct.id == rProduct.id
        case (.success(let lProduct), .success(let rProduct)):
            return lProduct.id == rProduct.id
        case (.failed(_), .failed(_)):
            return true
        default:
            return false
        }
    }
}

extension Product {
    var formattedPrice: String {
        return displayPrice
    }
}

// MARK: - Preview Helpers

#if DEBUG
extension TipStore {
    static func mock() -> TipStore {
        let store = TipStore()
        //TODO: justynx Mock products would be created here for previews
        return store
    }
}
#endif
