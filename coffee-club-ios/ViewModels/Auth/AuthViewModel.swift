import Foundation
import KeychainAccess
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject, TokenProviding {

    @Published var token: String?
    @Published var isLoggedIn = false
    @Published var user: User?
    @Published var state: AuthState = .idle
    @Published var errorMessage: String?

    private let keychain = Keychain(service: "com.yourcompany.coffeeclub")
    private let authService: AuthServiceProtocol
    private let nav: NavigationCoordinator

    var isMobileUser: Bool { user?.role == "user" }
    var isOwner: Bool { user?.role == "owner" }

    init(authService: AuthServiceProtocol, nav: NavigationCoordinator) {
        self.authService = authService
        self.nav = nav
        restoreSession()
    }

    func signInTapped() {
        state = .loading
        Task {
            do {
                let (token, user) = try await authService.signIn()
                storeSession(token: token, user: user)
                state = .authenticated(user: user, token: token)
                nav.goHome()
            } catch {
                let message = ErrorMapper.message(for: error)
                errorMessage = message
                state = .error(message: message)
            }
        }
    }

    func logout() {
        token = nil
        user = nil
        isLoggedIn = false
        state = .signedOut
        try? keychain.removeAll()
    }

    func storeSession(token: String, user: User) {
        self.token = token
        self.user = user
        self.isLoggedIn = true

        keychain["jwt"] = token
        if let encoded = try? JSONEncoder().encode(user) {
            keychain["user"] = encoded.base64EncodedString()
        }
    }

    func restoreSession() {
        if let token = keychain["jwt"],
            let userData = keychain["user"],
            let decoded = Data(base64Encoded: userData),
            let user = try? JSONDecoder().decode(User.self, from: decoded)
        {
            self.token = token
            self.user = user
            self.isLoggedIn = true
            print("✅ Session restored from Keychain")
        } else {
            print("ℹ️ No saved session found")
        }
    }
}
