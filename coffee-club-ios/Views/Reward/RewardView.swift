//
//  RewardView.swift
//  coffee-club-ios
//
//  Created by Bahadır Pekcan on 4.06.2025.
//

import SwiftUI

struct RewardView: View {
    var body: some View {
        Rectangle()
            .fill(Color.purple.opacity(0.2))
            .frame(height: 150)
            .overlay(Text("Rewards Box").foregroundColor(.purple))
            .border(Color.blue)
    }
}

#Preview {
    let auth = AuthViewModel()
    return ContentView(auth: auth)
        .environmentObject(auth)
}
