import Foundation

public enum Route: Equatable, Hashable {
    case home
    case profile
    case notifications
    case productList(category: String)
    case productDetail(id: Int)
    case cart
    case payment(orderID: Int, total: Decimal?)
}
