import Core
import Foundation
import Networking
import Testing
@testable import Accounts

struct FakeAccountsService: AccountsService {
    var accounts: [Account] = []
    var error: (any Error)?

    func fetchAccounts() async throws -> [Account] {
        if let error { throw error }
        return accounts
    }

    func fetchAccount(id: Account.ID) async throws -> Account {
        if let error { throw error }
        guard let account = accounts.first(where: { $0.id == id }) else { throw SampleError() }
        return account
    }

    func fetchTransactions(for id: Account.ID) async throws -> [Transaction] {
        if let error { throw error }
        return Transaction.samples.filter { $0.accountID == id }
    }
}

struct SampleError: Error {}

@MainActor
struct AccountsViewModelTests {
    @Test func loadsAccounts() async {
        let viewModel = AccountsViewModel(service: FakeAccountsService(accounts: Account.samples))
        await viewModel.load()
        #expect(viewModel.state == .loaded(Account.samples))
        #expect(viewModel.lastUpdated == nil)
    }

    @Test func showsEmptyState() async {
        let viewModel = AccountsViewModel(service: FakeAccountsService(accounts: []))
        await viewModel.load()
        #expect(viewModel.state == .empty)
    }

    @Test func showsFriendlyErrorWithNoCache() async {
        let viewModel = AccountsViewModel(service: FakeAccountsService(error: SampleError()))
        await viewModel.load()
        #expect(viewModel.state == .failed(.generic))
    }

    @Test func staysQuietWhenCancelled() async {
        let viewModel = AccountsViewModel(service: FakeAccountsService(error: CancellationError()))
        await viewModel.load()
        #expect(viewModel.state == .idle)
    }

    @Test func savesGoodResponsesToCache() async {
        let cache = InMemoryAccountsCache()
        let viewModel = AccountsViewModel(service: FakeAccountsService(accounts: Account.samples), cache: cache)
        await viewModel.load()
        #expect(await cache.load()?.accounts == Account.samples)
    }

    @Test func fallsBackToCacheWhenOffline() async {
        let savedAt = Date(timeIntervalSince1970: 1_700_000_000)
        let cache = InMemoryAccountsCache(CachedAccounts(accounts: Account.samples, savedAt: savedAt))
        let viewModel = AccountsViewModel(service: FakeAccountsService(error: SampleError()), cache: cache)
        await viewModel.load()
        #expect(viewModel.state == .loaded(Account.samples))
        #expect(viewModel.lastUpdated == savedAt)
    }
}

@MainActor
struct AccountDetailViewModelTests {
    @Test func loadsAccountAndTransactionsTogether() async {
        let viewModel = AccountDetailViewModel(accountID: "chq-001",
                                               service: FakeAccountsService(accounts: Account.samples))
        await viewModel.load()
        guard case .loaded(let account, let transactions) = viewModel.state else {
            Issue.record("Expected loaded, got \(viewModel.state)")
            return
        }
        #expect(account.id == "chq-001")
        #expect(transactions.allSatisfy { $0.accountID == "chq-001" })
    }

    @Test func failsWithFriendlyError() async {
        let viewModel = AccountDetailViewModel(accountID: "nope", service: FakeAccountsService(accounts: []))
        await viewModel.load()
        #expect(viewModel.state == .failed(.generic))
    }
}

struct RecentActivityTests {
    @Test func loadsEveryAccountInParallel() async throws {
        let service = MockAccountsService(delay: .zero)
        let activity = try await RecentActivity.load(for: Account.samples, using: service, limit: 2)
        #expect(Set(activity.keys) == Set(Account.samples.map(\.id)))
        #expect(activity["chq-001"]?.count == 2)
        #expect(activity["chq-001"]?.first?.id == "t-100")
    }
}

struct RemoteAccountsServiceTests {
    @Test func readsAccountsFromFixtures() async throws {
        let client = APIClientFactory.fixtures()
        let accounts = try await RemoteAccountsService(client: client).fetchAccounts()
        #expect(accounts.map(\.id) == ["chq-001", "sav-002", "cc-003"])
    }

    @Test func readsTransactionsNewestFirst() async throws {
        let transactions = try await RemoteAccountsService(client: APIClientFactory.fixtures())
            .fetchTransactions(for: "chq-001")
        #expect(transactions.first?.id == "t-100")
    }

    @Test func offlineFixtureServerThrowsOffline() async {
        let client = APIClientFactory.fixtures(offline: true)
        await #expect(throws: (any Error).self) {
            try await RemoteAccountsService(client: client).fetchAccounts()
        }
    }

    @Test func searchFiltersByMerchantOrCategory() {
        #if canImport(Combine)
        let results = TransactionSearch.filter(Transaction.samples, query: "food")
        #expect(results.map(\.id) == ["t-101", "t-103"])
        #endif
    }
}

enum APIClientFactory {
    static func fixtures(offline: Bool = false) -> APIClient {
        APIClient(baseURL: URL(string: "https://api.maplewallet.example")!,
                  transport: LocalFixtureTransport(latency: .zero, isOffline: { offline }),
                  retryPolicy: .none)
    }
}
