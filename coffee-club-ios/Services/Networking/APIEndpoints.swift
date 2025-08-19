// TODO: adjust loyaltyStatus's String: "/loyalty/status/\(userId)" if different

enum APIEndpoints {
    static let products = "/products"
    static func product(_ id: Int) -> String { "/products/\(id)" }

    static let orders = "/orders"
    static func order(_ id: Int) -> String { "/orders/\(id)" }

    static let payments = "/payments"
    static func payment(_ id: Int) -> String { "/payments/\(id)" }

    static func loyaltyStatus(_ userId: Int) -> String { "/loyalty/status/\(userId)" }
}
