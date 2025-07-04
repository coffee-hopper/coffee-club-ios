import SwiftUI

struct FooterView: View {
    @EnvironmentObject var coordinator: ViewCoordinator
    @Binding var isPresentingScanner: Bool
    @Binding var createdOrderId: Int?
    @Binding var createdOrderAmount: Double?

    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                IconButton(systemName: "heart.fill") {
                    print("Favorites tapped")
                }

                Spacer()

                QRScanner(
                    isPresentingScanner: $isPresentingScanner,
                    navigateToPayment: $coordinator.navigateToPayment,
                    createdOrderId: $createdOrderId,
                    createdOrderAmount: $createdOrderAmount
                )

                Spacer()

                IconButton(systemName: "cart.fill") {
                    print("Cart tapped")
                    coordinator.showCart = true
                }
                Spacer()
            }
            .padding(.vertical, 22)
        }
        .zIndex(2)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
        .environmentObject(ViewCoordinator())
}
