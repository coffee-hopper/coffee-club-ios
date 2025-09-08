import Foundation

@MainActor
final class ProductViewModel: ObservableObject {
    enum State: Equatable {
        case idle, loading, loaded
        case error(message: String)
    }

    @Published var searchText: String = ""
    @Published var selectedCategory: String = ""

    @Published private(set) var state: State = .idle
    @Published private(set) var allProducts: [Product] = []

    var filteredProducts: [Product] {
        var items = allProducts

        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            items = items.filter {
                $0.name.lowercased().contains(q) || $0.category.lowercased().contains(q)
                    || ($0.description ?? "").lowercased().contains(q)
            }
        }

        let cat = selectedCategory.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !cat.isEmpty {
            items = items.filter { $0.category.lowercased() == cat }
        }

        return items.sorted { $0.id < $1.id }
    }

    private var productService: ProductServiceProtocol?
    private weak var coordinator: ViewCoordinator?
    private var tokenProvider: () -> String?

    init() {
        self.tokenProvider = { nil }
    }

    func configure(
        productService: ProductServiceProtocol,
        coordinator: ViewCoordinator,
        tokenProvider: @escaping () -> String?
    ) {
        guard self.productService == nil else { return }
        self.productService = productService
        self.coordinator = coordinator
        self.tokenProvider = tokenProvider
    }

    func load() {
        guard let productService else { return }
        guard case .idle = state else { return }

        state = .loading
        Task {
            do {
                let token = tokenProvider()
                let products = try await productService.fetchProducts(token: token)
                self.allProducts = products.sorted { $0.id < $1.id }
                self.state = .loaded
            } catch {
                self.state = .error(message: ErrorMapper.message(for: error))
            }
        }
    }

    func refresh() {
        state = .idle
        load()
    }

    func onProductTapped(_ product: Product) {
        coordinator?.selectedProduct = product
        coordinator?.showProductDetail = true
    }

    func openSeeAll() {
        coordinator?.showProductList = true
    }
}
