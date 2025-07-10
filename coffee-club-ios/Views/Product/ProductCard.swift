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
        ZStack {

            VStack(spacing: 4) {
                Spacer()

                Text(product.name)
                    .font(.system(size: 14))
                    .lineLimit(1)

                Text(String(format: "%.2f ₺", product.price))
                    .font(.subheadline.bold())
                    .foregroundColor(.accent)
            }
            .frame(width: heightUnit * 0.75, height: heightUnit * 0.75)
            .taperedCardBackground(heightUnit: heightUnit * 0.75, isOutOfStock: isOutOfStock)

            VStack {
                Image(product.imageName)
                    .resizable()
                    .clipped(antialiased: false)
                    .scaledToFit()
                    .frame(height: heightUnit * 0.65)
                    .rotationEffect(.degrees(-9))
                    .opacity(isOutOfStock ? 0.4 : 1.0)
                    .onTapGesture {
                        coordinator.selectedProduct = product
                        coordinator.showProductDetail = true
                    }

                Spacer()

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
            .frame(width: heightUnit * 0.95, height: heightUnit * 0.95)
            .zIndex(2)

        }
        .frame(width: heightUnit * 0.80, height: heightUnit)
    }
}
