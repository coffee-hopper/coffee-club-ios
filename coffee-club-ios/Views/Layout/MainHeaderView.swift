import SwiftUI

struct MainHeaderView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var showProfile: Bool
    @Binding var showNotification: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Spacer()
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

                    IconButton(
                        systemName: "bell.fill",
                        action: {
                            showNotification = true
                            print("Notifications_tapped")
                        },
                        isFilled: false,
                        iconSize: 28
                    )
                }

                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .frame(height: 150)
        .ignoresSafeArea(edges: .top)
    }

}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
}
