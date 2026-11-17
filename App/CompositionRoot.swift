import Accounts
import Core
import Foundation
import Networking

/// The ONE place that knows which concrete types back each protocol.
@MainActor
struct CompositionRoot {
    let accountsService: any AccountsService
    let accountsCache: any AccountsCaching

    static func make() -> CompositionRoot {
        let transport = LocalFixtureTransport(isOffline: { UserDefaults.standard.bool(forKey: "simulateOffline") })
        let client = APIClient(baseURL: URL(string: "https://api.maplewallet.example")!, transport: transport)
        return CompositionRoot(accountsService: RemoteAccountsService(client: client),
                               accountsCache: FileAccountsCache())
    }

    func makeAccountsViewModel() -> AccountsViewModel {
        AccountsViewModel(service: accountsService, cache: accountsCache)
    }

    func makeAccountDetailViewModel(_ id: Account.ID) -> AccountDetailViewModel {
        AccountDetailViewModel(accountID: id, service: accountsService)
    }
}
