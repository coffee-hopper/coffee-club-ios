import Foundation

extension ProductQueryOptions {
    fileprivate var queryItems: [URLQueryItem] {
        var items: [URLQueryItem] = []
        if let q, !q.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            items.append(.init(name: "q", value: q))
        }
        if let category, !category.isEmpty {
            items.append(.init(name: "category", value: category))
        }
        if let inStock {
            items.append(.init(name: "inStock", value: inStock ? "true" : "false"))
        }
        items.append(.init(name: "offset", value: String(offset)))
        items.append(.init(name: "limit", value: String(limit)))
        items.append(.init(name: "sort", value: sort))
        items.append(.init(name: "order", value: order))
        return items
    }
}

final class APIProductService: ProductServiceProtocol {
    private let client: APIClient
    init(client: APIClient) { self.client = client }

    func fetchProducts(token: String?, options: ProductQueryOptions) async throws -> [Product] {
        try await client.request(
            [Product].self,
            APIEndpoints.products,
            query: options.queryItems,
            token: token
        )
    }

    func fetchProduct(id: Int, token: String?) async throws -> Product {
        try await client.request(Product.self, APIEndpoints.product(id), token: token)
    }
}
