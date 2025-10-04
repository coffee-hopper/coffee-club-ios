import CodeScanner
import SwiftUI

struct QRScanner: View {
    @Binding var isPresentingScanner: Bool
    @Binding var navigateToPayment: Bool
    @Binding var createdOrderId: Int?
    @Binding var createdOrderAmount: Decimal?

    @State private var alertMessage: String? = nil

    let productService: ProductServiceProtocol
    let orderService: OrderServiceProtocol
    let tokenProvider: TokenProviding?

    @StateObject private var vm: QRScannerViewModel

    init(
        isPresentingScanner: Binding<Bool>,
        navigateToPayment: Binding<Bool>,
        createdOrderId: Binding<Int?>,
        createdOrderAmount: Binding<Decimal?>,
        productService: ProductServiceProtocol,
        orderService: OrderServiceProtocol,
        tokenProvider: TokenProviding?
    ) {
        self._isPresentingScanner = isPresentingScanner
        self._navigateToPayment = navigateToPayment
        self._createdOrderId = createdOrderId
        self._createdOrderAmount = createdOrderAmount
        self.productService = productService
        self.orderService = orderService
        self.tokenProvider = tokenProvider
        _vm = StateObject(
            wrappedValue: QRScannerViewModel(
                productService: productService,
                orderService: orderService,
                tokenProvider: tokenProvider
            )
        )
    }

    var body: some View {
        IconButton(systemName: "qrcode") {
            vm.startScan()
        }
        .sheet(
            isPresented: $vm.isPresentingScanner,
            onDismiss: {
                if let msg = vm.pendingAlertMessage {
                    DispatchQueue.main.async {
                        alertMessage = msg
                        vm.pendingAlertMessage = nil
                    }
                }
            }
        ) {
            scannerSheet
                .presentationDragIndicator(.visible)
        }
        .alert(
            "Something went wrong",
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { alertMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
        .onChange(of: vm.shouldNavigateToPayment) { _, go in
            guard go else { return }
            createdOrderId = vm.createdOrderId
            createdOrderAmount = vm.createdOrderAmount
            navigateToPayment = true
            vm.shouldNavigateToPayment = false
        }
        .onChange(of: isPresentingScanner) { _, newVal in
            vm.isPresentingScanner = newVal
        }
        .onChange(of: vm.isPresentingScanner) { _, newVal in
            isPresentingScanner = newVal
        }
    }

    private var scannerSheet: some View {
        ZStack {
            CodeScannerView(codeTypes: [.qr]) { result in
                switch result {
                case .success(let code):
                    vm.handleScan(code.string)
                case .failure:
                    vm.handleScannerFailure()
                }
            }

            switch vm.state {
            case .fetchingProducts, .creatingOrder:
                ProgressView()
                    .scaleEffect(1.2)
                    .padding()
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
            default:
                EmptyView()
            }
        }
    }
}
