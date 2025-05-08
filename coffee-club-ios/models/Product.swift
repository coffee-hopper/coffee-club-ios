//
//  Product.swift
//  coffee-club-ios
//
//  Created by Bahadır Pekcan on 20.05.2025.
//

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
