import SwiftUI

struct FooterView: View {
    @EnvironmentObject var coordinator: ViewCoordinator
    @Binding var isPresentingScanner: Bool
    @Binding var createdOrderId: Int?
    @Binding var createdOrderAmount: Decimal?

    var body: some View {
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
                coordinator.showCart = true
            }

            Spacer()
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
