import Foundation

enum PriceFormatting {
    static let tryFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .currency
        f.currencyCode = "TRY"
        f.currencySymbol = "₺"
        f.minimumFractionDigits = 2
        f.maximumFractionDigits = 2
        return f
    }()

    static func string(from decimal: Decimal) -> String {
        tryFormatter.string(from: NSDecimalNumber(decimal: decimal)) ?? "₺0,00"
    }
}
