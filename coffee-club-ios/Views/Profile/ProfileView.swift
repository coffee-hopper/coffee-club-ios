import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var isActive: Bool

    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @Environment(\.colorScheme) private var systemColorScheme

    @State private var showLogoutConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
                        .foregroundColor(Color("Secondary"))
                }

                Text(auth.user?.name ?? "Guest")
                    .font(.headline)
                Text(auth.user?.role ?? "role")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)

            List {
                Section {
                    Label("Personal Info", systemImage: "person")
                    Label("Preferences", systemImage: "slider.horizontal.3")

                    HStack {
                        Label("Language", systemImage: "globe")
                        Spacer()
                        Text(Locale.current.identifier)
                            .foregroundColor(Color("TextSecondary"))
                    }

                    HStack {
                        Label("AppTheme", systemImage: "paintbrush")
                        Spacer()

                        Menu {
                            ForEach(AppTheme.allCases) { theme in
                                Button {
                                    appTheme = theme
                                } label: {
                                    Label(theme.displayName, systemImage: theme.iconName)
                                }
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text(appTheme.displayName)
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                            }
                            .foregroundColor(.primary)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.gray.opacity(0.1))
                            )
                        }
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
                    .foregroundColor(Color("AccentRed"))
                }
            }
            .confirmationDialog(
                "Are you sure you want to log out?",
                isPresented: $showLogoutConfirmation,
                titleVisibility: .visible
            ) {
                Button("Log Out", role: .destructive) {
                    auth.signOutTapped()
                    print("🔓 Logged out")
                }
                Button("Cancel", role: .cancel) {}
            }
        }
        .navigationTitle("Hi, \(auth.user?.name ?? "Guest")!")
    }
}


