// TEMP :  For now `nav` has a default value so existing call-sites compile. 'll replace this with the **root-injected** instance in the next step.

import Foundation

protocol TokenProviding { var token: String? { get } }

struct AppEnvironment {
    let authService: AuthServiceProtocol
    let productService: ProductServiceProtocol
    let orderService: OrderServiceProtocol
    let paymentService: PaymentServiceProtocol
    let loyaltyService: LoyaltyServiceProtocol
    
    let coordinator: ViewCoordinator
    
    let nav: NavigationCoordinator
    
    let tokenProvider: TokenProviding?
}

extension AppEnvironment {
    static func makeDefault(apiBaseURL: URL,
                            coordinator: ViewCoordinator,
                            nav: NavigationCoordinator,
                            tokenProvider: TokenProviding? = nil) -> AppEnvironment {
        let client = APIClient(baseURL: apiBaseURL)

        return AppEnvironment(
            authService: APIAuthService(client: client, callbackScheme: "coffeeclub"),
            productService: APIProductService(client: client),
            orderService: APIOrderService(client: client),
            paymentService: APIPaymentService(client: client),
            loyaltyService: APILoyaltyService(client: client),
            coordinator: coordinator,
            nav: nav,
            tokenProvider: tokenProvider
        )
    }
}
