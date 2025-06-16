import SwiftUI

struct IconButton: View {
    let systemName: String
    let action: () -> Void
    var isFilled: Bool = true

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
                .frame(width: isFilled ? 28 : 28, height: isFilled ? 28 : 28)
                .padding(isFilled ? 12 : 2)
                .background(
                    isFilled ? Color("Primary") : Color.clear
                )
                .clipShape(Circle())
                .foregroundColor(Color("Secondary"))
                .scaleEffect(isFilled && isPressed ? 0.90 : 1.0)
                .shadow(
                    color: isFilled ? Color("Primary").opacity(0.7) : .clear,
                    radius: isPressed ? 8 : 1
                )
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(2)
    }
}
