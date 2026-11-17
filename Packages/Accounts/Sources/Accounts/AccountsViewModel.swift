import Core
import Foundation
import Observation

@Observable @MainActor
public final class AccountsViewModel {
    public enum State: Equatable {
        case idle
        case loading
        case loaded([Account])
        case empty
        case failed(UserFacingError)
    }

    public private(set) var state: State = .idle
    /// Set when we're showing cached data because the network failed.
    public private(set) var lastUpdated: Date?

    private let service: any AccountsService
    private let cache: (any AccountsCaching)?

    public init(service: any AccountsService, cache: (any AccountsCaching)? = nil) {
        self.service = service
        self.cache = cache
    }

    public func load() async {
        if case .loaded = state {} else { state = .loading }
        do {
            let accounts = try await service.fetchAccounts()
            await cache?.save(accounts)
            lastUpdated = nil
            state = accounts.isEmpty ? .empty : .loaded(accounts)
        } catch {
            // Cancelled (user left the screen): go quiet, never show an error.
            guard let friendly = UserFacingError.from(error) else {
                if case .loading = state { state = .idle }
                return
            }
            if let cached = await cache?.load(), !cached.accounts.isEmpty {
                state = .loaded(cached.accounts)
                lastUpdated = cached.savedAt
            } else {
                state = .failed(friendly)
            }
        }
    }
}
