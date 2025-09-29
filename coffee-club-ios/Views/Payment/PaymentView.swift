import SwiftUI

struct PaymentView: View {
    let orderId: Int
    let totalAmount: Decimal

    @Binding var returnToHome: Bool
    @EnvironmentObject var cart: CartStoreManager
    @Environment(\.appEnvironment) private var env

    @StateObject private var vm: PaymentViewModel

    init(orderId: Int, totalAmount: Decimal, returnToHome: Binding<Bool>) {
        self.orderId = orderId
        self.totalAmount = totalAmount
        self._returnToHome = returnToHome
        _vm = StateObject(
            wrappedValue: PaymentViewModel(orderId: orderId, totalAmount: totalAmount)
        )
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Ödeme")
                .font(.title2)
                .bold()
                .padding(.top, 8)
                .foregroundColor(.primary)

            Text("Toplam: \(PriceFormatting.string(from: totalAmount))")
                .font(.headline)
                .foregroundColor(.primary)

            Picker("Payment Method", selection: $vm.selectedMethod) {
                ForEach(["cash", "iyzico"], id: \.self) { method in
                    Text(method.capitalized)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Button {
                Task { await vm.submitPayment() }
            } label: {
                Text(vm.ctaTitle)
                    .bold()
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(vm.isLoading)

            if let status = vm.paymentStatus {
                Text("Status: \(status)")
                    .foregroundColor(status == "success" ? .green : .red)
            }

            if let msg = vm.message {
                Text(msg)
                    .padding(.top, 4)
                    .multilineTextAlignment(.center)
            }

            if vm.isSuccess {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 8)
                            .opacity(0.1)
                            .foregroundColor(Color("TextSecondary"))

                        Circle()
                            .trim(from: 0, to: vm.redirectProgress)
                            .stroke(Color("GreenEnergic"), lineWidth: 8)
                            .rotationEffect(.degrees(-90))

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
                .task {

                    try? await Task.sleep(nanoseconds: 2_000_000_000)
                    cart.clearCart()
                    returnToHome = true
                }
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .onAppear {
            vm.attachEnvironment(env)
        }
    }
}
