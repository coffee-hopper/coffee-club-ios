import Foundation

final class APIPaymentService: PaymentServiceProtocol {
    private let client: APIClient
    init(client: APIClient) { self.client = client }

    func createPayment(_ request: PaymentRequest, token: String?) async throws -> PaymentResponse {
        try await client.request(
            PaymentResponse.self,
            APIEndpoints.payments,
            method: .POST,
            token: token,
            body: request
        )
    }

    func confirmPayment(id: Int, token: String?) async throws -> PaymentResponse {
        try await client.request(
            PaymentResponse.self,
            APIEndpoints.payment(id),
            method: .PATCH,
            token: token
        )
    }
}

extension PaymentRequest {
    static func cash(orderId: Int, amount: Decimal) -> PaymentRequest {
        .init(
            order: orderId,
            iyzicoTransactionId: "",
            amount: amount,
            paymentMethod: "cash",
            status: "success"
        )
    }
}
