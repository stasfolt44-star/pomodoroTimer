import StoreKit
import Observation

@MainActor
@Observable
final class StoreManager {

    private(set) var products: [Product] = []
    private(set) var isPremium: Bool = false
    private(set) var purchaseInProgress: Bool = false

    private let productIds = [
        "com.sergepomodoro.premium.monthly",
        "com.sergepomodoro.premium.yearly"
    ]

    init() {
        Task { await checkEntitlements() }
        Task { await loadProducts() }
        observeTransactions()
    }

    // MARK: - Products

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIds)
                .sorted { $0.price < $1.price }
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    var monthlyProduct: Product? {
        products.first { $0.id.contains("monthly") }
    }

    var yearlyProduct: Product? {
        products.first { $0.id.contains("yearly") }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        purchaseInProgress = true
        defer { purchaseInProgress = false }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try Self.checkVerified(verification)
                await transaction.finish()
                isPremium = true
            case .userCancelled:
                break
            case .pending:
                break
            @unknown default:
                break
            }
        } catch {
            print("Purchase failed: \(error)")
        }
    }

    // MARK: - Restore

    func restore() async {
        try? await AppStore.sync()
        await checkEntitlements()
    }

    // MARK: - Entitlements

    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? Self.checkVerified(result) {
                if productIds.contains(transaction.productID) {
                    isPremium = true
                    return
                }
            }
        }
        isPremium = false
    }

    // MARK: - Transaction Observer

    @ObservationIgnored
    private var transactionTask: Task<Void, Never>?

    private func observeTransactions() {
        transactionTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? StoreManager.checkVerified(result) {
                    await transaction.finish()
                    await self?.checkEntitlements()
                }
            }
        }
    }

    nonisolated private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.unverified
        case .verified(let value):
            return value
        }
    }

    enum StoreError: Error {
        case unverified
    }
}
