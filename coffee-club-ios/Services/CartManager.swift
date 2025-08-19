//TODO: In CartManager (temporary; later we’ll move to OrderService or a VM) (this todo added during createOrderPayload userId added fix)


import Foundation

final class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    private let key = "cart_items"

    init() {
        loadCart()
    }

    func addToCart(_ product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
        saveCart()
    }

    func decreaseQuantity(for productId: Int) {
        if let index = items.firstIndex(where: { $0.product.id == productId }) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else {
                items.remove(at: index)
            }
            saveCart()
        }
    }

    func removeFromCart(productId: Int) {
        items.removeAll { $0.product.id == productId }
        saveCart()
    }

    func clearCart() {
        items.removeAll()
        saveCart()
    }

    func saveCart() {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func loadCart() {
        if let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([CartItem].self, from: data)
        {
            self.items = decoded
        }
    }

    func createOrderPayload(userId: Int) -> OrderRequest? {
        guard !items.isEmpty else { return nil }
        let orderItems = items.map {
            OrderItem(product: .init(id: $0.product.id), quantity: $0.quantity, price: Decimal($0.product.price))
        }
        let total = orderItems.reduce(Decimal.zero) { $0 + $1.price * Decimal($1.quantity) }
        return OrderRequest(user: userId, items: orderItems, totalAmount: total, status: "success")
    }
}
