import Foundation

struct CartItem: Codable, Identifiable {
    var id: Int { product.id }
    let product: Product
    var quantity: Int
}
