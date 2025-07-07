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

    func createOrderPayload() -> OrderRequest? {
        guard !items.isEmpty else { return nil }
        let orderItems = items.map {
            OrderItem(
                product: ProductRef(id: $0.product.id),
                quantity: $0.quantity,
                price: Double($0.product.price)
            )
        }
        let total = orderItems.reduce(0.0) { $0 + ($1.price * Double($1.quantity)) }
        print(
            "1: \(OrderRequest(user: 1, items: orderItems, totalAmount: total, status: "pending"))"
        )

        return OrderRequest(user: 1, items: orderItems, totalAmount: total, status: "pending")
    }
}
