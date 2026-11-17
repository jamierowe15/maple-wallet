/// The only thing the Accounts feature knows about where data comes from.
/// Mock, remote and cached implementations all conform to this.
public protocol AccountsService: Sendable {
    func fetchAccounts() async throws -> [Account]
    func fetchTransactions(for id: Account.ID) async throws -> [Transaction]
}
