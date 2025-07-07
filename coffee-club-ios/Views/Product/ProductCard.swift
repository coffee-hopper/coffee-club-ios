import SwiftUI

struct ProductCard: View {
    let product: Product

    @EnvironmentObject var cart: CartManager
    @EnvironmentObject var coordinator: ViewCoordinator

    var isOutOfStock: Bool {
        product.stockQuantity == 0
    }

    var body: some View {
        ZStack(alignment: .center) {
            // 🟦 Main Card Background (changes based on stock)
            TaperedCardShape(cornerRadius: 50)
                .fill(isOutOfStock ? Color.gray.opacity(0.2) : Color.accentColor.opacity(0.1))
                .frame(width: 230, height: 200)

            VStack(spacing: 8) {
                // 🖼 Image (grayed overlay if out of stock)
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                    .rotationEffect(.degrees(-8))
                    .opacity(isOutOfStock ? 0.4 : 1.0)
                    .onTapGesture {
                        coordinator.selectedProduct = product
                        coordinator.showProductDetail = true
                    }

                Text(product.name)
                    .font(.system(size: 14))
                    .lineLimit(1)

                Text(String(format: "%.2f ₺", product.price))
                    .font(.subheadline.bold())
                    .foregroundColor(.accent)

                // ➕ Add to Cart Button
                IconButton(
                    systemName: "plus",
                    action: {
                        if !isOutOfStock {
                            cart.addToCart(product)
                            print("cart tapped product card")
                        }
                    },
                    isFilled: false,
                    iconSize: 14
                )
                .background(
                    TaperedCardShape(cornerRadius: 6)
                        .fill(isOutOfStock ? Color.gray : Color.textPrimary.opacity(0.9))
                        .frame(width: 34, height: 25)
                )
                .foregroundColor(.white)
                .disabled(isOutOfStock)
            }
            .offset(y: -5)
        }
        .frame(width: 220, height: 250)
    }
}
