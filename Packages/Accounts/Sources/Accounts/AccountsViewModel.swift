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
    private let service: any AccountsService

    public init(service: any AccountsService) {
        self.service = service
    }

    public func load() async {
        state = .loading
        do {
            let accounts = try await service.fetchAccounts()
            state = accounts.isEmpty ? .empty : .loaded(accounts)
        } catch {
            // Cancelled (user left the screen): go quiet, never show an error.
            guard let friendly = UserFacingError.from(error) else { state = .idle; return }
            state = .failed(friendly)
        }
    }
}
