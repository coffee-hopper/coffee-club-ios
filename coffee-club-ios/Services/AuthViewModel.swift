import Foundation
import GoogleSignIn
import KeychainAccess
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var token: String?
    @Published var isLoggedIn = false
    @Published var user: User?

    private let keychain = Keychain(service: "com.yourcompany.coffeeclub")

    var isMobileUser: Bool {
        user?.role == "user"
    }

    var isOwner: Bool {
        user?.role == "owner"
    }

    init() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let user = user {
                print("🔁 Google auto sign-in restored for: \(user.profile?.email ?? "")")
            } else {
                print("❌ Google auto sign-in failed or not available")
            }
        }

        restoreSession()
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

    func logout() {
        token = nil
        user = nil
        isLoggedIn = false
        try? keychain.removeAll()
    }
}
