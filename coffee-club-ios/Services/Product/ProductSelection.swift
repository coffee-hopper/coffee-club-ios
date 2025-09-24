import Foundation

struct ProductSummary: Equatable, Hashable {
    let id: Int
    let name: String
    let price: Decimal
    let imageName: String
}

@MainActor
final class ProductSelection: ObservableObject {

    @Published private(set) var lastSelected: ProductSummary?
    private var store: [Int: ProductSummary] = [:]

    func set(_ snapshot: ProductSummary) {
        store[snapshot.id] = snapshot
        lastSelected = snapshot
    }

    func snapshot(for id: Int) -> ProductSummary? {
        store[id]
    }

    func clear(id: Int? = nil) {
        if let id {
            store[id] = nil
        } else {
            store.removeAll()
            lastSelected = nil
        }
    }
}
