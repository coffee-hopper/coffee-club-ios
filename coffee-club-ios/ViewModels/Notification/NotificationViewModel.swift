import Foundation

@MainActor
final class NotificationsViewModel: ObservableObject {
    @Published private(set) var items: [NotificationDTO] = []
    @Published private(set) var isLoading = false
    @Published private(set) var reachedEnd = false

    private let service: NotificationServiceProtocol
    private var nextAfterId: Int? = nil

    init(service: NotificationServiceProtocol) {
        self.service = service
    }

    func refresh() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let resp = try await service.list(afterId: nil, limit: 50, unread: nil)
            self.items = resp.items
            self.nextAfterId = resp.nextAfterId
            self.reachedEnd = (resp.items.isEmpty || resp.nextAfterId == nil)
            NotificationCenter.default.post(name: .refreshUnreadBadge, object: nil)
        } catch {
            print("🔔 VM.refresh error:", error)
        }
    }

    func loadMore() async {
        guard !isLoading, !reachedEnd else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let resp = try await service.list(afterId: nextAfterId, limit: 50, unread: nil)
            let existing = Set(items.map(\.id))
            let newOnes = resp.items.filter { !existing.contains($0.id) }
            self.items.append(contentsOf: newOnes)
            self.nextAfterId = resp.nextAfterId
            self.reachedEnd = (resp.items.isEmpty || resp.nextAfterId == nil)
        } catch {
            print("🔔 VM.loadMore error:", error)
        }
    }

    func markRead(_ ids: [Int]) async {
        guard !ids.isEmpty else { return }
        do {
            _ = try await service.markRead(ids: ids)
            items = items.map { n in
                ids.contains(n.id)
                    ? NotificationDTO(
                        id: n.id,
                        type: n.type,
                        title: n.title,
                        body: n.body,
                        code: n.code,
                        metadata: n.metadata,
                        isRead: true,
                        readAt: n.readAt,
                        createdAt: n.createdAt
                    ) : n
            }
            NotificationCenter.default.post(name: .refreshUnreadBadge, object: nil)
        } catch {
            print("🔔 VM.markRead error:", error)
        }
    }

    func markUnread(_ ids: [Int]) async {
        guard !ids.isEmpty else { return }
        do {
            _ = try await service.markUnread(ids: ids)
            items = items.map { n in
                ids.contains(n.id)
                    ? NotificationDTO(
                        id: n.id,
                        type: n.type,
                        title: n.title,
                        body: n.body,
                        code: n.code,
                        metadata: n.metadata,
                        isRead: false,
                        readAt: nil,
                        createdAt: n.createdAt
                    ) : n
            }
            NotificationCenter.default.post(name: .refreshUnreadBadge, object: nil)
        } catch {
            print("🔔 VM.markUnread error:", error)
        }
    }

    func delete(_ ids: [Int]) async {
        guard !ids.isEmpty else { return }
        do {
            _ = try await service.delete(ids: ids)
            items.removeAll { ids.contains($0.id) }
            NotificationCenter.default.post(name: .refreshUnreadBadge, object: nil)
        } catch {
            print("🔔 VM.delete error:", error)
        }
    }
}
