import Core

/// Loads the newest transactions for every account at once with a task group.
public enum RecentActivity {
    public static func load(
        for accounts: [Account],
        using service: any AccountsService,
        limit: Int = 3
    ) async throws -> [Account.ID: [Transaction]] {
        try await withThrowingTaskGroup(of: (Account.ID, [Transaction]).self) { group in
            for account in accounts {
                group.addTask {
                    try Task.checkCancellation()
                    let transactions = try await service.fetchTransactions(for: account.id)
                    return (account.id, Array(transactions.sorted { $0.date > $1.date }.prefix(limit)))
                }
            }
            var result: [Account.ID: [Transaction]] = [:]
            for try await (id, transactions) in group {
                result[id] = transactions
            }
            return result
        }
    }
}
