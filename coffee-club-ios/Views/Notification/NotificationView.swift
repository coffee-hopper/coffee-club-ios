import SwiftUI

struct NotificationView: View {
    @ObservedObject var vm: NotificationsViewModel
    @Environment(\.dismiss) var dismiss

    @EnvironmentObject var auth: AuthViewModel
    @Binding var isActive: Bool

    var body: some View {
        List {
            ForEach(vm.items) { n in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        if !n.isRead {
                            Circle().frame(width: 10, height: 10).foregroundColor(.accentColor)
                        }
                        Text(DateFormatting.absolute(fromISO: n.createdAt))
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        Text(n.title).font(.headline)
                    }
                    Text(n.body).font(.subheadline).foregroundColor(.secondary)

                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    if n.isRead {
                        Button("Unread") { Task { await vm.markUnread([n.id]) } }
                            .tint(.orange)
                    } else {
                        Button("Read") { Task { await vm.markRead([n.id]) } }
                            .tint(.blue)
                    }
                    Button(role: .destructive) {
                        Task { await vm.delete([n.id]) }
                    } label: {
                        Text("Delete")
                    }
                }
                .onAppear {
                    if n.id == vm.items.last?.id {
                        Task { await vm.loadMore() }
                    }
                }
            }
        }
        .navigationTitle("Notifications")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {

                Button {
                    Task {
                        await vm.markRead(vm.items.map(\.id))
                    }
                } label: {
                    Image(systemName: "eyeglasses")

                }
            }
        }
        .refreshable { await vm.refresh() }
        .task { await vm.refresh() }
    }

}
