import GoogleSignIn
import SwiftUI

@main
struct coffee_club_iosApp: App {
    @StateObject private var auth = AuthViewModel()
    @StateObject private var cart = CartManager()
    @StateObject private var coordinator = ViewCoordinator()

    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoggedIn {
                    ContentView(auth: auth)
                        .environmentObject(auth)
                        .environmentObject(cart)
                        .environmentObject(coordinator)
                } else {
                    LoginScreen()
                        .environmentObject(auth)
                }
            }
            .preferredColorScheme(appTheme.colorScheme)
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
