import SwiftUI

struct FooterView: View {
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                IconButton(systemName: "heart.fill") {
                    print("Favorites tapped")
                }

                Spacer()

                QRScanner()

                Spacer()

                IconButton(systemName: "cart.fill") {
                    print("CheckOut tapped")
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
}
