import Foundation

@MainActor
final class NavigationCoordinator: ObservableObject {

    @Published private(set) var route: Route = .home

    func goHome() { set(.home) }
    func openProduct(_ id: Int) { set(.productDetail(id: id)) }
    func openCart() { set(.cart) }
    func openPayment(orderID: Int) { set(.payment(orderID: orderID)) }
    func openProfile() { set(.profile) }
    func openNotifications() { set(.notifications) }

    private func set(_ newRoute: Route) {
        guard route != newRoute else { return }
        route = newRoute
    }
}
