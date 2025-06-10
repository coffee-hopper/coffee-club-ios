//
//  IconButton.swift
//  coffee-club-ios
//
//  Created by Bahadır Pekcan on 4.06.2025.
//
import SwiftUI

struct IconButton: View {
    let systemName: String
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
                action()
            }
        }) {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .padding(12)
                .background(dynamicColor.opacity(0.15))
                .clipShape(Circle())
                .foregroundColor(dynamicColor)
                .scaleEffect(isPressed ? 0.85 : 1.0)
                .shadow(color: dynamicColor.opacity(0.25), radius: isPressed ? 1 : 4)
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(2)
    }

    private var dynamicColor: Color {
        colorScheme == .dark ? Color.green.opacity(0.9) : Color.mint
    }
}
