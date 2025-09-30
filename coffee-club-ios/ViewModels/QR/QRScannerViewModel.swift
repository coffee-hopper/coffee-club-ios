import Foundation

@MainActor
final class QRScannerViewModel: ObservableObject {

    enum State: Equatable {
        case idle
        case scanning
        case fetchingProducts
        case creatingOrder
        case success(orderId: Int, total: Decimal)
        case error(message: String)
    }

    @Published var isPresentingScanner: Bool = false
    @Published private(set) var state: State = .idle

    @Published private(set) var createdOrderId: Int?
    @Published private(set) var createdOrderAmount: Decimal?
    @Published var shouldNavigateToPayment: Bool = false

    @Published var pendingAlertMessage: String? = nil

    private let productService: ProductServiceProtocol
    private let orderService: OrderServiceProtocol
    private let tokenProvider: TokenProviding?

    private var workTask: Task<Void, Never>?

    private func failAndClose(_ message: String) {
        pendingAlertMessage = message
        isPresentingScanner = false
        state = .error(message: message)
    }

    init(
        productService: ProductServiceProtocol,
        orderService: OrderServiceProtocol,
        tokenProvider: TokenProviding?
    ) {
        self.productService = productService
        self.orderService = orderService
        self.tokenProvider = tokenProvider
    }

    func startScan() {
        state = .scanning
        isPresentingScanner = true
    }

    func cancel() {
        workTask?.cancel()
        isPresentingScanner = false
        state = .idle
    }

    func handleScan(_ code: String) {
        isPresentingScanner = false

        guard
            let data = code.data(using: .utf8),
            let payload = try? JSONDecoder().decode(QRPayload.self, from: data)
        else {
            failAndClose("Invalid QR code. Please try again with a valid code.")
            return
        }

        workTask?.cancel()
        workTask = Task { [weak self] in
            guard let self else { return }
            do {
                self.state = .fetchingProducts
                let token = self.tokenProvider?.token

                let products = try await self.productService.fetchProducts(
                    token: token,
                    options: .init()
                )

                let items = OrderComposer.mapToOrderItems(products: products, payload: payload)
                guard !items.isEmpty else {
                    failAndClose("No matching products were found for this QR.")
                    return
                }

                let total = OrderComposer.totalAmount(for: items)
                let request = OrderComposer.makeOrderRequest(
                    userId: payload.userId,
                    items: items,
                    total: total
                )

                self.state = .creatingOrder
                let order = try await self.orderService.createOrder(request, token: token)

                self.createdOrderId = order.id
                self.createdOrderAmount = order.totalAmount
                self.state = .success(orderId: order.id, total: order.totalAmount)
                self.shouldNavigateToPayment = true

            } catch is CancellationError {

            } catch {
                failAndClose(ErrorMapper.message(for: error))
            }
        }
    }

    func handleScannerFailure() {
        failAndClose("Couldn’t read a QR code from that image.")
    }
}
