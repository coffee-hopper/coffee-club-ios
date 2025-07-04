import Foundation
import SwiftUI

final class ViewCoordinator: ObservableObject {
    // MARK: - Core View States
    @Published var showProfile = false {
        didSet { if showProfile { resetExcept("profile") } }
    }

    @Published var showNotification = false {
        didSet { if showNotification { resetExcept("notification") } }
    }

    @Published var showProductList = false {
        didSet { if showProductList { resetExcept("productList") } }
    }

    @Published var showCart = false {
        didSet { if showCart { resetExcept("cart") } }
    }

    // MARK: - Payment Access (From Cart or QR)
    @Published var navigateToPayment = false {
        didSet { if navigateToPayment { resetExcept("payment") } }
    }

    // MARK: - Return to Home (ContentView Reset)
    @Published var returnToHome = false {
        didSet { if returnToHome { resetAll() } }
    }

    // MARK: - Utility
    private func resetExcept(_ key: String) {
        switch key {
        case "profile":
            showNotification = false
            showProductList = false
            showCart = false
            navigateToPayment = false
        case "notification":
            showProfile = false
            showProductList = false
            showCart = false
            navigateToPayment = false
        case "productList":
            showProfile = false
            showNotification = false
            showCart = false
            navigateToPayment = false
        case "cart":
            showProfile = false
            showNotification = false
            showProductList = false
            navigateToPayment = false
        case "payment":
            showProfile = false
            showNotification = false
            showProductList = false
            showCart = false
        default:
            resetAll()
        }
    }

    func resetAll() {
        showProfile = false
        showNotification = false
        showProductList = false
        showCart = false
        navigateToPayment = false
        returnToHome = false
    }
}
