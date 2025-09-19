import Combine
import SwiftUI

extension Notification.Name {
    static let refreshUnreadBadge = Notification.Name("refreshUnreadBadge")
}

struct BellButton: View {
    let service: NotificationServiceProtocol
    let onTap: () -> Void

    @State private var unreadCount: Int = 0
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .imageScale(.large)
                if unreadCount > 0 {
                    Text("\(unreadCount)")
                        .font(.caption2).padding(4)
                        .background(Circle().fill(Color.red))
                        .foregroundColor(.white)
                        .offset(x: 8, y: -8)
                }
            }
        }
        .onAppear { Task { await refreshBadge() } }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
        ) { _ in
            Task { await refreshBadge() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshUnreadBadge)) { _ in
            Task { await refreshBadge() }
        }
    }

    private func refreshBadge() async {
        do {
            let c = try await service.unreadCount()
            await MainActor.run { unreadCount = c }
        } catch {
            print("🔔 unreadCount error:", error)
        }
    }
}
