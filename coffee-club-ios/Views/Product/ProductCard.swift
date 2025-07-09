import SwiftUI

struct ProductCard: View {
    let product: Product
    let heightUnit: CGFloat

    @EnvironmentObject var cart: CartManager
    @EnvironmentObject var coordinator: ViewCoordinator

    var isOutOfStock: Bool {
        product.stockQuantity == 0
    }

    var body: some View {
        ZStack(alignment: .center) {
            TaperedCardShape(cornerRadius: heightUnit * 0.2)
                .fill(isOutOfStock ? Color.gray.opacity(0.2) : Color.accentColor.opacity(0.1))
                .frame(width: heightUnit * 0.70, height: heightUnit * 0.65)
            
            VStack(spacing: 8) {
                Image(product.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: heightUnit * 0.38)
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
            .offset(y: -heightUnit * 0.05)
        }
        .frame(height: heightUnit)
    }
}
