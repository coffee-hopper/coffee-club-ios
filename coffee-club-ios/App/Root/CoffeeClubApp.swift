import SwiftUI

@main
struct CoffeeClubApp: App {
    @StateObject private var nav: NavigationCoordinator
    @StateObject private var legacyCoordinator: ViewCoordinator

    @StateObject private var auth: AuthViewModel

    private let environment: AppEnvironment

    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    init() {
        let nav = NavigationCoordinator()
        let legacy = ViewCoordinator()
        let env = AppEnvironment.makeDefault(
            apiBaseURL: URL(string: "http://localhost:3000")!,
            coordinator: legacy,
            nav: nav
        )

        _nav = StateObject(wrappedValue: nav)
        _legacyCoordinator = StateObject(wrappedValue: legacy)
        _auth = StateObject(
            wrappedValue: AuthViewModel(
                authService: env.authService,
                nav: env.nav
            )
        )

        environment = env
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoggedIn {
                    ContentView(auth: auth)
                } else {
                    LoginScreen()
                }
            }
            .environment(\.appEnvironment, environment)
            .environmentObject(auth)
            .environmentObject(nav)
            .environmentObject(legacyCoordinator)
            .preferredColorScheme(appTheme.colorScheme)
        }
    }
}
