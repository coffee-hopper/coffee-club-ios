import Foundation

public enum Route: Equatable, Hashable {
    case home
    case root
    case productDetail(id: Int)
    case cart
    case payment(orderID: Int)
    case profile
    case notifications
}
