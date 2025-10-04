import Foundation

protocol CartStore {
    var items: [CartItem] { get }

    func addToCart(_ product: Product)
    func decreaseQuantity(for productId: Int)
    func removeFromCart(productId: Int)
    func clearCart()

    // helpers
    func quantity(for productId: Int) -> Int
    func createOrderPayload(userId: Int) -> OrderRequest?
}

