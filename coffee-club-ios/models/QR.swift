import Foundation

struct QRPayload: Codable {
    let userId: Int
    let items: [QRItem]
}

struct QRItem: Codable {
    let productId: Int
    let quantity: Int
}
