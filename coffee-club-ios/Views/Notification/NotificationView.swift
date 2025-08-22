import SwiftUI

struct NotificationView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var isActive: Bool

    var body: some View {
        Text( /*@START_MENU_TOKEN@*/"Hello, World!" /*@END_MENU_TOKEN@*/)
    }
}

