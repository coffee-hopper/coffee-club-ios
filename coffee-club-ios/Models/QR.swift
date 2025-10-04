import Foundation

struct QRPayload: Decodable {
    let userId: Int
    let items: [QRItem]

    /// Merge duplicates and drop non-positive quantities
    func normalizedItems() -> [QRItem] {
        var bucket: [Int: Int] = [:]
        for item in items where item.quantity > 0 {
            bucket[item.productId, default: 0] += item.quantity
        }
        return bucket.map { QRItem(productId: $0.key, quantity: $0.value) }
    }

    /// accept both userId / user_id
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyKey.self)
        self.userId = try c.decodeEither(Int.self, "userId", "user_id")
        self.items = try c.decodeEither([QRItem].self, "items", "order_items")
    }
}

struct QRItem: Decodable {
    let productId: Int
    let quantity: Int

    init(productId: Int, quantity: Int) {
        self.productId = productId
        self.quantity = quantity
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: AnyKey.self)
        self.productId = try c.decodeEither(Int.self, "productId", "product_id", "id")
        self.quantity = try c.decodeEither(Int.self, "quantity", "qty")
    }
}

// MARK: decoding helpers

private struct AnyKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }
    init?(intValue: Int) { nil }
    init?(stringValue: String) { self.stringValue = stringValue }
}

extension KeyedDecodingContainer where Key == AnyKey {
    fileprivate func decodeEither<T: Decodable>(_ type: T.Type, _ keys: String...) throws -> T {
        for k in keys {
            if let value = try? decode(T.self, forKey: AnyKey(stringValue: k)!) {
                return value
            }
        }
        throw DecodingError.keyNotFound(
            AnyKey(stringValue: keys.first!)!,
            .init(codingPath: codingPath, debugDescription: "None of \(keys) present")
        )
    }
}
