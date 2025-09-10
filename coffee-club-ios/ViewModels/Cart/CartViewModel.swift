//TODO: temporary pass-through (Step 7 will move this into payment/order orchestration)
import Combine
import Foundation

@MainActor
final class CartViewModel: ObservableObject {
    private let store: CartStore
    private let productService: ProductServiceProtocol?

    @Published private(set) var items: [CartItem] = []
    @Published private(set) var canCheckout = false
    @Published var errorMessage: String?

    var totalAmount: Decimal {
        items.reduce(Decimal.zero) { $0 + Decimal($1.product.price) * Decimal($1.quantity) }
    }

    private var cancellable: AnyCancellable?

    init(store: CartStore, productService: ProductServiceProtocol? = nil) {
        self.store = store
        self.productService = productService
        sync()

        if let observableStore = store as? CartStoreManager {
            cancellable = observableStore.$items.sink { [weak self] _ in
                Task { @MainActor in self?.sync() }
            }
        }
    }

    func add(product: Product) {
        let inCart = store.quantity(for: product.id)
        guard inCart < product.stockQuantity else {
            errorMessage = "Stok yetersiz: \(product.name)."
            return
        }
        store.addToCart(product)
        sync()
    }

    func decrement(productId: Int) {
        store.decreaseQuantity(for: productId)
        sync()
    }

    func remove(productId: Int) {
        store.removeFromCart(productId: productId)
        sync()
    }

    func clear() {
        store.clearCart()
        sync()
    }

    func quantityInCart(for productId: Int) -> Int {
        store.quantity(for: productId)
    }

    // temporary pass-through (Step 7 will move this into payment/order orchestration)
    func makeOrderRequest(userId: Int) -> OrderRequest? {
        store.createOrderPayload(userId: userId)
    }

    private func sync() {
        items = store.items
        canCheckout = !items.isEmpty
    }
}
