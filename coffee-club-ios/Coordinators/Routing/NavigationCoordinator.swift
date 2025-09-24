import Foundation
import SwiftUI

@MainActor
final class NavigationCoordinator: ObservableObject {
    @Published private(set) var route: Route = .home

    func goHome() { set(.home) }
    func reset() { set(.home) }

    func openProfile() { set(.profile) }
    func openNotifications() { set(.notifications) }
    func openProductList(category: String) { set(.productList(category: category)) }
    func openProduct(_ id: Int) { set(.productDetail(id: id)) }
    func openCart() { set(.cart) }
    func openPayment(orderID: Int, total: Decimal?) {
        set(.payment(orderID: orderID, total: total))
    }

    private func set(_ newRoute: Route) {
        guard route != newRoute else { return }
        route = newRoute
    }
}


extension NavigationCoordinator {
    func binding(for target: Route, open: @escaping () -> Void) -> Binding<Bool> {
        Binding(
            get: { self.route == target },
            set: { newValue in
                let isActive = (self.route == target)
                guard newValue != isActive else { return }
                if newValue { open() } else if isActive { self.reset() }
            }
        )
    }
    var isProfileActive: Binding<Bool> { binding(for: .profile, open: openProfile) }
    var isNotificationsActive: Binding<Bool> {
        binding(for: .notifications, open: openNotifications)
    }
    var isCartActive: Binding<Bool> { binding(for: .cart, open: openCart) }
}
