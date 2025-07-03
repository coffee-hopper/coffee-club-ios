import SwiftUI

struct IconButton: View {
    let systemName: String
    let action: () -> Void
    var isFilled: Bool = true
    var iconSize : CGFloat = 28

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
                .frame(width: isFilled ? 28 : iconSize, height: isFilled ? 28 : iconSize)
                .padding(isFilled ? 12 : 2)
                .background(
                    isFilled ? Color("Primary") : Color.clear
                )
                .clipShape(Circle())
                .foregroundColor(Color("Secondary"))
                .scaleEffect(isFilled && isPressed ? 0.90 : 0.90)
                .shadow(
                    color: isFilled ? Color("Primary").opacity(0.7) : .clear,
                    radius: isPressed ? 8 : 1
                )
        }
        .buttonStyle(PlainButtonStyle())
        .zIndex(2)
    }
}
