//
//  PurchaseManager.swift
//  MoveMe
//
//  Created by User on 2024-10-07.
//

import Foundation
import StoreKit
import SwiftUI

enum UserDefaultsKeys {
    static let isPremium = "isPremium"
}

class PurchaseManager: ObservableObject {
    
    @AppStorage(UserDefaultsKeys.isPremium) var isPremium = false
    
    @Published var products: [Product] = []
    @Published var dismissSubcriptionCover: Bool = false
    
    init() {
        fetchProducts()
    }
    
    func fetchProducts() {
        Task {
            do {
                let products = try await Product.products(for: ["pro.yearly"])
                DispatchQueue.main.async {
                    self.products = products
                }
            } catch {
                print("Failed to fetch products: \(error)")
            }
        }
    }
    
    func purchase(_ product: Product) {
        Task {
            do {
                let result = try await product.purchase()
                await handlePurchaseResult(result)
                dismissSubcriptionCover.toggle()
            } catch {
                print("Failed to purchase: \(error)")
                if let skError = error as? StoreKitError {
                    switch skError {
                    case .userCancelled: print("User cancelled")
                    case .networkError: print("Network error")
                    case .unknown: print("Unknown error")
                    case .systemError(_): print("SYSTEM error")
                    case .notAvailableInStorefront: print("notAvailableInStorefront error")
                    case .notEntitled: print("notEntitled error")
                    @unknown default: print("Unhandled error")
                    }
                }
            }
        }
    }
    
    @MainActor
    private func handlePurchaseResult(_ result: Product.PurchaseResult) {
        switch result {
        case .success(let verificationResult):
            handleTransactionResult(verificationResult)
        case .userCancelled:
            print("User cancelled the purchase")
        case .pending:
            print("Purchase is pending")
        @unknown default:
            print("Unknown purchase result")
        }
    }
    
    @MainActor
    private func handleTransactionResult(_ result: VerificationResult<StoreKit.Transaction>) {
        switch result {
        case .verified(let transaction):
            // Handle successful purchase
            print("Purchase successful!")
            isPremium = true
            // Update your app's state or unlock features here
            Task {
                await transaction.finish()
            }
        case .unverified(_, let error):
            print("Transaction unverified: \(error)")
        }
    }

    private func startTransactionListener() {
        Task {
            for await result in StoreKit.Transaction.updates {
                await handleTransactionResult(result)
            }
        }
    }
}
