import Foundation

protocol PaymentServiceProtocol {
    func createPayment(_ request: PaymentRequest, token: String?) async throws -> PaymentResponse
    func confirmPayment(id: Int, token: String?) async throws -> PaymentResponse
}
