//TODO: look AppEnvironment ok for now part- remove later ?
//TODO: After Each payment transaction product list must be refetch so quantities updated.
//TODO: Look for the part of Optional: after returning home, trigger product refresh (post-payment)

import SwiftUI

struct ContentView: View {
    var auth: AuthViewModel

    @EnvironmentObject private var nav: NavigationCoordinator
    @Environment(\.appEnvironment) private var environment

    @StateObject private var cart = CartStoreManager()
    @StateObject private var selection = ProductSelection()

    @State private var isSearchFocused: Bool = false
    @State private var searchTapShield: Bool = false
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

                    // LOYALTY
                    LoyaltyView()
                        .frame(height: geo.size.height * 0.25)

                    // PRODUCTS
                    ProductView(
                        isSearchFocused: $isSearchFocused,
                        searchText: $searchText,
                        category: $selectedCategory,
                        searchTapShield: $searchTapShield,
                        title: selectedCategory,
                        heightUnit: geo.size.height * 0.60
                    )
                    .environmentObject(cart)
                    .environmentObject(auth)
                    .environmentObject(selection)
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
                ///SearchBar close Trigger overlay
                .overlay {
                    if isSearchFocused {
                        Color.black
                            .opacity(0.085)
                            .ignoresSafeArea()
                            .allowsHitTesting(false)
                            .transition(.opacity)
                            .zIndex(9999)
                    }
                }
                .simultaneousGesture(
                    TapGesture().onEnded {
                        defer { searchTapShield = false }
                        if searchTapShield { return }
                        if isSearchFocused {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                isSearchFocused = false
                            }
                        }
                    }
                )

            }

            // MARK: ===== DESTINATIONS =====

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
                .environmentObject(cart)
            }

            // Product Detail
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

        //TODO: after returning home, trigger product refresh (post-payment)
        .onChange(of: nav.route) { _, newRoute in
            if case .home = newRoute {
                // Task { await productsVM.refetch() }
            }
        }
    }
}
