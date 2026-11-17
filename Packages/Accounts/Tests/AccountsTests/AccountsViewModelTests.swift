import Core
import Testing
@testable import Accounts

struct FakeAccountsService: AccountsService {
    var accounts: [Account] = []
    var error: (any Error)?

    func fetchAccounts() async throws -> [Account] {
        if let error { throw error }
        return accounts
    }

    func fetchTransactions(for id: Account.ID) async throws -> [Transaction] { [] }
}

struct SampleError: Error {}

@MainActor
struct AccountsViewModelTests {
    @Test func startsIdle() {
        let viewModel = AccountsViewModel(service: FakeAccountsService())
        #expect(viewModel.state == .idle)
    }

    @Test func loadsAccounts() async {
        let viewModel = AccountsViewModel(service: FakeAccountsService(accounts: Account.samples))
        await viewModel.load()
        #expect(viewModel.state == .loaded(Account.samples))
    }

    @Test func showsEmptyState() async {
        let viewModel = AccountsViewModel(service: FakeAccountsService(accounts: []))
        await viewModel.load()
        #expect(viewModel.state == .empty)
    }

    @Test func showsFriendlyErrorOnFailure() async {
        let viewModel = AccountsViewModel(service: FakeAccountsService(error: SampleError()))
        await viewModel.load()
        #expect(viewModel.state == .failed(.generic))
    }

    @Test func staysQuietWhenCancelled() async {
        let viewModel = AccountsViewModel(service: FakeAccountsService(error: CancellationError()))
        await viewModel.load()
        #expect(viewModel.state == .idle)
    }
}
