import SwiftUI

struct ProductCard: View {
    let product: Product
    let heightUnit: CGFloat
    @Binding var activeProductId: Int?

    @EnvironmentObject var cart: CartStoreManager
    @EnvironmentObject var nav: NavigationCoordinator
    @EnvironmentObject var selection: ProductSelection

    @State private var tiltAngle: Double = -9

    var isOutOfStock: Bool { product.stockQuantity == 0 }
    var isStepperVisible: Bool { activeProductId == product.id }

    var body: some View {
        ZStack {
            VStack(spacing: 4) {
                Spacer()

                Text(product.name)
                    .font(.system(size: 14))
                    .lineLimit(1)

                Text(PriceFormatting.string(from: Decimal(product.price)))
                    .font(.subheadline.bold())
                    .foregroundColor(.accent)

                Spacer().frame(height: 2)
            }
            .frame(width: heightUnit * 0.75, height: heightUnit * 0.75)
            .taperedCardBackground(heightUnit: heightUnit * 0.75, isOutOfStock: isOutOfStock)

            VStack {
                Image(product.processedImageName)
                    .resizable()
                    .clipped(antialiased: false)
                    .scaledToFit()
                    .frame(height: heightUnit * 0.65)
                    .rotationEffect(.degrees(tiltAngle))
                    .opacity(isOutOfStock ? 0.4 : 1.0)
                    .onTapGesture {
                        selection.set(
                            .init(
                                id: product.id,
                                name: product.name,
                                price: Decimal(product.price),
                                imageName: product.processedImageName
                            )
                        )
                        nav.openProduct(product.id)
                    }

                Spacer()

                CartStepperButton(
                    product: product,
                    quantity: nil,
                    height: 25,
                    isOutOfStock: isOutOfStock,
                    onTap: {
                        withAnimation(.spring()) {
                            tiltAngle = 9
                            activeProductId = product.id
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                            withAnimation(.spring()) {
                                tiltAngle = -9
                            }
                        }
                    }
                )
            }
            .frame(width: heightUnit * 0.95, height: heightUnit * 0.95)
            .zIndex(2)
        }
        .frame(width: heightUnit * 0.80, height: heightUnit)
    }
}
