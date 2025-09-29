import Foundation

struct ProductQueryOptions {
    var q: String? = nil
    var category: String? = nil
    var inStock: Bool? = nil
    var offset: Int = 0
    var limit: Int = 50
    var sort: String = "name"
    var order: String = "asc"
}

protocol ProductServiceProtocol {
    func fetchProducts(token: String?, options: ProductQueryOptions) async throws -> [Product]
    func fetchProduct(id: Int, token: String?) async throws -> Product
}

extension ProductServiceProtocol {
    func fetchProducts(
        token: String?,
        q: String? = nil,
        category: String? = nil,
        inStock: Bool? = nil,
        offset: Int = 0,
        limit: Int = 50,
        sort: String = "name",
        order: String = "asc"
    ) async throws -> [Product] {
        try await fetchProducts(
            token: token,
            options: .init(
                q: q,
                category: category,
                inStock: inStock,
                offset: offset,
                limit: limit,
                sort: sort,
                order: order
            )
        )
    }
}
