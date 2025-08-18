import SwiftUI

struct PaymentView: View {
    let orderId: Int
    let totalAmount: Decimal

    @Binding var returnToHome: Bool
    @EnvironmentObject var cart: CartManager

    @State private var selectedMethod: String = "cash"
    @State private var paymentStatus: String?
    @State private var isLoading = false
    @State private var message: String?
    @State private var redirectProgress: CGFloat = 0.0

    let methods = ["cash", "iyzico"]

    var body: some View {
        VStack(spacing: 24) {
            Text("💳 Payment")
                .font(.largeTitle.bold())

            Text("Total: \(PriceFormatting.string(from: totalAmount))")
                .font(.title2)
                .foregroundColor(.primary)

            Picker("Payment Method", selection: $selectedMethod) {
                ForEach(methods, id: \.self) { method in
                    Text(method.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Button(action: submitPayment) {
                Text(isLoading ? "Processing..." : "Pay Now")
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading)

            if let status = paymentStatus {
                Text("Status: \(status)")
                    .foregroundColor(status == "success" ? .green : .red)
            }

            if let msg = message {
                Text(msg)
                    .padding(.top, 4)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }

            if paymentStatus == "success" {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 8)
                            .opacity(0.1)
                            .foregroundColor(Color("TextSecondary"))

                        Circle()
                            .trim(from: 0, to: redirectProgress)
                            .stroke(Color("GreenEnergic"), lineWidth: 8)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1.5), value: redirectProgress)

                        Text("Returning...")
                            .font(.subheadline)
                            .foregroundColor(Color("TextSecondary"))
                    }
                    .frame(width: 100, height: 100)

                    Text("Thank you for your purchase!\nYou’ll be redirected to home.")
                        .font(.footnote)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color("TextSecondary"))
                }
                .padding(.top)
            }

            Spacer()

            if paymentStatus == "success" {
                IconButton(systemName: "house.fill") {
                    cart.clearCart()
                    returnToHome = true
                }
                .padding(.top, 24)
            }
        }
        .padding()
    }

    private func submitPayment() {
        isLoading = true
        paymentStatus = nil
        message = nil

        let payload = PaymentRequest(
            order: orderId,
            iyzicoTransactionId: UUID().uuidString,
            amount: totalAmount,
            paymentMethod: selectedMethod,
            status: "success"
        )

        guard let url = URL(string: "http://localhost:3000/payments"),
            let data = try? JSONEncoder().encode(payload)
        else {
            print("❌ Failed to encode payment request")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = data

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                self.isLoading = false

                if let error = error {
                    print("❌ Payment Error:", error.localizedDescription)
                    self.paymentStatus = "failed"
                    return
                }

                guard let data = data else {
                    self.paymentStatus = "failed"
                    return
                }

                do {
                    let decoded = try JSONDecoder().decode(PaymentResponse.self, from: data)
                    self.paymentStatus = decoded.payment.status
                    self.message = decoded.messages.first

                    if decoded.payment.status == "success" {
                        withAnimation {
                            redirectProgress = 2.0
                        }

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            cart.clearCart()
                            returnToHome = true
                        }
                    }
                } catch {
                    print("❌ Payment decode error:", error)
                    self.paymentStatus = "failed"
                }
            }
        }.resume()
    }
}

#Preview {
    PaymentView(
        orderId: 123,
        totalAmount: 18.50,
        returnToHome: .constant(false)
    )
    .environmentObject(CartManager())
}
