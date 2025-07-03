import SwiftUI

struct ContentView: View {
    var auth: AuthViewModel

    @StateObject private var cart = CartManager()

    @State private var showProfile = false
    @State private var showNotification = false
    @State private var showProductListView = false
    @State private var selectedCategory = "drink"
    @State private var searchText: String = ""
    @State private var showCartView = false
    @State private var returnToHome = false

    @State private var isPresentingScanner = false
    @State private var navigateToPayment = false
    @State private var createdOrderId: Int?
    @State private var createdOrderAmount: Double?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                MainHeaderView(showProfile: $showProfile, showNotification: $showNotification)
                FooterView(
                    isPresentingScanner: $isPresentingScanner,
                    navigateToPayment: $navigateToPayment,
                    createdOrderId: $createdOrderId,
                    createdOrderAmount: $createdOrderAmount,
                    showCartView: $showCartView
                )

                VStack(spacing: 0) {
                    Spacer().frame(height: 50)

                    ScrollView(showsIndicators: false) {
                        VStack {
                            RewardView()

                            ProductView(
                                title: selectedCategory,
                                showAllBinding: $showProductListView,
                                searchText: $searchText,
                                category: $selectedCategory
                            ).padding()
                                .frame(maxWidth: .infinity)

                            Spacer().frame(height: 80)
                        }
                    }
                }
            }

            .navigationDestination(isPresented: $showProductListView) {
                ProductListView(
                    isActive: $showProductListView,
                    category: selectedCategory
                )
                .environmentObject(auth)
            }

            .navigationDestination(isPresented: $showProfile) {
                ProfileView(isActive: $showProfile)
                    .environmentObject(auth)
            }

            .navigationDestination(isPresented: $showNotification) {
                NotificationView(isActive: $showNotification)
                    .environmentObject(auth)
            }

            .navigationDestination(isPresented: $navigateToPayment) {
                if let id = createdOrderId, let amount = createdOrderAmount {
                    PaymentView(
                        orderId: id,
                        totalAmount: amount,
                        returnToHome: $returnToHome
                    ).environmentObject(cart)

                } else {
                    EmptyView()
                }
            }

            .navigationDestination(isPresented: $showCartView) {
                CartView(
                    returnToHome: $returnToHome, navigateToPayment: $navigateToPayment
                )
            }
            
            .navigationDestination(isPresented: $returnToHome) {
                ContentView(auth: auth)
        }
        }
    }

}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
}
