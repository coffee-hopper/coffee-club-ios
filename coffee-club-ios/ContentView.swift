import SwiftUI

struct ContentView: View {
    var auth: AuthViewModel

    @StateObject private var cart = CartManager()
    @EnvironmentObject var coordinator: ViewCoordinator

    @State private var selectedCategory = "drink"
    @State private var searchText: String = ""

    @State private var isPresentingScanner = false

    @State private var createdOrderId: Int?
    @State private var createdOrderAmount: Double?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MainHeaderView(
                    showProfile: $coordinator.showProfile,
                    showNotification: $coordinator.showNotification
                )

                FooterView(
                    isPresentingScanner: $isPresentingScanner,
                    createdOrderId: $createdOrderId,
                    createdOrderAmount: $createdOrderAmount
                )
                .environmentObject(coordinator)

                VStack(spacing: 0) {
                    Spacer().frame(height: 50)

                    ScrollView(showsIndicators: false) {
                        VStack {
                            RewardView()

                            ProductView(
                                title: selectedCategory,
                                showAllBinding: $coordinator.showProductList,
                                searchText: $searchText,
                                category: $selectedCategory
                            )
                            .environmentObject(cart)
                            .padding()
                            .frame(maxWidth: .infinity)

                            Spacer().frame(height: 80)
                        }
                    }
                }
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
                    createdOrderAmount: $createdOrderAmount
                )
                .environmentObject(cart)
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
        .onChange(of: coordinator.returnToHome) {
            coordinator.resetAll()
        }
    }
}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
        .environmentObject(ViewCoordinator())
}
