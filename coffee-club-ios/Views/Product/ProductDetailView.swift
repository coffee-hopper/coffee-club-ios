//import SwiftUI
//
//struct ProductDetailView: View {
//    let product: Product
//    @EnvironmentObject var cart: CartStoreManager
//
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                Image(product.processedImageName)
//                    .resizable()
//                    .scaledToFit()
//                    .frame(maxWidth: .infinity)
//                    .frame(height: 260)
//                    .background(Color.gray.opacity(0.1))
//                    .clipShape(RoundedRectangle(cornerRadius: 24))
//                    .padding(.horizontal)
//
//                VStack(alignment: .leading, spacing: 12) {
//                    Text(product.name)
//                        .font(.title)
//                        .bold()
//
//                    HStack(spacing: 16) {
//                        Text(product.category.capitalized)
//                            .font(.subheadline)
//                            .foregroundColor(.secondary)
//
//                        Text("Stock: \(product.stockQuantity)")
//                            .font(.subheadline)
//                            .foregroundColor(product.stockQuantity > 0 ? .green : .red)
//                    }
//
//                    Text(PriceFormatting.string(from: Decimal(product.price)))
//                        .font(.title2.bold())
//                        .foregroundColor(.accentColor)
//
//                    Divider()
//
//                    Text("Description")
//                        .font(.headline)
//                    Text(product.description ?? "No description available.")
//                        .font(.body)
//                        .foregroundColor(.primary)
//                }
//                .padding(.horizontal)
//
//                Spacer(minLength: 24)
//
//                Button(action: {
//                    cart.addToCart(product)
//                }) {
//                    Text("Add to Cart")
//                        .font(.headline)
//                        .frame(maxWidth: .infinity)
//                        .padding()
//                        .background(Color.accentColor)
//                        .foregroundColor(.white)
//                        .cornerRadius(12)
//                        .padding(.horizontal)
//                }
//            }
//            .padding(.top)
//        }
//        .navigationTitle("Product Detail")
//        .navigationBarTitleDisplayMode(.inline)
//    }
//}

import SwiftUI

/// Single-component Product Detail with snapshot→refresh.
/// Pass *only* productID; it uses ProductSelection for instant data
/// and fetches the full Product via ProductService (with token).
struct ProductDetailView: View {
    let productID: Int

    @EnvironmentObject private var cart: CartStoreManager
    @EnvironmentObject private var selection: ProductSelection
    @Environment(\.appEnvironment) private var env

    @State private var product: Product?
    @State private var isLoading = false
    @State private var errorText: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(
                    (product?.processedImageName)
                        ?? (selection.snapshot(for: productID)?.imageName ?? "")
                )
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 260)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    Text(product?.name ?? selection.snapshot(for: productID)?.name ?? "Loading…")
                        .font(.title)
                        .bold()

                    if let p = product {
                        HStack(spacing: 16) {
                            Text(p.category.capitalized)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text("Stock: \(p.stockQuantity)")
                                .font(.subheadline)
                                .foregroundColor(p.stockQuantity > 0 ? .green : .red)
                        }
                    } else {
                        HStack(spacing: 16) {
                            Text("Category…").redacted(reason: .placeholder).font(.subheadline)
                            Text("Stock: —").redacted(reason: .placeholder).font(.subheadline)
                        }
                        .foregroundStyle(.secondary)
                    }

                    if let p = product {
                        Text(PriceFormatting.string(from: Decimal(p.price)))
                            .font(.title2.bold())
                            .foregroundColor(.accentColor)
                    } else if let snap = selection.snapshot(for: productID) {
                        Text(PriceFormatting.string(from: snap.price))
                            .font(.title2.bold())
                            .foregroundColor(.accentColor)
                    } else {
                        Text("₺—").redacted(reason: .placeholder)
                            .font(.title2.bold())
                            .foregroundColor(.accentColor)
                    }

                    Divider()

                    Text("Description")
                        .font(.headline)
                    if let p = product {
                        Text(p.description ?? "No description available.")
                            .font(.body)
                            .foregroundColor(.primary)
                    } else {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Loading description…").redacted(reason: .placeholder)
                            Text(" ").redacted(reason: .placeholder)
                            Text(" ").redacted(reason: .placeholder)
                        }
                        .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal)

                Spacer(minLength: 24)

                Button(action: { if let p = product { cart.addToCart(p) } }) {
                    Text(product == nil ? "Loading…" : "Add to Cart")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(product == nil ? Color.gray.opacity(0.4) : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(product == nil)
            }
            .padding(.top)
        }
        .navigationTitle("Product Detail")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            if let errorText, !isLoading {
                VStack(spacing: 12) {
                    Text("Failed to load product").font(.headline)
                    Text(errorText).font(.subheadline).foregroundStyle(.secondary)
                    Button("Retry") { Task { await loadLatest() } }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding()
            }
        }
        .task { await loadLatest() }  // snapshot shows instantly; then we refresh
    }

    @MainActor
    private func loadLatest() async {
        guard !isLoading else { return }
        isLoading = true
        errorText = nil
        do {
            let token = env.tokenProvider?.token
            let fetched = try await env.productService.fetchProduct(id: productID, token: token)
            self.product = fetched
        } catch {
            self.errorText = error.localizedDescription
        }
        isLoading = false
    }
}
