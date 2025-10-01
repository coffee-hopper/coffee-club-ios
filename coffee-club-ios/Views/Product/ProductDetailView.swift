import SwiftUI

struct ProductDetailView: View {
    let productID: Int

    @EnvironmentObject private var cart: CartStoreManager
    @EnvironmentObject private var selection: ProductSelection
    @Environment(\.appEnvironment) private var env

    @StateObject private var vm = ProductDetailViewModel()

    private var isLoading: Bool {
        if case .loading = vm.state { return true }
        return false
    }

    private var errorText: String? {
        if case .error(let msg) = vm.state { return msg }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Image(
                    (vm.product?.processedImageName)
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
                    Text(vm.product?.name ?? selection.snapshot(for: productID)?.name ?? "Loading…")
                        .font(.title)
                        .bold()

                    if let p = vm.product {
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

                    if let p = vm.product {
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
                    if let p = vm.product {
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

                Group {
                    if let p = vm.product {
                        let qty = cart.quantity(for: p.id)
                        let isOutOfStock = p.stockQuantity == 0

                        if qty == 0 {
                            Button(action: {
                                guard !isOutOfStock else { return }
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                                    cart.addToCart(p)
                                }
                            }) {
                                Text(isOutOfStock ? "Out of Stock" : "Add to Cart")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(24)
                                    .background(
                                        isOutOfStock ? Color.gray.opacity(0.4) : Color.accentColor
                                    )
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                    .padding(.horizontal)
                            }
                            .disabled(isOutOfStock)

                        } else {
                            VStack {
                                HStack(spacing: 12) {
                                    Text("Added to cart")
                                        .font(.headline)
                                        .foregroundColor(.white)

                                    Spacer(minLength: 0)

                                    CartStepperButton(
                                        product: p,
                                        quantity: qty,
                                        height: 28,
                                        isOutOfStock: isOutOfStock,
                                        onZeroQuantity: {
                                            cart.removeFromCart(productId: p.id)
                                        }
                                    )

                                    Button {
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.85))
                                        {
                                            cart.removeFromCart(productId: p.id)
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                            .foregroundColor(.white)
                                            .padding(8)
                                            .background(Color.red.opacity(0.95), in: Circle())
                                    }
                                    .accessibilityLabel("Remove from cart")
                                }
                                .padding()
                                .background(Color.accentDark.opacity(0.9))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .transition(.move(edge: .trailing).combined(with: .opacity))

                                HStack {
                                    IconButton(
                                        systemName: "cart",
                                        action: { env.nav.openCart() },
                                        isFilled: false,
                                        iconSize: 30
                                    )
                                    .accessibilityLabel("Go to cart")
                                }
                                .padding()
                                .background(Color.accentColor)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .transition(.move(edge: .trailing).combined(with: .opacity))

                            }
                        }

                    } else {
                        Button(action: {}) {
                            Text("Loading…")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.4))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                                .padding(.horizontal)
                        }
                        .disabled(true)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: cart.items.count)
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
                    Button("Retry") { vm.refresh(productID: productID) }
                        .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                .padding()
            }
        }
        .onAppear {
            vm.configure(
                productService: env.productService,
                tokenProvider: { env.tokenProvider?.token }
            )
            vm.load(productID: productID)
        }
    }
}
