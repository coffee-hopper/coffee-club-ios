import Foundation

struct OrderItem: Codable {
    let product: ProductRef
    let quantity: Int
    let price: Decimal
}

struct OrderRequest: Codable {
    let user: Int
    let items: [OrderItem]
    let totalAmount: Decimal
    let status: String
}

struct OrderResponse: Codable {
    let id: Int
    let totalAmount: Decimal
}
