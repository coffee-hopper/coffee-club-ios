import Foundation

@MainActor
final class ProductListViewModel: ObservableObject {
    enum State: Equatable {
        case idle, loading, loaded
        case error(message: String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var products: [Product] = []

    var initialCategory: String = ""

    private var productService: ProductServiceProtocol?
    private weak var nav: NavigationCoordinator?
    private weak var selection: ProductSelection?
    private var tokenProvider: () -> String?

    init() { self.tokenProvider = { nil } }

    func configure(
        productService: ProductServiceProtocol,
        nav: NavigationCoordinator,
        selection: ProductSelection,
        tokenProvider: @escaping () -> String?,
        initialCategory: String
    ) {
        guard self.productService == nil else { return }
        self.productService = productService
        self.nav = nav
        self.selection = selection
        self.tokenProvider = tokenProvider
        self.initialCategory = initialCategory
    }

    func load() {
        guard let productService else { return }
        guard case .idle = state else { return }

        state = .loading
        Task {
            do {
                let token = tokenProvider()
                let items = try await productService.fetchProducts(token: token)
                if initialCategory.isEmpty {
                    self.products = items
                } else {
                    self.products = items.filter {
                        $0.category.lowercased() == initialCategory.lowercased()
                    }
                }
                self.products.sort { $0.id < $1.id }
                self.state = .loaded
            } catch {
                self.state = .error(message: ErrorMapper.message(for: error))
            }
        }
    }

    func onProductTapped(_ p: Product) {
        selection?.set(
            .init(
                id: p.id,
                name: p.name,
                price: Decimal(p.price),
                imageName: p.processedImageName
            )
        )
        nav?.openProduct(p.id)
    }
}
