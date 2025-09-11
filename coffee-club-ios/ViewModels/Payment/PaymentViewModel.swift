import Foundation
import SwiftUI

@MainActor
final class PaymentViewModel: ObservableObject {

    let orderId: Int
    let totalAmount: Decimal

    private var paymentService: PaymentServiceProtocol?
    private weak var tokenProvider: TokenProviding?

    @Published var selectedMethod: String = "cash"
    @Published var isLoading: Bool = false
    @Published var paymentStatus: String? = nil  // "success" | "failed"
    @Published var message: String? = nil
    @Published var redirectProgress: CGFloat = 0.0

    init(orderId: Int, totalAmount: Decimal) {
        self.orderId = orderId
        self.totalAmount = totalAmount
    }

    func attachEnvironment(_ env: AppEnvironment) {
        self.paymentService = env.paymentService
        self.tokenProvider = env.tokenProvider
    }

    func submitPayment() async {
        guard let paymentService else {
            self.message = "Ödeme servisine erişilemiyor."
            self.paymentStatus = "failed"
            return
        }

        isLoading = true
        defer { isLoading = false }

        // NOTE: We only have builder for cash in APIPaymentService today.
        // Until iyzico path lands, we still use `.cash` (server accepts status: "success").
        let request = PaymentRequest.cash(orderId: orderId, amount: totalAmount)
        do {
            let resp = try await paymentService.createPayment(request, token: tokenProvider?.token)
            self.paymentStatus = resp.payment.status
            self.message = resp.messages.first

            if resp.payment.status == "success" {
                withAnimation(.linear(duration: 1.5)) {
                    self.redirectProgress = 2.0
                }
            } else {
                self.paymentStatus = "failed"
            }
        } catch {

            self.paymentStatus = "failed"
            self.message =
                (error as? LocalizedError)?.errorDescription ?? "Ödeme sırasında bir hata oluştu."
        }
    }

    
    var ctaTitle: String { isLoading ? "Processing..." : "Pay Now" }
    var isSuccess: Bool { paymentStatus == "success" }
}
