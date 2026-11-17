#if canImport(Combine)
import Core
import Testing
@testable import Accounts

@MainActor
struct TransactionSearchTests {
    @Test func debouncedQueryFiltersResults() async throws {
        let search = TransactionSearch()
        search.setTransactions(Transaction.samples)
        search.query = "coffee"
        try await Task.sleep(for: .milliseconds(600)) // longer than the 300 ms debounce
        #expect(search.results.map(\.merchant) == ["Coffee"])
    }

    @Test func emptyQueryShowsEverything() async throws {
        let search = TransactionSearch()
        search.setTransactions(Transaction.samples)
        try await Task.sleep(for: .milliseconds(600))
        #expect(search.results.count == Transaction.samples.count)
    }
}
#endif
