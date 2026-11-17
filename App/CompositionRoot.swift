import Accounts
import Core

/// The ONE place that knows which concrete types back each protocol.
/// Features never create their own dependencies.
@MainActor
struct CompositionRoot {
    let accountsService: any AccountsService

    static func make() -> CompositionRoot {
        CompositionRoot(accountsService: MockAccountsService())
    }

    func makeAccountsViewModel() -> AccountsViewModel {
        AccountsViewModel(service: accountsService)
    }
}
