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
            GeometryReader { geo in
                VStack(alignment: .leading) {
                    MainHeaderView(
                        showProfile: $coordinator.showProfile,
                        showNotification: $coordinator.showNotification
                    )
                    .frame(height: geo.size.height * 0.075)

                    RewardView()
                        .frame(height: geo.size.height * 0.25)

                    ProductView(
                        title: selectedCategory,
                        showAllBinding: $coordinator.showProductList,
                        searchText: $searchText,
                        category: $selectedCategory,
                        heightUnit: geo.size.height * 0.55
                    )
                    .environmentObject(cart)
                    .frame(height: geo.size.height * 0.52)

                    Spacer()
                    
                    FooterView(
                        isPresentingScanner: $isPresentingScanner,
                        createdOrderId: $createdOrderId,
                        createdOrderAmount: $createdOrderAmount
                    )
                    .environmentObject(coordinator)
                    .frame(height: geo.size.height * 0.1)
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
