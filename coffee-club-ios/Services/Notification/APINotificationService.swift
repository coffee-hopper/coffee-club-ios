import Foundation

final class APINotificationService: NotificationServiceProtocol {
    private let client: APIClient

    private weak var tokenProvider: TokenProviding?

    init(client: APIClient, tokenProvider: TokenProviding?) {
        self.client = client
        self.tokenProvider = tokenProvider
    }

    private func currentToken() async -> String? {
        await MainActor.run { [weak tokenProvider] in tokenProvider?.token }
    }
    
    private func requireToken() async throws -> String {
        if let t = await currentToken(), !t.isEmpty { return t }
        throw AppError.unauthorized
    }


    func list(afterId: Int?, limit: Int?, unread: Bool?) async throws -> NotificationListResponse {
        let t = try await requireToken()
        return try await client.request(
            NotificationListResponse.self,
            "/notifications",
            method: .GET,
            token: t
        )
    }

    func unreadCount() async throws -> Int {
        let t = await currentToken()
        let resp = try await client.request(
            UnreadCountResponse.self,
            "/notifications/unread-count",
            method: .GET,
            token: t
        )
        return resp.count
    }

    func markRead(ids: [Int]) async throws -> Int {
        let t = await currentToken()
        let resp = try await client.request(
            UpdatedResponse.self,
            "/notifications/read",
            method: .PATCH,
            token: t,
            body: ["ids": ids]
        )
        return resp.updated
    }

    func markUnread(ids: [Int]) async throws -> Int {
        let t = await currentToken()
        let resp = try await client.request(
            UpdatedResponse.self,
            "/notifications/unread",
            method: .PATCH,
            token: t,
            body: ["ids": ids]
        )
        return resp.updated
    }

    func delete(ids: [Int]) async throws -> Int {
        let t = await currentToken()
        let resp = try await client.request(
            DeletedResponse.self,
            "/notifications",
            method: .DELETE,
            token: t,
            body: ["ids": ids]
        )
        return resp.deleted
    }
}

