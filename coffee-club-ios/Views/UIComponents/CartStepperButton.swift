import SwiftUI

struct CartStepperButton: View {
    let product: Product
    let quantity: Int?
    let height: CGFloat
    let isOutOfStock: Bool
    var onZeroQuantity: (() -> Void)? = nil
    var onTap: (() -> Void)? = nil

    @EnvironmentObject var cart: CartManager
    @State private var showStepper = false
    @State private var resetTimer: Timer?

    var actualQuantity: Int {
        quantity ?? cart.items.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }

    var body: some View {
        HStack(spacing: 4) {
            if showStepper || actualQuantity > 0 {
                Button(action: {
                    onTap?()
                    cart.decreaseQuantity(for: product.id)

                    if actualQuantity - 1 == 0 {
                        onZeroQuantity?()
                        scheduleReset()
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 26, height: height)
                        .background(Color.textPrimary.opacity(0.9))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(isOutOfStock)

                Text("\(actualQuantity)")
                    .font(.subheadline.bold())
                    .frame(width: height)

                Button(action: {
                    if actualQuantity < product.stockQuantity {
                        onTap?()
                        cart.addToCart(product)
                        cancelReset()
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .bold))
                        .frame(width: 26, height: height)
                        .background(
                            isOutOfStock ? Color.gray : Color.accent
                        )
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
                .disabled(isOutOfStock)
            } else {
                Button(action: {
                    if !isOutOfStock {
                        onTap?()
                        cart.addToCart(product)
                        withAnimation {
                            showStepper = true
                        }
                        cancelReset()
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .frame(width: 34, height: 25)
                        .background(
                            TaperedCardShape(cornerRadius: 6)
                                .fill(isOutOfStock ? Color.gray : Color.textPrimary.opacity(0.9))
                        )
                        .foregroundColor(.white)
                }
                .disabled(isOutOfStock)
            }
        }
        .onChange(of: actualQuantity) { oldValue, newValue in
            if newValue == 0 && showStepper {
                scheduleReset()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: actualQuantity)
    }

    private func scheduleReset() {
        cancelReset()
        resetTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            withAnimation {
                showStepper = false
            }
        }
    }

    private func cancelReset() {
        resetTimer?.invalidate()
        resetTimer = nil
    }
}
