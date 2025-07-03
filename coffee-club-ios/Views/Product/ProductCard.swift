import SwiftUI

struct ProductCard: View {
    let product: Product
    @EnvironmentObject var cart: CartManager

    var body: some View {
        ZStack(alignment: .center) {
            TaperedCardShape(cornerRadius: 50)
                .fill(Color.accentColor.opacity(0.1))
                .frame(width: 230, height: 200)

            VStack(spacing: 8) {
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .rotationEffect(.degrees(-8))

                Text(product.name)
                    .font(.system(size: 14))
                    .lineLimit(1)

                Text(String(format: "%.2f ₺", product.price))
                    .font(.subheadline.bold())
                    .foregroundColor(.accent)

                IconButton(
                    systemName: "plus",

                    action: {
                        cart.addToCart(product)
                        print("cart tapped product card")
                    },
                    isFilled: false,
                    iconSize: 14
                )
                .background(
                    TaperedCardShape(cornerRadius: 6)
                        .fill(Color.textPrimary.opacity(0.9))
                        .frame(width: 34, height: 25)
                )
                .foregroundColor(.white)
            }
            .offset(y: -5)

        }
        .frame(width: 220, height: 250)

    }
}
