//
//  MainHeaderView.swift
//  coffee-club-ios
//
//  Created by Bahadır Pekcan on 30.05.2025.
//

import SwiftUI

struct MainHeaderView: View {
    @EnvironmentObject var auth: AuthViewModel
    @Binding var showProfile: Bool

    var body: some View {
        ZStack {
            VStack(spacing: 12) {
                Spacer()
                HStack {
                    Button(action: {
                        showProfile = true
                    }) {
                        if let pictureURL = auth.user?.picture, let url = URL(string: pictureURL) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .frame(width: 40, height: 40)
                                .foregroundColor(.gray)
                        }
                    }

                    Spacer()

                    Button(action: {
                        print("Notifications tapped")
                    }) {
                        Image(systemName: "bell.fill")
                            .resizable()
                            .frame(width: 24, height: 28)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal, 20)

                Spacer()
            }
        }
        .frame(height: 150)
        .ignoresSafeArea(edges: .top)
    }

}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
}
