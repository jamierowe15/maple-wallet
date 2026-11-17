import Accounts
import Auth
import Core
import Foundation
import Networking
import Transfers
import WidgetKit

/// The ONE place that knows which concrete types back each protocol.
@MainActor
struct CompositionRoot {
    let accountsService: any AccountsService
    let accountsCache: any AccountsCaching
    let transfersService: any TransfersService
    let tokenProvider: TokenProvider
    let signInService: SignInService
    let router = DeepLinkRouter()

    nonisolated static var isUITesting: Bool { ProcessInfo.processInfo.arguments.contains("-uiTesting") }

    static func make() -> CompositionRoot {
        let configuration = AuthConfiguration.fromInfoPlist() ?? .stub
        if isUITesting { UserDefaults.standard.removeObject(forKey: "simulateOffline") } // every UI test starts online
        let tokenStore: any TokenStore = isUITesting ? InMemoryTokenStore() : KeychainTokenStore()

        let exchanger: any TokenExchanging
        let refresher: any TokenRefreshing
        let authenticator: any WebAuthenticating
        var refreshMargin: TimeInterval = 30
        if configuration.isStub {
            // Short on purpose so you can watch a refresh. Launch with `-tokenLifetime 8` to make it shorter.
            let lifetime = UserDefaults.standard.double(forKey: "tokenLifetime")
            let stub = StubTokenClient(lifetime: lifetime > 0 ? lifetime : 45)
            if lifetime > 0 { refreshMargin = min(30, lifetime / 2) }
            exchanger = stub
            refresher = stub
            authenticator = StubWebAuthenticator()
        } else {
            let client = OAuthTokenClient(configuration: configuration)
            exchanger = client
            refresher = client
            authenticator = WebAuthenticator()
        }

        let tokenProvider = TokenProvider(store: tokenStore, refresher: refresher, refreshMargin: refreshMargin)
        let uiTesting = isUITesting
        let transport = LocalFixtureTransport(isOffline: {
            !uiTesting && UserDefaults.standard.bool(forKey: "simulateOffline")
        })
        let client = APIClient(baseURL: URL(string: "https://api.maplewallet.example")!,
                               transport: transport, tokens: tokenProvider)

        return CompositionRoot(
            accountsService: WidgetSnapshottingService(base: RemoteAccountsService(client: client)),
            accountsCache: isUITesting ? InMemoryAccountsCache() : FileAccountsCache(),
            transfersService: RemoteTransfersService(client: client),
            tokenProvider: tokenProvider,
            signInService: SignInService(configuration: configuration, authenticator: authenticator,
                                         exchanger: exchanger, store: tokenStore)
        )
    }

    func makeSessionModel() -> SessionModel {
        SessionModel(service: signInService) { [accountsCache] in
            await accountsCache.clear()
            await WebDataCleaner.clearAll()
        }
    }

    func makeAccountsViewModel() -> AccountsViewModel {
        AccountsViewModel(service: accountsService, cache: accountsCache)
    }

    func makeAccountDetailViewModel(_ id: Account.ID) -> AccountDetailViewModel {
        AccountDetailViewModel(accountID: id, service: accountsService)
    }

    func makeTransferViewModel(accounts: [Account], prefill: Money?) -> TransferViewModel {
        TransferViewModel(accounts: accounts, service: transfersService, prefillAmount: prefill)
    }
}

extension AuthConfiguration {
    /// Uses a real Auth0 tenant when Config/Auth.local.xcconfig sets one; otherwise nil (stub login).
    static func fromInfoPlist(_ bundle: Bundle = .main) -> AuthConfiguration? {
        guard let domain = bundle.object(forInfoDictionaryKey: "AUTH0_DOMAIN") as? String, !domain.isEmpty,
              let clientID = bundle.object(forInfoDictionaryKey: "AUTH0_CLIENT_ID") as? String, !clientID.isEmpty
        else { return nil }
        return .auth0(domain: domain, clientID: clientID)
    }
}

/// Decorator: every successful accounts load also refreshes the Home Screen widget.
struct WidgetSnapshottingService: AccountsService {
    let base: any AccountsService

    func fetchAccounts() async throws -> [Account] {
        let accounts = try await base.fetchAccounts()
        if let primary = accounts.first {
            let snapshot = WidgetSnapshot(accountName: primary.name, balance: primary.balance, updatedAt: Date())
            if let data = try? JSONEncoder().encode(snapshot) {
                UserDefaults(suiteName: WidgetSnapshot.appGroup)?.set(data, forKey: WidgetSnapshot.defaultsKey)
                await MainActor.run { WidgetCenter.shared.reloadAllTimelines() }
            }
        }
        return accounts
    }

    func fetchAccount(id: Account.ID) async throws -> Account { try await base.fetchAccount(id: id) }

    func fetchTransactions(for id: Account.ID) async throws -> [Transaction] {
        try await base.fetchTransactions(for: id)
    }
}
