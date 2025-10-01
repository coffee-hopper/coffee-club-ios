import Foundation

@MainActor
final class LoyaltyViewModel: ObservableObject {
    enum State: Equatable {
        case idle
        case loading
        case loaded
        case error(message: String)
    }

    @Published private(set) var state: State = .idle
    @Published private(set) var status: LoyaltyStatus = .init(
        stars: 0,
        rewards: 0,
        remainingToNext: 0,
        requiredStars: 15
    )

    private var loyaltyService: LoyaltyServiceProtocol?
    private var tokenProvider: (() -> String?)?
    private var userId: Int?

    private var loadTask: Task<Void, Never>?

    func configure(
        loyaltyService: LoyaltyServiceProtocol,
        userId: Int,
        tokenProvider: @escaping () -> String?
    ) {
        guard self.loyaltyService == nil else { return }
        self.loyaltyService = loyaltyService
        self.userId = userId
        self.tokenProvider = tokenProvider
    }

    func load() {
        switch state {
        case .idle, .error:
            fetch(force: true)
        default:
            break
        }
    }

    func refresh() {
        fetch(force: true)
    }

    private func fetch(force: Bool) {
        guard let loyaltyService, let userId else { return }
        if !force, case .loading = state { return }

        state = .loading
        loadTask?.cancel()
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let token = self.tokenProvider?()
                let s = try await loyaltyService.fetchStatus(userId: userId, token: token)
                self.status = s
                self.state = .loaded
            } catch is CancellationError {
                /// ignore
            } catch {
                self.state = .error(message: ErrorMapper.message(for: error))
            }
        }
    }
}
