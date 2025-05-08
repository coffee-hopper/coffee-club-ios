//
//  ContentView.swift
//  coffee-club-ios
//
//  Created by Bahadır Pekcan on 8.05.2025.
//

import SwiftUI

struct ContentView: View {
    var auth: AuthViewModel

    var body: some View {
        TabView {
            ProductListView()
                .tabItem { Label("Menu", systemImage: "cup.and.saucer") }
                .environmentObject(auth)

            // Uncomment and implement when needed:
            // PaymentView()
            //     .tabItem { Label("Pay", systemImage: "creditcard") }

            // HistoryView()
            //     .tabItem { Label("History", systemImage: "clock") }

            // ProfileView(auth: auth)
            //     .tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
    }
}

#Preview {
    ContentView(auth: AuthViewModel())
}
