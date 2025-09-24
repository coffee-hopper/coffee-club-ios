import GoogleSignIn
import SwiftUI
import os.log

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        let handled = GIDSignIn.sharedInstance.handle(url)
        Logger(subsystem: "app.coffeeclub", category: "Auth")
            .info("openURL: \(url.scheme ?? "nil") → handled=\(handled)")
        return handled
    }
}

@main
struct CoffeeClubApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject private var nav: NavigationCoordinator

    @StateObject private var auth: AuthViewModel

    private let environment: AppEnvironment

    @AppStorage("appTheme") private var appTheme: AppTheme = .system

    init() {
        configureGoogle()

        let nav = NavigationCoordinator()
        let env = AppEnvironment.makeDefault(
            apiBaseURL: URL(string: "http://localhost:3000")!,
            nav: nav
        )

        _nav = StateObject(wrappedValue: nav)
        _auth = StateObject(
            wrappedValue: AuthViewModel(
                authService: env.authService,
                nav: env.nav,
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
            .preferredColorScheme(appTheme.colorScheme)
        }
    }
}

private func configureGoogle() {
    // Try GoogleService-Info.plist first
    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
        let dict = NSDictionary(contentsOfFile: path),
        let clientID = dict["CLIENT_ID"] as? String
    {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        return
    }

    // Fallback: Info.plist key `GIDClientID`
    if let clientID = Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String {
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        return
    }

}
