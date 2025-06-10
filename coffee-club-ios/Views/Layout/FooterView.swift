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
                IconButton(systemName: "heart") {
                    print("Favorites tapped")
                }

                Spacer()

                IconButton(systemName: "qrcode") {
                    print("CheckOut tapped")
                }

                Spacer()

                IconButton(systemName: "person.crop.circle") {
                    print("Profile tapped")
                }
                Spacer()
            }
            .padding()
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
