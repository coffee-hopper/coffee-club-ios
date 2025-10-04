import Foundation

enum OrderComposer {

    /// Build order items by joining payload items with fetched products.
    /// Items with a missing product are skipped.
    static func mapToOrderItems(products: [Product], payload: QRPayload) -> [OrderItem] {
        let lookup = Dictionary(uniqueKeysWithValues: products.map { ($0.id, $0) })
        return payload.items.compactMap { item in
            guard let p = lookup[item.productId] else { return nil }
            return OrderItem(
                product: ProductRef(id: p.id),
                quantity: item.quantity,
                price: Decimal(p.price)
            )
        }
    }

    /// Sum quantity * price for each item.
    static func totalAmount(for items: [OrderItem]) -> Decimal {
        items.reduce(Decimal(0)) { $0 + ($1.price * Decimal($1.quantity)) }
    }

    /// Build the order request with a default status of "success".
    static func makeOrderRequest(
        userId: Int,
        items: [OrderItem],
        total: Decimal,
        status: String = "success"
    ) -> OrderRequest {
        OrderRequest(user: userId, items: items, totalAmount: total, status: status)
    }
}
