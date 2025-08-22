import Foundation

@MainActor
final class ProductListViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(message: String)
    }

    // Inputs (bound by the view)
    @Published var searchText: String
    @Published var selectedCategory: String

    // Outputs
    @Published private(set) var state: State = .idle
    @Published private(set) var allProducts: [Product] = []

    private let productService: ProductServiceProtocol
    private weak var tokenProvider: TokenProviding?
    private let nav: NavigationCoordinator

    init(
        productService: ProductServiceProtocol,
        tokenProvider: TokenProviding?,
        nav: NavigationCoordinator,
        selectedCategory: String = "coffee",
        searchText: String = ""
    ) {
        self.productService = productService
        self.tokenProvider = tokenProvider
        self.nav = nav
        self.selectedCategory = selectedCategory
        self.searchText = searchText
    }

    var filtered: [Product] {
        let base = allProducts.filter {
            $0.category.lowercased() == selectedCategory.lowercased()
        }
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return base }
        return base.filter {
            $0.name.lowercased().contains(q) || ($0.description?.lowercased().contains(q) ?? false)
        }
    }

    func load() {
        guard case .loading = state else {

            state = .loading
            Task {
                do {
                    let items = try await productService.fetchProducts(token: tokenProvider?.token)
                    allProducts = items.sorted { $0.id < $1.id }
                    state = .loaded
                } catch {
                    state = .error(message: ErrorMapper.message(for: error))
                }
            }
            return
        }
    }

    func onProductTapped(id: Int) {
        nav.openProduct(id)
    }
}
