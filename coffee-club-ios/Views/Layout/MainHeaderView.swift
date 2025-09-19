import SwiftUI

struct MainHeaderView: View {
    @EnvironmentObject var auth: AuthViewModel

    @Binding var showProfile: Bool
    @Binding var showNotification: Bool

    let notificationService: NotificationServiceProtocol

    var body: some View {

        HStack {
            Button(action: {
                showProfile = true
            }) {
                if let pictureURL = auth.user?.picture, let url = URL(string: pictureURL) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                } else {
                    IconButton(
                        systemName: "person.crop.circle.fill",
                        action: {
                            print("Profile_tapped")
                        },
                        isFilled: false
                    )
                }
            }

            Spacer()

            BellButton(service: notificationService) {
                showNotification = true
            }
        }
        .padding(.horizontal, 20)
    }

}
