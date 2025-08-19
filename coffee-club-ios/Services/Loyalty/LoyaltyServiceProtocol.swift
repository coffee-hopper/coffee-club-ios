import Foundation

protocol LoyaltyServiceProtocol {
    func fetchStatus(userId: Int, token:String?) async throws -> LoyaltyStatus
}
