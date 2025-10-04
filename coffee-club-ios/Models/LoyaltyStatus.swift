import Foundation

struct LoyaltyStatus: Codable {
    let stars: Int
    let rewards: Int
    let remainingToNext: Int
    let requiredStars: Int
    
    var isEligibleForFreeDrink: Bool { stars >= requiredStars }
    var progress: Double {
        guard requiredStars > 0 else { return 0 }
        return min(1, Double(stars) / Double(requiredStars))
    }
}
