import Foundation

protocol NotificationServiceProtocol {
    func list(afterId: Int?, limit: Int?, unread: Bool?) async throws -> NotificationListResponse
    func unreadCount() async throws -> Int
    func markRead(ids: [Int]) async throws -> Int
    func markUnread(ids: [Int]) async throws -> Int
    func delete(ids: [Int]) async throws -> Int
}
