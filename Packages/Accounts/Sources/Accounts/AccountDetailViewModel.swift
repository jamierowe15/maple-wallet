import Core
import Foundation
import Observation

@Observable @MainActor
public final class AccountDetailViewModel {
    public enum State: Equatable {
        case loading
        case loaded(Account, [Transaction])
        case failed(UserFacingError)
    }

    public private(set) var state: State = .loading
    public let accountID: Account.ID
    private let service: any AccountsService

    public init(accountID: Account.ID, service: any AccountsService) {
        self.accountID = accountID
        self.service = service
    }

    /// Balance and transactions load in PARALLEL with `async let`.
    public func load() async {
        do {
            async let account = service.fetchAccount(id: accountID)
            async let transactions = service.fetchTransactions(for: accountID)
            let (loadedAccount, loadedTransactions) = try await (account, transactions)
            state = .loaded(loadedAccount, loadedTransactions)
        } catch {
            if let friendly = UserFacingError.from(error) { state = .failed(friendly) }
        }
    }
}
