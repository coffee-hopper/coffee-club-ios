import Foundation

struct InvoiceRequest: Codable {
    let order: ProductRef
    let billingAddress: String
    let totalAmount: Double
}
