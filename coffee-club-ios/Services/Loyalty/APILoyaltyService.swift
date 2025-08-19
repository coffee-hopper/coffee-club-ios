import Foundation

final class APILoyaltyService: LoyaltyServiceProtocol {
    private let client: APIClient
    init(client: APIClient) { self.client = client }

    func fetchStatus(userId: Int, token: String?) async throws -> LoyaltyStatus {
        try await client.request(LoyaltyStatus.self ,APIEndpoints.loyaltyStatus(userId), token: token)
    }
}
