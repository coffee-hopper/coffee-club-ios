// TODO: inject services temporaly(productService-orderService-tokenProvider..) (later, these goes into a ViewModel)

import CodeScanner
import SwiftUI

struct QRScanner: View {
    @Binding var isPresentingScanner: Bool
    @Binding var navigateToPayment: Bool
    @Binding var createdOrderId: Int?
    @Binding var createdOrderAmount: Decimal?

    let productService: ProductServiceProtocol
    let orderService: OrderServiceProtocol
    let tokenProvider: TokenProviding?

    var body: some View {
        IconButton(systemName: "qrcode") { self.isPresentingScanner = true }
            .sheet(isPresented: $isPresentingScanner) { scannerSheet }
    }

    var scannerSheet: some View {
        CodeScannerView(codeTypes: [.qr]) { result in
            guard case let .success(code) = result else { return }
            self.isPresentingScanner = false
            handleScanned(code: code.string)
        }
    }

    private func handleScanned(code: String) {
        guard let data = code.data(using: .utf8),
            let payload = try? JSONDecoder().decode(QRPayload.self, from: data)
        else {
            print("❌ Failed to decode QR payload")
            return
        }

        Task {
            do {
                // 1) fetch products via service
                let products: [Product] = try await productService.fetchProducts(
                    token: tokenProvider?.token
                )

                // 2) map to order items
                let orderItems: [OrderItem] = payload.items.compactMap { item in
                    guard let product = products.first(where: { $0.id == item.productId }) else {
                        return nil
                    }
                    return OrderItem(
                        product: ProductRef(id: product.id),
                        quantity: item.quantity,
                        price: Decimal(product.price)
                    )
                }

                let totalAmount = orderItems.reduce(Decimal(0)) {
                    $0 + ($1.price * Decimal($1.quantity))
                }

                let orderPayload = OrderRequest(
                    user: payload.userId,
                    items: orderItems,
                    totalAmount: totalAmount,
                    status: "success"
                )

                // 3) create order via service
                let order: OrderResponse = try await orderService.createOrder(
                    orderPayload,
                    token: tokenProvider?.token
                )

                await MainActor.run {
                    self.createdOrderId = order.id
                    self.createdOrderAmount = order.totalAmount
                    self.navigateToPayment = true
                }
            } catch {
                print("❌ QR flow failed:", error)
            }
        }
    }
}
