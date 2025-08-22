//TODO: In old GoogleAuthService's also sent mobile-auth: ios. If the backend depends on it, keep that header in the new service (as shown).

import AuthenticationServices
import Foundation
import SwiftUI

struct AuthLoginURLResponse: Decodable { let url: String }

final class APIAuthService: NSObject, AuthServiceProtocol {
    private let client: APIClient
    private let callbackScheme: String
    private var session: ASWebAuthenticationSession?

    init(client: APIClient, callbackScheme: String) {
        self.client = client
        self.callbackScheme = callbackScheme
    }

    @discardableResult
    func signIn() async throws -> (token: String, user: User) {
        let login: AuthLoginURLResponse = try await client.request(
            AuthLoginURLResponse.self,
            "/auth/google",
            method: .GET,
            headers: ["mobile-auth": "ios"]
        )

        guard let loginURL = URL(string: login.url) else {
            throw AppError.unknown(underlying: nil)
        }

        let token: String = try await withCheckedThrowingContinuation { cont in
            Task { @MainActor [weak self] in
                guard let self else {
                    cont.resume(throwing: AppError.unknown(underlying: nil))
                    return
                }

                let session = ASWebAuthenticationSession(
                    url: loginURL,
                    callbackURLScheme: self.callbackScheme
                ) { callbackURL, error in
                    Task { @MainActor [weak self] in
                        defer { self?.session = nil }

                        if let error {
                            cont.resume(throwing: error)
                            return
                        }

                        guard let callbackURL,
                            let comps = URLComponents(
                                url: callbackURL,
                                resolvingAgainstBaseURL: false
                            ),
                            let token = comps.queryItems?.first(where: { $0.name == "token" })?
                                .value
                        else {
                            cont.resume(throwing: AppError.unknown(underlying: nil))
                            return
                        }

                        cont.resume(returning: token)
                    }
                }

                session.presentationContextProvider = self
                self.session = session
                _ = session.start()
            }
        }

        let user = try await fetchProfile(token: token)
        return (token, user)
    }

    func fetchProfile(token: String) async throws -> User {
        try await client.request(User.self, "/auth/profile", method: .GET, token: token)
    }
}

// MARK: - ASWebAuthenticationPresentationContextProviding
extension APIAuthService: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {

        #if canImport(UIKit)
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let wnd = scene.keyWindow
            {
                return wnd
            }
            return UIApplication.shared.windows.first ?? ASPresentationAnchor()
        #else
            return ASPresentationAnchor()
        #endif
    }
}

#if canImport(UIKit)
    extension UIWindowScene {
        fileprivate var keyWindow: UIWindow? { windows.first { $0.isKeyWindow } }
    }
#endif
