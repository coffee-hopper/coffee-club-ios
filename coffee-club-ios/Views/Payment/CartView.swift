import SwiftUI

struct CartView: View {
    @EnvironmentObject var cart: CartManager

    @Binding var returnToHome: Bool
    @Binding var navigateToPayment: Bool
    @Binding var showCartView : Bool

    @State private var createdOrderId: Int?
    @State private var createdOrderAmount: Double?

    var totalAmount: Double {
        cart.items.reduce(0.0) { $0 + (Double($1.product.price) * Double($1.quantity)) }
    }

    var body: some View {
        VStack(spacing: 20) {
            Text("🛒 Your Cart")
                .font(.largeTitle.bold())
                .padding(.top)

            if cart.items.isEmpty {
                Spacer()
                Text("Cart is empty. Start adding items!")
                    .foregroundColor(.secondary)
                    .font(.headline)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 14) {
                        ForEach(cart.items) { item in
                            HStack(spacing: 16) {
                                Image(item.product.imageName)
                                    .resizable()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(item.product.name)
                                        .font(.headline)

                                    Text("\(item.quantity) × \(item.product.price)₺")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Button(action: {
                                    cart.removeFromCart(productId: item.product.id)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            .padding()
                            .background(Color.accentDark.opacity(0.9))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }

                VStack(spacing: 16) {
                    HStack {
                        Text("Total:")
                            .font(.title2.bold())
                        Spacer()
                        Text("\(Int(totalAmount))₺")
                            .font(.title2.bold())
                    }

                    Button(action: {
                        createOrderFromCart()
                    }) {
                        Text("Proceed to Payment")
                            .bold()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .disabled(cart.items.isEmpty)

                    Button("Clear Cart") {
                        cart.clearCart()
                    }
                    .foregroundColor(.red)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)

        .navigationDestination(isPresented: $navigateToPayment) {
            if let id = createdOrderId, let amount = createdOrderAmount {
                PaymentView(
                    orderId: id,
                    totalAmount: amount,
                    returnToHome: $returnToHome
                ).environmentObject(cart)

            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private var paymentDestination: some View {
        if let id = createdOrderId, let amount = createdOrderAmount {
            PaymentView(orderId: id, totalAmount: amount, returnToHome: $returnToHome)
        } else {
            EmptyView()
        }
    }

    private func createOrderFromCart() {
        guard let orderPayload = cart.createOrderPayload(),
            let orderData = try? JSONEncoder().encode(orderPayload)
        else {
            print("❌ Failed to prepare cart order")
            return
        }

        var request = URLRequest(url: URL(string: "http://localhost:3000/orders")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = orderData

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                let order = try? JSONDecoder().decode(OrderResponse.self, from: data)
            else {
                print("❌ Failed to create order from cart")
                return
            }

            DispatchQueue.main.async {
                self.createdOrderId = order.id
                self.createdOrderAmount = order.totalAmount
                self.navigateToPayment = true
                self.showCartView = false
            }
        }.resume()
    }
}


