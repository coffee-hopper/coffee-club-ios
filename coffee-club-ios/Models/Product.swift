import Foundation
import UIKit

struct Product: Codable, Identifiable {
    let id: Int
    let name: String
    let imageName: String
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
    var processedImageName: String {
        let assetName = imageName.replacingOccurrences(of: ".png", with: "")

        if UIImage(named: assetName) != nil {
            return assetName
        }

        // Fallback by category
        switch category.lowercased() {
        case "coffee": return "default_coffee"
        case "tea": return "default_tea"
        case "food": return "default_food"
        default: return "default_product"
        }
    }
}
