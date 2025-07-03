import Foundation

struct CartItem: Codable, Identifiable {
    let id = UUID()
    let product: Product
    var quantity: Int
}
