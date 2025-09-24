////TODO: look AppEnvironment ok for now part- remove later ?
////TODO: After Each payment transaction product list must be refetch so quantities updated.
//
//import SwiftUI
//
//struct ContentView: View {
//    var auth: AuthViewModel
//
//    // Legacy is still injected at app root, but we don't rely on it for navigation anymore
//    @EnvironmentObject var coordinator: ViewCoordinator
//
//    @EnvironmentObject var nav: NavigationCoordinator
//
//    @StateObject private var cart = CartStoreManager()
//
//    @State private var selectedCategory = "coffee"
//    @State private var searchText: String = ""
//
//    @State private var isPresentingScanner = false
//    @State private var navigateToPayment = false
//
//    @State private var createdOrderId: Int?
//    @State private var createdOrderAmount: Decimal?
//
//    // LOOK : Simple computed env
//    private var environment: AppEnvironment {
//        AppEnvironment.makeDefault(
//            apiBaseURL: URL(string: API.baseURL)!,
//            coordinator: coordinator,
//            nav: nav,
//            tokenProvider: auth
//        )
//    }
//
//    var body: some View {
//        NavigationStack {
//            GeometryReader { geo in
//                VStack(alignment: .leading, spacing: 0) {
//                    MainHeaderView(
//                        showProfile: $coordinator.showProfile,
//                        showNotification: $coordinator.showNotification,
//                        notificationService: environment.notificationService
//                    )
//                    .frame(height: geo.size.height * 0.075)
//
//                    RewardView()
//                        .frame(height: geo.size.height * 0.25)
//
//                    ProductView(
//                        searchText: $searchText,
//                        category: $selectedCategory,
//                        title: selectedCategory,
//                        heightUnit: geo.size.height * 0.60,
//                    )
//                    .environmentObject(cart)
//                    .environmentObject(auth)
//                    .frame(height: geo.size.height * 0.60)
//
//                    FooterView(
//                        isPresentingScanner: $isPresentingScanner,
//                        navigateToPayment: .init(
//                            get: { coordinator.navigateToPayment },
//                            set: { coordinator.navigateToPayment = $0 }
//                        ),
//                        createdOrderId: $createdOrderId,
//                        createdOrderAmount: $createdOrderAmount,
//                        productService: environment.productService,
//                        orderService: environment.orderService,
//                        tokenProvider: environment.tokenProvider
//                    )
//                    .environmentObject(coordinator)
//                    .frame(height: geo.size.height * 0.075)
//                }
//                .frame(width: geo.size.width, height: geo.size.height)
//            }
//
//            .navigationDestination(isPresented: $coordinator.showProductList) {
//                ProductListView(
//                    isActive: $coordinator.showProductList,
//                    category: selectedCategory
//                )
//                .environmentObject(auth)
//            }
//
//            .navigationDestination(isPresented: $coordinator.showProfile) {
//                ProfileView(isActive: $coordinator.showProfile)
//                    .environmentObject(auth)
//            }
//
//            .navigationDestination(isPresented: $coordinator.showNotification) {
//                NotificationView(
//                    vm: NotificationsViewModel(service: environment.notificationService),
//                    isActive: $coordinator.showNotification
//                )
//                .environmentObject(auth)
//            }
//
//            .navigationDestination(isPresented: $coordinator.navigateToPayment) {
//                if let id = createdOrderId, let amount = createdOrderAmount {
//                    PaymentView(
//                        orderId: id,
//                        totalAmount: amount,
//                        returnToHome: $coordinator.returnToHome
//                    )
//                    .environmentObject(cart)
//                } else {
//                    EmptyView()
//                }
//            }
//
//            .navigationDestination(isPresented: $coordinator.showCart) {
//                CartView(
//                    returnToHome: $coordinator.returnToHome,
//                    navigateToPayment: $coordinator.navigateToPayment,
//                    showCartView: $coordinator.showCart,
//                    createdOrderId: $createdOrderId,
//                    createdOrderAmount: $createdOrderAmount,
//                    orderService: environment.orderService,
//                    tokenProvider: environment.tokenProvider,
//                    store: cart,
//                    productService: environment.productService
//                )
//                .environmentObject(auth)
//            }
//
//            .navigationDestination(isPresented: $coordinator.showProductDetail) {
//                if let product = coordinator.selectedProduct {
//                    ProductDetailView(product: product)
//                        .environmentObject(cart)
//                } else {
//                    EmptyView()
//                }
//            }
//        }
//        .environmentObject(cart)
//        .environment(\.appEnvironment, environment)
//
//        .onChange(of: coordinator.returnToHome) {
//            coordinator.resetAll()
//        }
//    }
//}

import SwiftUI

struct ContentView: View {
    var auth: AuthViewModel

    @EnvironmentObject private var nav: NavigationCoordinator
    @Environment(\.appEnvironment) private var environment

    @StateObject private var cart = CartStoreManager()
    @StateObject private var selection = ProductSelection()

    @State private var selectedCategory: String = "coffee"
    @State private var searchText: String = ""

    // QR
    @State private var isPresentingScanner = false

    // Footer → Payment bridge
    @State private var footerRequestsNavigatePayment = false
    @State private var createdOrderId: Int?
    @State private var createdOrderAmount: Decimal?

    // Payment → Home bridge
    @State private var closePaymentAndGoHome = false

    // Local environment (services) using the current nav/auth
    private var localEnv: AppEnvironment {
        AppEnvironment.makeDefault(
            apiBaseURL: URL(string: API.baseURL)!,
            nav: nav,
            tokenProvider: auth
        )
    }

    // MARK: Local bindings to adapt existing screens to routes

    private var returnToHomeBinding: Binding<Bool> {
        Binding(
            get: { false },
            set: { newValue in if newValue { nav.reset() } }
        )
    }

    private var navigateToPaymentBinding: Binding<Bool> {
        Binding(
            get: { if case .payment = nav.route { return true } else { return false } },
            set: { newValue in
                if newValue {
                    guard let id = createdOrderId else { return }
                    nav.openPayment(orderID: id, total: createdOrderAmount)
                } else {
                    if case .payment = nav.route { nav.reset() }
                }
            }
        )
    }

    private var showCartBinding: Binding<Bool> {
        Binding(
            get: { if case .cart = nav.route { return true } else { return false } },
            set: { newValue in
                if newValue { nav.openCart() } else if case .cart = nav.route { nav.reset() }
            }
        )
    }

    private var showProductListBinding: Binding<Bool> {
        Binding(
            get: { if case .productList = nav.route { return true } else { return false } },
            set: { newValue in
                if newValue {
                    nav.openProductList(category: selectedCategory)
                } else if case .productList = nav.route {
                    nav.reset()
                }
            }
        )
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack(alignment: .leading, spacing: 0) {

                    // HEADER
                    MainHeaderView(
                        showProfile: nav.isProfileActive,
                        showNotification: nav.isNotificationsActive,
                        notificationService: localEnv.notificationService
                    )
                    .frame(height: geo.size.height * 0.075)

                    // REWARDS
                    RewardView()
                        .frame(height: geo.size.height * 0.25)

                    // PRODUCTS (inject selection so taps can snapshot+route)
                    ProductView(
                        searchText: $searchText,
                        category: $selectedCategory,
                        title: selectedCategory,
                        heightUnit: geo.size.height * 0.60
                    )
                    .environmentObject(cart)
                    .environmentObject(auth)
                    .environmentObject(selection)  // <— important: snapshot service
                    .frame(height: geo.size.height * 0.60)

                    // FOOTER
                    FooterView(
                        isPresentingScanner: $isPresentingScanner,
                        navigateToPayment: $footerRequestsNavigatePayment,
                        createdOrderId: $createdOrderId,
                        createdOrderAmount: $createdOrderAmount,
                        productService: localEnv.productService,
                        orderService: localEnv.orderService,
                        tokenProvider: localEnv.tokenProvider
                    )
                    .frame(height: geo.size.height * 0.075)
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }

            // ===== DESTINATIONS (purely from nav.route) =====

            // Product List
            .navigationDestination(isPresented: showProductListBinding) {
                let categoryForRoute: String = {
                    if case let .productList(c) = nav.route { return c }
                    return selectedCategory
                }()

                ProductListView(
                    isActive: showProductListBinding,
                    category: categoryForRoute
                )
                .environmentObject(auth)
                .environmentObject(selection)
            }

            // Profile
            .navigationDestination(isPresented: nav.isProfileActive) {
                ProfileView(isActive: nav.isProfileActive)
                    .environmentObject(auth)
            }

            // Notifications
            .navigationDestination(isPresented: nav.isNotificationsActive) {
                NotificationView(
                    vm: NotificationsViewModel(service: localEnv.notificationService),
                    isActive: nav.isNotificationsActive
                )
                .environmentObject(auth)
            }

            // Cart
            .navigationDestination(isPresented: showCartBinding) {
                CartView(
                    returnToHome: returnToHomeBinding,
                    navigateToPayment: navigateToPaymentBinding,
                    showCartView: showCartBinding,
                    createdOrderId: $createdOrderId,
                    createdOrderAmount: $createdOrderAmount,
                    orderService: localEnv.orderService,
                    tokenProvider: localEnv.tokenProvider,
                    store: cart,
                    productService: localEnv.productService
                )
                .environmentObject(auth)
            }

            // Product Detail (snapshot → instant UI, then refresh)
            .navigationDestination(
                isPresented: Binding(
                    get: {
                        if case .productDetail = nav.route { return true } else { return false }
                    },
                    set: { newValue in
                        if !newValue, case .productDetail = nav.route { nav.reset() }
                    }
                )
            ) {
                if case let .productDetail(id) = nav.route {
                    ProductDetailView(productID: id)
                        .environmentObject(selection) 
                        .environmentObject(cart)
                } else {
                    EmptyView()
                }
            }

            // Payment
            .navigationDestination(
                isPresented: Binding(
                    get: { if case .payment = nav.route { return true } else { return false } },
                    set: { newValue in
                        if !newValue, case .payment = nav.route { nav.reset() }
                    }
                )
            ) {
                if case let .payment(orderID, total) = nav.route {
                    PaymentView(
                        orderId: orderID,
                        totalAmount: total ?? 0,
                        returnToHome: $closePaymentAndGoHome
                    )
                    .environmentObject(cart)
                } else {
                    EmptyView()
                }
            }
        }
        .environment(\.appEnvironment, localEnv)

        // Footer → Payment
        .onChange(of: footerRequestsNavigatePayment) { _, wantsNavigate in
            guard wantsNavigate, let id = createdOrderId else { return }
            nav.openPayment(orderID: id, total: createdOrderAmount)
            footerRequestsNavigatePayment = false
        }

        // Payment → Home
        .onChange(of: closePaymentAndGoHome) { _, goHome in
            if goHome {
                nav.reset()
                closePaymentAndGoHome = false
            }
        }

        // Optional: after returning home, trigger product refresh (post-payment)
        .onChange(of: nav.route) { _, newRoute in
            if case .home = newRoute {
                // Task { await productsVM.refetch() }
            }
        }
    }
}
