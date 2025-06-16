import Foundation

struct Product: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let description: String?
    let price: Int
    let stockQuantity: Int
    let loyaltyMultiplier: Int
}

extension Product {
    var imageName: String {
        switch id {
        case 1: return "filter_coffee"
        case 2: return "iced_americano"
        case 3: return "iced_latte"
        default: return "default_coffee"
        }
    }
}
