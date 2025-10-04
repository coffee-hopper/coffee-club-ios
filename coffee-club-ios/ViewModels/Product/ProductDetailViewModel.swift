import Foundation

@MainActor
final class ProductDetailViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(message: String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var product: Product?

    private var productService: ProductServiceProtocol?
    private var tokenProvider: (() -> String?)?

    private var loadTask: Task<Void, Never>?

    func configure(
        productService: ProductServiceProtocol,
        tokenProvider: @escaping () -> String?
    ) {
        guard self.productService == nil else { return }
        self.productService = productService
        self.tokenProvider = tokenProvider
    }

    func load(productID: Int) {
        guard let productService else { return }
        if case .loading = state { return }

        state = .loading
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let token = self.tokenProvider?()
                let fetched = try await productService.fetchProduct(id: productID, token: token)
                self.product = fetched
                self.state = .loaded
            } catch let AppError.http(status: code, message: msg) {
                self.state = .error(message: msg ?? "HTTP \(code)")
            } catch {
                self.state = .error(message: error.localizedDescription)
            }
        }
    }

    func refresh(productID: Int) { load(productID: productID) }
}
