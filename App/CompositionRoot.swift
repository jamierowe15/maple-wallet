import Accounts
import Auth
import Core
import Foundation
import Networking

/// The ONE place that knows which concrete types back each protocol.
@MainActor
struct CompositionRoot {
    let accountsService: any AccountsService
    let accountsCache: any AccountsCaching
    let tokenProvider: TokenProvider
    let signInService: SignInService

    nonisolated static var isUITesting: Bool { ProcessInfo.processInfo.arguments.contains("-uiTesting") }

    static func make() -> CompositionRoot {
        let configuration = AuthConfiguration.fromInfoPlist() ?? .stub
        let tokenStore: any TokenStore = isUITesting ? InMemoryTokenStore() : KeychainTokenStore()

        let exchanger: any TokenExchanging
        let refresher: any TokenRefreshing
        let authenticator: any WebAuthenticating
        if configuration.isStub {
            let stub = StubTokenClient(lifetime: 45) // short, so you can see a refresh happen
            exchanger = stub
            refresher = stub
            authenticator = StubWebAuthenticator()
        } else {
            let client = OAuthTokenClient(configuration: configuration)
            exchanger = client
            refresher = client
            authenticator = WebAuthenticator()
        }

        let tokenProvider = TokenProvider(store: tokenStore, refresher: refresher)
        let transport = LocalFixtureTransport(isOffline: { UserDefaults.standard.bool(forKey: "simulateOffline") })
        let client = APIClient(baseURL: URL(string: "https://api.maplewallet.example")!,
                               transport: transport, tokens: tokenProvider)

        return CompositionRoot(
            accountsService: RemoteAccountsService(client: client),
            accountsCache: FileAccountsCache(),
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
