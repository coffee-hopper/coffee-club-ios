import SwiftUI

struct FooterView: View {
    @EnvironmentObject var nav: NavigationCoordinator
    
    @Binding var isPresentingScanner: Bool
    @Binding var navigateToPayment: Bool
    @Binding var createdOrderId: Int?
    @Binding var createdOrderAmount: Decimal?
    
    let productService: ProductServiceProtocol
    let orderService: OrderServiceProtocol
    let tokenProvider: TokenProviding?

    var body: some View {
        HStack {
            Spacer()

            IconButton(systemName: "heart.fill") {
                print("Favorites tapped")
            }

            Spacer()

            QRScanner(
                isPresentingScanner: $isPresentingScanner,
                navigateToPayment: $navigateToPayment,
                createdOrderId: $createdOrderId,
                createdOrderAmount: $createdOrderAmount,
                productService: productService,
                orderService: orderService,
                tokenProvider: tokenProvider
            )

            Spacer()

            IconButton(systemName: "cart.fill") {
                nav.openCart()
            }

            Spacer()
        }
        .zIndex(2)
        .ignoresSafeArea(edges: .bottom)
    }
}

