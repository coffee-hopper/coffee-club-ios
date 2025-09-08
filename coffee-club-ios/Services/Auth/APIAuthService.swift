import Foundation
import GoogleSignIn
import UIKit

struct MobileAuthRequest: Encodable { let token: String }

struct MobileAuthUserDTO: Decodable {
    let id: Int
    let username: String
    let role: String
    let googlePicture: String?
}

struct MobileAuthResponse: Decodable {
    let token: String
    let user: MobileAuthUserDTO
}

final class APIAuthService: AuthServiceProtocol {
    private let client: APIClient
    @MainActor private static var signInInFlight = false

    init(client: APIClient) { self.client = client }

    @MainActor
    func signIn() async throws -> (token: String, user: User) {
        let presenter = try Self.topPresenter()

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AppError.unknown(
                underlying: NSError(
                    domain: "Auth",
                    code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Missing Google ID token"]
                )
            )
        }

        let resp: MobileAuthResponse = try await client.request(
            MobileAuthResponse.self,
            "/auth/google/mobile",
            method: .POST,
            headers: [
                "mobile-auth": "ios",
                "Content-Type": "application/json",
            ],
            body: MobileAuthRequest(token: idToken)
        )

        let user = User(
            id: resp.user.id,
            name: resp.user.username,
            role: resp.user.role,
            picture: resp.user.googlePicture
        )

        return (resp.token, user)
    }

    func fetchProfile(token: String) async throws -> User {
        let dto = try await client.request(
            MobileAuthUserDTO.self,
            "/auth/profile",
            method: .GET,
            token: token
        )
        return User(id: dto.id, name: dto.username, role: dto.role, picture: dto.googlePicture)
    }

    @MainActor
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
    }
}

extension APIAuthService {
    @MainActor
    fileprivate static func topPresenter() throws -> UIViewController {
        guard
            let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
            let root = scene.keyWindow?.rootViewController
        else {
            throw AppError.unknown(
                underlying: NSError(
                    domain: "UI",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "No presenter available"]
                )
            )
        }
        let top = root.topMost()

        return top
    }
}

extension UIViewController {
    fileprivate func topMost() -> UIViewController {
        if let presented = presentedViewController { return presented.topMost() }
        if let nav = self as? UINavigationController, let visible = nav.visibleViewController {
            return visible.topMost()
        }
        if let tab = self as? UITabBarController, let selected = tab.selectedViewController {
            return selected.topMost()
        }
        return self
    }
}

extension UIWindowScene {
    fileprivate var keyWindow: UIWindow? { windows.first { $0.isKeyWindow } }
}
