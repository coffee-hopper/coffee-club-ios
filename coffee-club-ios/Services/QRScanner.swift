import CodeScanner
import SwiftUI

struct QRScanner: View {
    @Binding var isPresentingScanner: Bool
    @Binding var navigateToPayment: Bool
    @Binding var createdOrderId: Int?
    @Binding var createdOrderAmount: Double?

    var body: some View {
        IconButton(systemName: "qrcode") {
            self.isPresentingScanner = true
        }
        .sheet(isPresented: $isPresentingScanner) {
            scannerSheet
        }
    }

    var scannerSheet: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.isPresentingScanner = false
                    print("📦 Scanned QR Content:\n\(code.string)")

                    guard let data = code.string.data(using: .utf8),
                          let payload = try? JSONDecoder().decode(QRPayload.self, from: data)
                    else {
                        print("❌ Failed to decode QR payload")
                        return
                    }

                    let productURL = URL(string: "http://localhost:3000/products")!
                    URLSession.shared.dataTask(with: productURL) { data, _, _ in
                        guard let data = data,
                              let products = try? JSONDecoder().decode([Product].self, from: data)
                        else {
                            print("❌ Failed to fetch products")
                            return
                        }

                        let orderItems: [OrderItem] = payload.items.compactMap { item in
                            guard let product = products.first(where: { $0.id == item.productId })
                            else { return nil }
                            return OrderItem(
                                product: ProductRef(id: product.id),
                                quantity: item.quantity,
                                price: Double(product.price)
                            )
                        }

                        let totalAmount = orderItems.reduce(0.0) {
                            $0 + ($1.price * Double($1.quantity))
                        }

                        let orderPayload = OrderRequest(
                            user: payload.userId,
                            items: orderItems,
                            totalAmount: totalAmount,
                            status: "pending"
                        )

                        guard let orderData = try? JSONEncoder().encode(orderPayload) else {
                            return
                        }

                        var orderRequest = URLRequest(
                            url: URL(string: "http://localhost:3000/orders")!
                        )
                        orderRequest.httpMethod = "POST"
                        orderRequest.setValue(
                            "application/json",
                            forHTTPHeaderField: "Content-Type"
                        )
                        orderRequest.httpBody = orderData

                        URLSession.shared.dataTask(with: orderRequest) { data, _, _ in
                            guard let data = data,
                                  let order = try? JSONDecoder().decode(
                                      OrderResponse.self,
                                      from: data
                                  )
                            else {
                                print("❌ Order creation failed")
                                return
                            }

                            DispatchQueue.main.async {
                                self.createdOrderId = order.id
                                self.createdOrderAmount = order.totalAmount
                                self.navigateToPayment = true
                            }
                        }.resume()
                    }.resume()
                }
            }
        )
    }
}
