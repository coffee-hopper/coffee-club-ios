//
//  coffee_club_iosApp.swift
//  coffee-club-ios
//
//  Created by Bahadır Pekcan on 8.05.2025.
//
import GoogleSignIn
import SwiftUI

@main
struct coffee_club_iosApp: App {
    @StateObject private var auth = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoggedIn {
                    ContentView(auth: auth)
                        .environmentObject(auth)
                } else {
                    LoginScreen()
                        .environmentObject(auth)
                }
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}
