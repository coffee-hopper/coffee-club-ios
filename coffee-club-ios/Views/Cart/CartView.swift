//TODO: createOrderFromCart Step 7 will move this to Payment orchestration

import SwiftUI

struct CartView: View {
    @EnvironmentObject var auth: AuthViewModel
    @EnvironmentObject var cartStore: CartStoreManager

    @Binding var returnToHome: Bool
    @Binding var navigateToPayment: Bool
    @Binding var showCartView: Bool
    @Binding var createdOrderId: Int?
    @Binding var createdOrderAmount: Decimal?

    let orderService: OrderServiceProtocol
    let tokenProvider: TokenProviding?

    @StateObject private var vm: CartViewModel

    init(
        returnToHome: Binding<Bool>,
        navigateToPayment: Binding<Bool>,
        showCartView: Binding<Bool>,
        createdOrderId: Binding<Int?>,
        createdOrderAmount: Binding<Decimal?>,
        orderService: OrderServiceProtocol,
        tokenProvider: TokenProviding?,
        store: CartStore,
        productService: ProductServiceProtocol? = nil
    ) {
        _returnToHome = returnToHome
        _navigateToPayment = navigateToPayment
        _showCartView = showCartView
        _createdOrderId = createdOrderId
        _createdOrderAmount = createdOrderAmount
        self.orderService = orderService
        self.tokenProvider = tokenProvider
        _vm = StateObject(wrappedValue: CartViewModel(store: store, productService: productService))
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("Your Cart")
                .font(.largeTitle.bold())
                .padding(.top)

            if vm.items.isEmpty {
                Spacer()
                Text("Cart is empty. Start adding items!")
                    .foregroundColor(.secondary)
                    .font(.headline)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(vm.items) { item in
                            CartRow(
                                item: item,
                                onRemove: { vm.remove(productId: item.product.id) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    HStack {
                        Text("Total:")
                            .font(.title2.bold())
                        Spacer()
                        Text(PriceFormatting.string(from: vm.totalAmount))
                            .font(.title2.bold())
                    }

                    Button(action: { createOrderFromCart() }) {
                        Text("Proceed to Payment")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(!vm.canCheckout)

                    Button("Clear Cart") { vm.clear() }
                        .foregroundColor(.red)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
    }

    // TEMP: Step 7 will move this to Payment orchestration
    private func createOrderFromCart() {
        guard
            let userId = auth.user?.id,
            let payload = vm.makeOrderRequest(userId: userId)
        else {
            print("❌ Missing/invalid user id or failed to build payload")
            return
        }

        Task {
            do {
                let order = try await orderService.createOrder(payload, token: tokenProvider?.token)
                await MainActor.run {
                    self.createdOrderId = order.id
                    self.createdOrderAmount = order.totalAmount
                    self.navigateToPayment = true
                    self.showCartView = false
                }
            } catch {
                print("❌ Failed to create order from cart:", error)
            }
        }
    }
}

private struct CartRow: View {
    let item: CartItem
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Image(item.product.processedImageName)
                .resizable()
                .scaledToFit()
                .frame(height: 80)

                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.headline)

                Text("\(item.quantity) × \(item.product.price)₺")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()

            CartStepperButton(
                product: item.product,
                quantity: item.quantity,
                height: 25,
                isOutOfStock: item.product.stockQuantity == 0,
                onZeroQuantity: onRemove
            )

            Button(action: onRemove) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color.accentDark.opacity(0.9))
        .cornerRadius(12)
    }
}
