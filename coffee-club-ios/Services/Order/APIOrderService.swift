import Foundation

final class APIOrderService: OrderServiceProtocol {
    private let client: APIClient
    init(client: APIClient) { self.client = client }

    func createOrder(_ request: OrderRequest, token: String?) async throws -> OrderResponse {
        try await client.request(
            OrderResponse.self,
            APIEndpoints.orders,
            method: .POST,
            token: token,
            body: request
        )
    }

    func getOrder(id: Int, token: String?) async throws -> OrderResponse {
        try await client.request(OrderResponse.self, APIEndpoints.order(id), token: token)
    }
}
