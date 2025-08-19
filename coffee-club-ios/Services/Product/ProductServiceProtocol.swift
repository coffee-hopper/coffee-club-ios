import Foundation

protocol ProductServiceProtocol {
    func fetchProducts(token: String?) async throws -> [Product]
    func fetchProduct(id: Int, token: String?) async throws -> Product
}
