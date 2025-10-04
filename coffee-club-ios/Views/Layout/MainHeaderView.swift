import SwiftUI

struct MainHeaderView: View {
    @EnvironmentObject var auth: AuthViewModel

    @Binding var showProfile: Bool
    @Binding var showNotification: Bool

    let notificationService: NotificationServiceProtocol

    var body: some View {

        HStack {
            Button(action: { showProfile = true }) {
                if let path = auth.userCachedPicturePath,
                    let ui = UIImage(contentsOfFile: path)
                {
                    Image(uiImage: ui)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else if let pictureURL = auth.user?.picture,
                    let url = URL(string: pictureURL)
                {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable().frame(width: 40, height: 40).foregroundColor(
                                    .secondary
                                )
                        case .success(let image):
                            image.resizable()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        case .failure(_):
                            Image(systemName: "person.crop.circle.fill")
                                .resizable().frame(width: 40, height: 40).foregroundColor(
                                    .secondary
                                )
                        @unknown default:
                            Image(systemName: "person.crop.circle.fill")
                                .resizable().frame(width: 40, height: 40).foregroundColor(
                                    .secondary
                                )
                        }
                    }
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable().frame(width: 40, height: 40).foregroundColor(.secondary)
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
