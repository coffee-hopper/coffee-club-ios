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

struct ProductRef: Codable {
    let id: Int
}

extension Product {
    var imageName: String {
        switch id {
        case 1: return "coffee_icedLatte"
        case 2: return "coffee_icedMocha"
        case 3: return "coffee_latte"
        case 4: return "coffee_turkish"
        default: return "default_coffee"
        }
    }
}
