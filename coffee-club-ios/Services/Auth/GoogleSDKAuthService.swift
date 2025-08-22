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

final class GoogleSDKAuthService: AuthServiceProtocol {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func signIn() async throws -> (token: String, user: User) {
        let presenter = try Self.topViewController()

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

        let u = resp.user
        let user = User(
            id: u.id,
            name: u.username,
            role: u.role,
            picture: u.googlePicture
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
        return User(
            id: dto.id,
            name: dto.username,
            role: dto.role,
            picture: dto.googlePicture
        )
    }

    private static func topViewController(
        base: UIViewController? = {
            let scene = UIApplication.shared.connectedScenes
                .compactMap { $0 as? UIWindowScene }
                .first
            return scene?.keyWindow?.rootViewController
        }()
    ) throws -> UIViewController {
        func visible(from vc: UIViewController) -> UIViewController {
            if let nav = vc as? UINavigationController, let v = nav.visibleViewController {
                return visible(from: v)
            }
            if let tab = vc as? UITabBarController, let v = tab.selectedViewController {
                return visible(from: v)
            }
            if let presented = vc.presentedViewController { return visible(from: presented) }
            return vc
        }
        guard let base else {
            throw AppError.unknown(
                underlying: NSError(
                    domain: "Auth",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "No presenter available"]
                )
            )
        }
        return visible(from: base)
    }
}

extension UIWindowScene {
    fileprivate var keyWindow: UIWindow? { windows.first(where: { $0.isKeyWindow }) }
}
