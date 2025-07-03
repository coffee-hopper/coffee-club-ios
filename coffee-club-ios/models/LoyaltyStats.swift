import Foundation

struct LoyaltyStats: Codable {
    let stars: Int
    let rewards: Int
    let remainingToNext: Int
    let requiredStars: Int
}
