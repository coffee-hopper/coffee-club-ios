import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var isActive: Bool

    @State private var showLogoutConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // MARK: Header
            HStack {
                Button(action: {
                    isActive = false
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3.weight(.medium))
                        .padding(8)
                        .background(Color.gray.opacity(0.15))
                        .clipShape(Circle())
                }

                Text("Hi, \(auth.user?.name ?? "guest")!")
                    .font(.title2.bold())
                    .padding(.leading, 4)

                Spacer()
            }
            .padding(.horizontal)

            // MARK: Profile Info
            VStack(spacing: 8) {
                if let urlString = auth.user?.picture,
                    let url = URL(string: urlString)
                {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.gray)
                }

                Text(auth.user?.name ?? "Guest")
                    .font(.headline)

                Text("☕ Free filter coffees: 2")
                    .font(.subheadline.bold())
                    .padding(.top, 20)

                VStack {
                    Text("3 / 5 to next free one")
                        .font(.caption)
                        .foregroundColor(.gray)

                    ProgressView(value: 3, total: 5)
                        .progressViewStyle(LinearProgressViewStyle(tint: .brown))
                        .padding(.horizontal, 80)
                }
                .padding(.vertical, 10)

            }

            // MARK: Settings List
            List {
                Section {
                    Label("Personal Info", systemImage: "person")
                    Label("Preferences", systemImage: "slider.horizontal.3")
                }

                Section {
                    HStack {
                        Label("Language", systemImage: "globe")
                        Spacer()
                        Text(Locale.current.identifier)
                            .foregroundColor(.gray)
                    }

                    Toggle(isOn: .constant(false)) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }

                Section {
                    Label("About CoffeeHopper", systemImage: "info.circle")
                }

                Section {
                    Button {
                        showLogoutConfirmation = true
                    } label: {
                        Label("Logout", systemImage: "arrow.backward.circle")
                    }
                    .foregroundColor(.red)
                }
            }
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    auth.logout()
                    print("🔓 Logged out")
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var showProfile = true
        var body: some View {
            ProfileView(isActive: $showProfile)
                .environmentObject(AuthViewModel())
        }
    }

    return PreviewWrapper()
}
