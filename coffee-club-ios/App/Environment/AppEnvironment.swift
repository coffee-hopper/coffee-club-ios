import Foundation
import SwiftUI

// MARK: - Token access for services that need JWT
@MainActor
protocol TokenProviding: AnyObject {
    var token: String? { get }
}

// MARK: - Environment container
struct AppEnvironment {
    let authService: AuthServiceProtocol
    let productService: ProductServiceProtocol
    let orderService: OrderServiceProtocol
    let paymentService: PaymentServiceProtocol
    let loyaltyService: LoyaltyServiceProtocol
    let notificationService: NotificationServiceProtocol

    let nav: NavigationCoordinator

    let tokenProvider: TokenProviding?
}

extension AppEnvironment {
    @MainActor
    static func makeDefault(
        apiBaseURL: URL,
        nav: NavigationCoordinator,
        tokenProvider: TokenProviding? = nil
    ) -> AppEnvironment {
        let client = APIClient(baseURL: apiBaseURL)

        return AppEnvironment(
            authService: APIAuthService(client: client),
            productService: APIProductService(client: client),
            orderService: APIOrderService(client: client),
            paymentService: APIPaymentService(client: client),
            loyaltyService: APILoyaltyService(client: client),
            notificationService: APINotificationService(
                client: client,
                tokenProvider: tokenProvider
            ),
            nav: nav,
            tokenProvider: tokenProvider
        )
    }

    @MainActor
    static var preview: AppEnvironment {
        let nav = NavigationCoordinator()
        return .makeDefault(
            apiBaseURL: URL(string: "http://localhost:3000")!,
            nav: nav,
            tokenProvider: nil
        )
    }
}

// MARK: - SwiftUI Environment key
private struct AppEnvironmentKey: EnvironmentKey {
    @MainActor
    static var defaultValue: AppEnvironment { .preview }
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
