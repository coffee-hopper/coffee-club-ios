import Foundation

protocol OrderServiceProtocol {
    func createOrder(_ request: OrderRequest, token: String?) async throws -> OrderResponse
    func getOrder(id: Int, token: String?) async throws -> OrderResponse
}
