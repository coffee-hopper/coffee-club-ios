import Foundation

protocol TokenProviding { var token: String? { get } }

struct AppEnvironment {
    let authService: AuthServiceProtocol
    let productService: ProductServiceProtocol
    let orderService: OrderServiceProtocol
    let paymentService: PaymentServiceProtocol
    let loyaltyService: LoyaltyServiceProtocol
    let coordinator: ViewCoordinator
    let tokenProvider: TokenProviding?
}

extension AppEnvironment {
    static func makeDefault(apiBaseURL: URL,
                            coordinator: ViewCoordinator,
                            tokenProvider: TokenProviding? = nil) -> AppEnvironment {
        let client = APIClient(baseURL: apiBaseURL)

        return AppEnvironment(
            authService: APIAuthService(client: client, callbackScheme: "coffeeclub"),
            productService: APIProductService(client: client),
            orderService: APIOrderService(client: client),
            paymentService: APIPaymentService(client: client),
            loyaltyService: APILoyaltyService(client: client),
            coordinator: coordinator,
            tokenProvider: tokenProvider
        )
    }
}
