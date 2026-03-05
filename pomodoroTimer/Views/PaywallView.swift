import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(StoreManager.self) var store
    @Environment(\.dismiss) private var dismiss
    @State private var selectedProduct: Product?

    var body: some View {
        ZStack {
            Color(hex: 0x0D0D0D)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                Spacer().frame(height: 32)

                // Header
                Text("Unlock Full Power")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(.white)

                Spacer().frame(height: 8)

                Text("Take your focus to the next level")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))

                Spacer().frame(height: 36)

                // Features
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "paintpalette", title: "All Themes", subtitle: "Sand, Forest, Lavender")
                    FeatureRow(icon: "slider.horizontal.3", title: "Custom Intervals", subtitle: "Set any duration you want")
                    FeatureRow(icon: "bell.badge", title: "Custom Sounds", subtitle: "Choose notification sounds")
                    FeatureRow(icon: "chart.bar", title: "Statistics", subtitle: "Track your productivity")
                }
                .padding(.horizontal, 32)

                Spacer()

                // Product selection
                VStack(spacing: 12) {
                    if let yearly = store.yearlyProduct {
                        ProductButton(
                            product: yearly,
                            label: "Yearly",
                            detail: yearlyDetail(yearly),
                            badge: "SAVE 58%",
                            isSelected: selectedProduct?.id == yearly.id
                        ) {
                            selectedProduct = yearly
                        }
                    }

                    if let monthly = store.monthlyProduct {
                        ProductButton(
                            product: monthly,
                            label: "Monthly",
                            detail: monthly.displayPrice + "/mo",
                            badge: nil,
                            isSelected: selectedProduct?.id == monthly.id
                        ) {
                            selectedProduct = monthly
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer().frame(height: 20)

                // CTA
                Button {
                    guard let product = selectedProduct else { return }
                    Task { await store.purchase(product) }
                } label: {
                    Group {
                        if store.purchaseInProgress {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Start Free Trial")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(Color(hex: 0xFF6B35))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .disabled(selectedProduct == nil || store.purchaseInProgress)
                .padding(.horizontal, 20)

                Spacer().frame(height: 12)

                // Restore + Terms
                HStack(spacing: 16) {
                    Button("Restore Purchases") {
                        Task { await store.restore() }
                    }
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))

                    Text("·").foregroundStyle(.white.opacity(0.3))

                    Button("Terms") {}
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))

                    Text("·").foregroundStyle(.white.opacity(0.3))

                    Button("Privacy") {}
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.4))
                }

                Spacer().frame(height: 20)
            }
        }
        .onAppear {
            selectedProduct = store.yearlyProduct
        }
    }

    private func yearlyDetail(_ product: Product) -> String {
        let monthly = product.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = product.priceFormatStyle.locale
        let monthlyStr = formatter.string(from: monthly as NSDecimalNumber) ?? ""
        return "\(product.displayPrice)/yr (\(monthlyStr)/mo)"
    }
}

// MARK: - Feature Row

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(hex: 0xFF6B35))
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(.subheadline, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
    }
}

// MARK: - Product Button

private struct ProductButton: View {
    let product: Product
    let label: String
    let detail: String
    let badge: String?
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(label)
                            .font(.system(.body, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundStyle(.white)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Capsule().fill(Color(hex: 0xFF6B35)))
                        }
                    }
                    Text(detail)
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color(hex: 0xFF6B35) : .white.opacity(0.3))
                    .font(.title3)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? Color(hex: 0xFF6B35) : .white.opacity(0.15), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}
