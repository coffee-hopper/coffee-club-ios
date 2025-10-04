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
    @Published var userCachedPicturePath: String?

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

    private func prefetchUserImageIfNeeded() {
        guard let urlString = user?.picture else {
            userCachedPicturePath = nil
            return
        }

        if let cached = DiskImageCache.loadImagePathIfExists(for: urlString) {
            userCachedPicturePath = cached
            return
        }

        Task { @MainActor in
            if let path = await DiskImageCache.fetchAndCache(from: urlString) {
                self.userCachedPicturePath = path
            }
        }
    }

    @MainActor
    func signInTapped() {
        guard case .loading = state else {
            state = .loading

            Task {
                do {
                    let (jwt, user) = try await authService.signIn()
                    saveSession(token: jwt, user: user)
                    state = .authenticated(user: user, token: jwt)
                    isLoggedIn = true
                    nav.goHome()
                } catch {
                    errorMessage = ErrorMapper.message(for: error)
                    state = .error(message: errorMessage ?? "Oturum açılırken bir hata oluştu.")
                    clearSession()
                }
            }
            return
        }
    }

    @MainActor
    func signOutTapped() {
        authService.signOut()
        clearSession()
        state = .signedOut
        isLoggedIn = false
        nav.reset()
    }

    @MainActor
    private func saveSession(token: String, user: User) {
        keychain["jwt"] = token

        if let data = try? JSONEncoder().encode(user) {
            keychain["user"] = data.base64EncodedString()
        }
        self.token = token
        self.user = user
        prefetchUserImageIfNeeded()
    }

    @MainActor
    private func clearSession() {
        keychain["jwt"] = nil
        keychain["user"] = nil
        token = nil
        user = nil
    }

    @MainActor
    func restoreSession() {
        if let token = keychain["jwt"],
            let userData = keychain["user"],
            let decoded = Data(base64Encoded: userData),
            let user = try? JSONDecoder().decode(User.self, from: decoded)
        {
            self.token = token
            self.user = user
            self.isLoggedIn = true
            self.state = .authenticated(user: user, token: token)
            prefetchUserImageIfNeeded()
        } else {
            self.isLoggedIn = false
            self.state = .idle
        }
    }
}
