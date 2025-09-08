import Foundation

struct InvoiceRequest: Codable {
    let orderId: Int
    let billingAddress: String
    let totalAmount: Decimal
}

struct Invoice: Codable, Identifiable {
    let id: Int
    let orderId: Int
    let totalAmount: Decimal
    let status: InvoiceStatus
    let createdAt: Date
}

enum InvoiceStatus: String, Codable { case pending, issued, paid, failed, canceled }
