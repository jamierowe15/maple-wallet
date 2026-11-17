import Core
import Foundation

/// Fixture data with a little fake latency. Used by previews and tests.
public struct MockAccountsService: AccountsService {
    public var accounts: [Account]
    public var transactions: [Transaction]
    public var delay: Duration

    public init(accounts: [Account] = Account.samples,
                transactions: [Transaction] = Transaction.samples,
                delay: Duration = .milliseconds(300)) {
        self.accounts = accounts
        self.transactions = transactions
        self.delay = delay
    }

    public func fetchAccounts() async throws -> [Account] {
        try await Task.sleep(for: delay)
        return accounts
    }

    public func fetchAccount(id: Account.ID) async throws -> Account {
        try await Task.sleep(for: delay)
        guard let account = accounts.first(where: { $0.id == id }) else { throw UserFacingError.generic }
        return account
    }

    public func fetchTransactions(for id: Account.ID) async throws -> [Transaction] {
        try await Task.sleep(for: delay)
        return transactions.filter { $0.accountID == id }
    }
}
