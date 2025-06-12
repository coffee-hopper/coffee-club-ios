//
//  FooterView.swift
//  coffee-club-ios
//
//  Created by Bahadır Pekcan on 4.06.2025.
//

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

                IconButton(systemName: "qrcode") {
                    print("CheckOut tapped")
                }

                Spacer()

                IconButton(systemName: "cart.fill") {
                    print("Cart tapped")
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
