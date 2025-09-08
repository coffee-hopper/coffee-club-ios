//TODO: look AppEnvironment ok for now part- remove later ?
//TODO: After Each payment transaction product list must be refetch so quantities updated.

import SwiftUI

struct ContentView: View {
    var auth: AuthViewModel

    @EnvironmentObject var coordinator: ViewCoordinator
    @EnvironmentObject var nav: NavigationCoordinator

    @StateObject private var cart = CartManager()

    @State private var selectedCategory = "coffee"
    @State private var searchText: String = ""

    @State private var isPresentingScanner = false
    @State private var navigateToPayment = false

    @State private var createdOrderId: Int?
    @State private var createdOrderAmount: Decimal?

    // LOOK : Simple computed env
    private var environment: AppEnvironment {
        AppEnvironment.makeDefault(
            apiBaseURL: URL(string: API.baseURL)!,
            coordinator: coordinator,
            nav: nav,
            tokenProvider: auth
        )
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {
                    MainHeaderView(
                        showProfile: $coordinator.showProfile,
                        showNotification: $coordinator.showNotification
                    )
                    .frame(height: geo.size.height * 0.075)

                    RewardView()
                        .frame(height: geo.size.height * 0.25)

                    ProductView(
                        searchText: $searchText,
                        category: $selectedCategory,
                        title: selectedCategory,
                        heightUnit: geo.size.height * 0.60,
                    )
                    .environmentObject(cart)
                    .environmentObject(auth)
                    .frame(height: geo.size.height * 0.60)

                    FooterView(
                        isPresentingScanner: $isPresentingScanner,
                        navigateToPayment: .init(
                            get: { coordinator.navigateToPayment },
                            set: { coordinator.navigateToPayment = $0 }
                        ),
                        createdOrderId: $createdOrderId,
                        createdOrderAmount: $createdOrderAmount,
                        productService: environment.productService,
                        orderService: environment.orderService,
                        tokenProvider: environment.tokenProvider
                    )
                    .environmentObject(coordinator)
                    .frame(height: geo.size.height * 0.075)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }

            .navigationDestination(isPresented: $coordinator.showProductList) {
                ProductListView(
                    isActive: $coordinator.showProductList,
                    category: selectedCategory
                )
                .environmentObject(auth)
            }

            .navigationDestination(isPresented: $coordinator.showProfile) {
                ProfileView(isActive: $coordinator.showProfile)
                    .environmentObject(auth)
            }

            .navigationDestination(isPresented: $coordinator.showNotification) {
                NotificationView(isActive: $coordinator.showNotification)
                    .environmentObject(auth)
            }

            .navigationDestination(isPresented: $coordinator.navigateToPayment) {
                if let id = createdOrderId, let amount = createdOrderAmount {
                    PaymentView(
                        orderId: id,
                        totalAmount: amount,
                        returnToHome: $coordinator.returnToHome
                    )
                    .environmentObject(cart)
                } else {
                    EmptyView()
                }
            }

            .navigationDestination(isPresented: $coordinator.showCart) {
                CartView(
                    returnToHome: $coordinator.returnToHome,
                    navigateToPayment: $coordinator.navigateToPayment,
                    showCartView: $coordinator.showCart,
                    createdOrderId: $createdOrderId,
                    createdOrderAmount: $createdOrderAmount,
                    orderService: environment.orderService,  // TEMP
                    tokenProvider: environment.tokenProvider  // TEMP

                )
                .environmentObject(cart)
                .environmentObject(auth)  // TEMP
            }

            .navigationDestination(isPresented: $coordinator.showProductDetail) {
                if let product = coordinator.selectedProduct {
                    ProductDetailView(product: product)
                        .environmentObject(cart)
                } else {
                    EmptyView()
                }
            }
        }
        .environment(\.appEnvironment, environment)

        .onChange(of: coordinator.returnToHome) {
            coordinator.resetAll()
        }
    }
}
