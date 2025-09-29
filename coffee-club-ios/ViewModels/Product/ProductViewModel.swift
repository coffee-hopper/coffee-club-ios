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
    @Published private(set) var products: [Product] = []

    var filteredProducts: [Product] { products }

    private var productService: ProductServiceProtocol?
    private weak var nav: NavigationCoordinator?
    private weak var selection: ProductSelection?
    private var tokenProvider: () -> String?

    private var debounceTask: Task<Void, Never>?
    private var fetchTask: Task<Void, Never>?
    private var lastQueryKey: String?

    init() { self.tokenProvider = { nil } }

    func configure(
        productService: ProductServiceProtocol,
        nav: NavigationCoordinator,
        selection: ProductSelection,
        tokenProvider: @escaping () -> String?
    ) {
        guard self.productService == nil else { return }
        self.productService = productService
        self.nav = nav
        self.selection = selection
        self.tokenProvider = tokenProvider
    }

    func load() {
        guard case .idle = state else { return }
        state = .loading
        fetch(force: true)
    }

    func refresh() {
        state = .loading
        fetch(force: true)
    }

    func filtersDidChange() {
        debounceTask?.cancel()
        debounceTask = Task { @MainActor [weak self] in
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard let self, !Task.isCancelled else { return }
            self.fetch()
        }
    }

    private func currentOptions() -> ProductQueryOptions {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawCat =
            selectedCategory
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        return ProductQueryOptions(
            q: q.isEmpty ? nil : q,
            category: rawCat.isEmpty ? nil : rawCat,
            inStock: nil,
            offset: 0,
            limit: 50,
            sort: "name",
            order: "asc"
        )
    }

    private func queryKey(for opts: ProductQueryOptions) -> String {
        [
            opts.q ?? "",
            opts.category ?? "",
            opts.inStock == nil ? "" : (opts.inStock! ? "in" : "out"),
            String(opts.offset),
            String(opts.limit),
            opts.sort,
            opts.order,
        ].joined(separator: "|")
    }

    private func fetch(force: Bool = false) {
        guard let productService else { return }

        let opts = currentOptions()
        let key = queryKey(for: opts)
        if !force, key == lastQueryKey, state == .loaded { return }

        lastQueryKey = key

        fetchTask?.cancel()
        fetchTask = Task { [weak self] in
            guard let self else { return }
            do {
                let token = self.tokenProvider()
                let items = try await productService.fetchProducts(token: token, options: opts)

                await MainActor.run {
                    self.products = items
                    self.state = .loaded
                }
            } catch is CancellationError {
                /// ignore
            } catch {
                await MainActor.run {
                    self.state = .error(message: ErrorMapper.message(for: error))
                }

            }
        }
    }

    func onProductTapped(_ product: Product) {
        selection?.set(
            ProductSummary(
                id: product.id,
                name: product.name,
                price: Decimal(product.price),
                imageName: product.processedImageName
            )
        )
        nav?.openProduct(product.id)
    }

    func openSeeAll() {
        nav?.openProductList(category: selectedCategory)
    }
}
