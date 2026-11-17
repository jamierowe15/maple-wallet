#if canImport(Combine)
import Combine
import Core
import Foundation

/// The one Combine pipeline in the app: debounced, de-duplicated search.
/// Combine suits UI event streams with timing operators (debounce, combineLatest). See docs/day-2.md.
@MainActor
public final class TransactionSearch: ObservableObject {
    @Published public var query = ""
    @Published public private(set) var results: [Transaction] = []
    @Published private var all: [Transaction] = []

    public init() {
        $query
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .combineLatest($all)
            .map { query, all in TransactionSearch.filter(all, query: query) }
            .assign(to: &$results)
    }

    public func setTransactions(_ transactions: [Transaction]) {
        all = transactions
    }

    nonisolated static func filter(_ transactions: [Transaction], query: String) -> [Transaction] {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return transactions }
        return transactions.filter {
            $0.merchant.localizedCaseInsensitiveContains(trimmed) || $0.category.localizedCaseInsensitiveContains(trimmed)
        }
    }
}
#endif
