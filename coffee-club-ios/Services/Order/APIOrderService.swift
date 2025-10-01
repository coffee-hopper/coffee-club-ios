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

// MARK: - Cart → Order orchestration
enum CheckoutError: Error {
    case emptyCart
}

extension OrderServiceProtocol {
    /// Builds an OrderRequest from the given cart and creates the order.
    func createOrderFromCart(
        userId: Int,
        cart: CartStore,
        token: String?
    ) async throws -> OrderResponse {
        guard let payload = cart.createOrderPayload(userId: userId) else {
            throw CheckoutError.emptyCart
        }
        return try await createOrder(payload, token: token)
    }
}
