//
//  TipJarTestingView.swift
//  Ayewam
//
//  Created by Justyn Adusei-Prempeh on 5/27/25.
//

import SwiftUI
import StoreKit

// MARK: - Integration Testing View
/// Use this view to test the complete tip jar flow in development
struct TipJarTestingView: View {
    @StateObject private var tipStore = TipStore()
    @State private var showingAboutView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Test Header
                    testHeader
                    
                    // StoreKit Status
                    storeKitStatus
                    
                    // Tip Store Debug Info
                    tipStoreDebugInfo
                    
                    // Test Tip Jar (Isolated)
                    testTipJarSection
                    
                    // Test About View Integration
                    testAboutIntegration
                    
                    // User Defaults Testing
                    userDefaultsTestSection
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .navigationTitle("Tip Jar Testing")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingAboutView) {
            AboutView()
        }
    }
    
    // MARK: - Test Sections
    
    private var testHeader: some View {
        VStack(spacing: 16) {
            Text("🧪 Tip Jar Integration Test")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.primary)
            
            Text("Test all tip jar functionality before production")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private var storeKitStatus: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("StoreKit Status")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack {
                Circle()
                    .fill(tipStore.isAvailable ? .green : .red)
                    .frame(width: 12, height: 12)
                
                Text(tipStore.isAvailable ? "Available" : "Unavailable")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(tipStore.isAvailable ? .green : .red)
                
                Spacer()
                
                Text("\(tipStore.products.count) products loaded")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if tipStore.isLoadingProducts {
                HStack(spacing: 8) {
                    ProgressView()
                        .scaleEffect(0.8)
                    
                    Text("Loading products...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let error = tipStore.lastError {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var tipStoreDebugInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tip Store Debug Info")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                debugRow("Has Ever Tipped", value: tipStore.hasEverTipped ? "Yes" : "No")
                debugRow("Tip Count", value: "\(tipStore.tipCount)")
                debugRow("Total Tips", value: String(format: "$%.2f", tipStore.totalTipsReceived))
                debugRow("Purchase State", value: purchaseStateDescription)
                
                if let lastTipDate = tipStore.lastTipDate {
                    debugRow("Last Tip Date", value: DateFormatter.localizedString(from: lastTipDate, dateStyle: .short, timeStyle: .short))
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private var testTipJarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Isolated Tip Jar Test")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Test the tip jar component in isolation")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TipJarView()
        }
    }
    
    private var testAboutIntegration: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("About View Integration")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Test how the tip jar appears in the full About view")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button("Open About View") {
                showingAboutView = true
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.blue)
            )
        }
    }
    
    private var userDefaultsTestSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("User Defaults Testing")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Test tip tracking persistence")
                .font(.caption)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    Button("Simulate First Tip") {
                        simulateFirstTip()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Simulate Multiple Tips") {
                        simulateMultipleTips()
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack(spacing: 12) {
                    Button("Reset All Data") {
                        resetTipData()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.red)
                    
                    Button("Load Test Data") {
                        loadTestTipData()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
    }
    
    // MARK: - Helper Methods
    
    private func debugRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label + ":")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
        }
    }
    
    private var purchaseStateDescription: String {
        switch tipStore.purchaseState {
        case .idle:
            return "Idle"
        case .purchasing(let product):
            return "Purchasing \(product.displayName)"
        case .success(let product):
            return "Success: \(product.displayName)"
        case .failed(let error):
            return "Failed: \(error.localizedDescription)"
        case .unavailable:
            return "Unavailable"
        }
    }
    
    // MARK: - Test Data Methods
    
    private func simulateFirstTip() {
        UserDefaults.standard.set(true, forKey: "hasEverTipped")
        UserDefaults.standard.set(1, forKey: "tipCount")
        UserDefaults.standard.set(0.99, forKey: "totalTipsReceived")
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "lastTipDate")
    }
    
    private func simulateMultipleTips() {
        UserDefaults.standard.set(true, forKey: "hasEverTipped")
        UserDefaults.standard.set(5, forKey: "tipCount")
        UserDefaults.standard.set(12.95, forKey: "totalTipsReceived")
        UserDefaults.standard.set(Date().addingTimeInterval(-86400).timeIntervalSince1970, forKey: "lastTipDate")
    }
    
    private func resetTipData() {
        UserDefaults.standard.removeObject(forKey: "hasEverTipped")
        UserDefaults.standard.removeObject(forKey: "tipCount")
        UserDefaults.standard.removeObject(forKey: "totalTipsReceived")
        UserDefaults.standard.removeObject(forKey: "lastTipDate")
    }
    
    private func loadTestTipData() {
        UserDefaults.standard.set(true, forKey: "hasEverTipped")
        UserDefaults.standard.set(3, forKey: "tipCount")
        UserDefaults.standard.set(8.97, forKey: "totalTipsReceived")
        UserDefaults.standard.set(Date().addingTimeInterval(-3600).timeIntervalSince1970, forKey: "lastTipDate")
    }
}

// MARK: - Production Integration Checklist

/*
 🎯 PRODUCTION INTEGRATION CHECKLIST
 
 ✅ STOREKIT SETUP:
 - [ ] Product IDs configured in App Store Connect
 - [ ] Products approved and available
 - [ ] StoreKit configuration file added (for testing)
 - [ ] Entitlements configured for in-app purchases
 
 ✅ CODE INTEGRATION:
 - [ ] TipStore.swift added to project
 - [ ] TipJarView.swift added to project
 - [ ] AboutView.swift updated with tip jar integration
 - [ ] All color assets available ("GhanaGold", "KenteGold", etc.)
 - [ ] ScaleButtonStyle available in project
 
 ✅ TESTING CHECKLIST:
 - [ ] Products load correctly
 - [ ] Purchase flow works in sandbox
 - [ ] Transaction verification works
 - [ ] UserDefaults persistence works
 - [ ] UI responds correctly to all states
 - [ ] Error handling works gracefully
 - [ ] Cultural messaging displays correctly
 - [ ] Animations perform smoothly
 - [ ] Thank you flow works
 - [ ] Auto-collapse behavior works
 
 ✅ EDGE CASES:
 - [ ] No internet connection
 - [ ] StoreKit unavailable
 - [ ] User cancels purchase
 - [ ] Purchase fails
 - [ ] Products fail to load
 - [ ] App backgrounding during purchase
 - [ ] Multiple rapid taps
 
 ✅ CULTURAL VALIDATION:
 - [ ] Twi translations accurate ("Medaase", "Akwaaba")
 - [ ] Cultural messaging appropriate
 - [ ] Ghana flag colors correct
 - [ ] Heritage focus maintained
 - [ ] Non-commercial tone preserved
 
 ✅ PERFORMANCE:
 - [ ] No memory leaks in tip flow
 - [ ] Smooth animations on older devices
 - [ ] Quick response to user interactions
 - [ ] Proper cleanup on view dismissal
 
 ✅ ACCESSIBILITY:
 - [ ] VoiceOver labels appropriate
 - [ ] Button accessibility hints clear
 - [ ] Color contrast sufficient
 - [ ] Dynamic Type support
 
 ✅ APP STORE GUIDELINES:
 - [ ] Tips clearly labeled as tips
 - [ ] No misleading functionality promises
 - [ ] Graceful degradation when unavailable
 - [ ] No requirement to tip for app features
 
 */

// MARK: - Preview for Testing

#Preview("Tip Jar Testing") {
    TipJarTestingView()
}

// MARK: - Quick Integration Test

struct QuickTipJarTest: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    Text("Quick Integration Test")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Test the components individually
                    Group {
                        Text("1. TipJarView Component")
                            .font(.headline)
                        
                        TipJarView()
                        
                        Text("2. Cultural Elements Test")
                            .font(.headline)
                        
                        culturalElementsTest
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
        }
    }
    
    private var culturalElementsTest: some View {
        VStack(spacing: 16) {
            HStack {
                Text("🫖")
                    .font(.system(size: 32))
                
                Text("🇬🇭")
                    .font(.system(size: 32))
                
                Text("🍲")
                    .font(.system(size: 32))
            }
            
            Text("Medaase! Akwaaba to our heritage preservation mission!")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color("GhanaGold"))
                .multilineTextAlignment(.center)
            
            HStack(spacing: 20) {
                colorSwatch("GhanaGold", Color("GhanaGold"))
                colorSwatch("KenteGold", Color("KenteGold"))
                colorSwatch("WarmRed", Color("WarmRed"))
                colorSwatch("ForestGreen", Color("ForestGreen"))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGray6))
        )
    }
    
    private func colorSwatch(_ name: String, _ color: Color) -> some View {
        VStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 30, height: 30)
            
            Text(name)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview("Quick Test") {
    QuickTipJarTest()
}
