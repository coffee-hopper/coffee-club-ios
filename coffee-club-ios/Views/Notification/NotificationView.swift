import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var isActive: Bool

    var body: some View {
        Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showNotification = true
        var body: some View {
            NotificationView(isActive: $showNotification)
                .environmentObject(AuthViewModel())
        }
    }

    return PreviewWrapper()
}
