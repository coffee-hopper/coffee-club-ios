import Foundation

final class APIProductService: ProductServiceProtocol {
    private let client: APIClient
    init(client: APIClient) { self.client = client }

    func fetchProducts(token: String?) async throws -> [Product] {
        try await client.request([Product].self, APIEndpoints.products, token: token)
    }

    func fetchProduct(id: Int, token: String?) async throws -> Product {
        try await client.request(Product.self, APIEndpoints.product(id), token: token)
    }
}
