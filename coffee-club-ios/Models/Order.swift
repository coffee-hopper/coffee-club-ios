import Foundation

struct OrderRequest: Codable {
    let user: Int
    let items: [OrderItem]
    let totalAmount: Double
    let status: String
}

struct OrderItem: Codable {
    let product: ProductRef
    let quantity: Int
    let price: Double
}

struct OrderResponse: Codable {
    let id: Int
    let totalAmount: Double
}
