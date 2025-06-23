import CodeScanner
import SwiftUI

struct QRScanner: View {
    @State var isPresentingScanner = false
    @State var scannedCode: String = "Scan a QR code to get started"

    var scannerSheet: some View {
        CodeScannerView(
            codeTypes: [.qr],
            completion: { result in
                if case let .success(code) = result {
                    self.scannedCode = code.string
                    self.isPresentingScanner = false

                    print("📦 Scanned QR Content:")
                    print(code.string)

                    guard let data = code.string.data(using: .utf8),
                        let payload = try? JSONDecoder().decode(QRPayload.self, from: data)
                    else {
                        print("❌ Failed to decode QR payload")
                        return
                    }

                    // 1️⃣ Fetch real product prices
                    let productURL = URL(string: "http://localhost:3000/products")!
                    URLSession.shared.dataTask(with: productURL) { data, _, _ in
                        guard let data = data,
                            let products = try? JSONDecoder().decode([Product].self, from: data)
                        else {
                            print("❌ Failed to fetch product list")
                            return
                        }

                        let orderItems: [OrderItem] = payload.items
                            .filter { item in
                                let exists = products.contains(where: { $0.id == item.productId })
                                if !exists {
                                    print("⚠️ Product not found: \(item.productId)")
                                }
                                return exists
                            }
                            .map { item in
                                let product = products.first(where: { $0.id == item.productId })!
                                return OrderItem(
                                    product: ProductRef(id: product.id),
                                    quantity: item.quantity,
                                    price: Double(product.price)
                                )
                            }

                        let totalAmount = orderItems.reduce(0.0) {
                            $0 + ($1.price * Double($1.quantity))
                        }

                        // 2️⃣ Prepare order payload
                        let orderPayload = OrderRequest(
                            user: payload.userId,
                            items: orderItems,
                            totalAmount: totalAmount,
                            status: "pending"
                        )

                        guard let orderData = try? JSONEncoder().encode(orderPayload) else {
                            print("❌ Failed to encode order payload")
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
                                print("❌ Failed to decode order response")
                                return
                            }

                            print("✅ Order created:", order.id)

                            // 3️⃣ Create invoice
                            let invoicePayload = InvoiceRequest(
                                order: ProductRef(id: order.id),
                                billingAddress: "Swift Café - Table 7",
                                totalAmount: order.totalAmount
                            )

                            guard let invoiceData = try? JSONEncoder().encode(invoicePayload) else {
                                print("❌ Failed to encode invoice payload")
                                return
                            }

                            var invoiceRequest = URLRequest(
                                url: URL(string: "http://localhost:3000/invoices")!
                            )
                            invoiceRequest.httpMethod = "POST"
                            invoiceRequest.setValue(
                                "application/json",
                                forHTTPHeaderField: "Content-Type"
                            )
                            invoiceRequest.httpBody = invoiceData

                            URLSession.shared.dataTask(with: invoiceRequest) { _, _, _ in
                                print("✅ Invoice created for order:", order.id)
                            }.resume()
                        }.resume()
                    }.resume()
                }
            }
        )
    }

    var body: some View {
        VStack {

            IconButton(systemName: "qrcode") {
                self.isPresentingScanner = true
                print("qr tapped")
            }
            .sheet(isPresented: $isPresentingScanner) {
                self.scannerSheet
            }
        }

    }
}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
}
