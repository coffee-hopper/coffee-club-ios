import Foundation

struct PaymentRequest: Codable {
    let order: Int
    let iyzicoTransactionId: String
    let amount: Decimal
    let paymentMethod: String  // "cash" or "iyzico"
    let status: String  // always "success" for now
}

struct PaymentData: Codable {
    let id: Int
    let amount: Double
    let status: String
}

struct PaymentResponse: Codable {
    let payment: PaymentData
    let messages: [String]
}
