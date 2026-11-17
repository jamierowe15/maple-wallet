import Core
import Foundation
import Networking
import Testing
@testable import Auth
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

actor CountingRefresher: TokenRefreshing {
    private(set) var calls = 0

    func refresh(_ refreshToken: String) async throws -> TokenSet {
        calls += 1
        try await Task.sleep(for: .milliseconds(100)) // long enough for every caller to pile up
        return TokenSet(accessToken: "new-\(calls)", refreshToken: refreshToken,
                        expiresAt: Date().addingTimeInterval(3600))
    }
}

struct TokenProviderTests {
    private func signedIn(expiresIn seconds: TimeInterval) -> InMemoryTokenStore {
        InMemoryTokenStore(TokenSet(accessToken: "old", refreshToken: "r1",
                                    expiresAt: Date().addingTimeInterval(seconds)))
    }

    @Test func fiveConcurrentRefreshesMakeOneNetworkCall() async throws {
        let store = signedIn(expiresIn: 3600)
        let refresher = CountingRefresher()
        let provider = TokenProvider(store: store, refresher: refresher)

        let tokens = try await withThrowingTaskGroup(of: String.self) { group in
            for _ in 0..<5 { group.addTask { try await provider.refreshToken(rejecting: "old") } }
            var all: [String] = []
            for try await token in group { all.append(token) }
            return all
        }

        #expect(await refresher.calls == 1)
        #expect(tokens == Array(repeating: "new-1", count: 5))
        #expect(await store.load()?.accessToken == "new-1")
    }

    @Test func lateRefreshForAnOldTokenReusesTheNewOne() async throws {
        let store = signedIn(expiresIn: 3600)
        let refresher = CountingRefresher()
        let provider = TokenProvider(store: store, refresher: refresher)

        _ = try await provider.refreshToken(rejecting: "old")
        let again = try await provider.refreshToken(rejecting: "old")

        #expect(again == "new-1")
        #expect(await refresher.calls == 1)
    }

    @Test func validTokenSkipsRefreshWhenFresh() async throws {
        let refresher = CountingRefresher()
        let provider = TokenProvider(store: signedIn(expiresIn: 3600), refresher: refresher)
        #expect(try await provider.validToken() == "old")
        #expect(await refresher.calls == 0)
    }

    @Test func validTokenRefreshesWhenExpired() async throws {
        let refresher = CountingRefresher()
        let provider = TokenProvider(store: signedIn(expiresIn: -10), refresher: refresher)
        #expect(try await provider.validToken() == "new-1")
    }

    @Test func throwsWhenSignedOut() async {
        let provider = TokenProvider(store: InMemoryTokenStore(), refresher: CountingRefresher())
        await #expect(throws: AuthError.notSignedIn) { try await provider.validToken() }
    }
}

/// Answers 401 to the old token and 200 to any refreshed one, like a real API would.
actor TokenCheckingTransport: HTTPTransport {
    private(set) var requests = 0

    func send(_ request: URLRequest) async throws -> HTTPResponse {
        requests += 1
        let header = request.value(forHTTPHeaderField: "Authorization")
        if header == "Bearer old" { return HTTPResponse(status: 401, data: Data()) }
        return HTTPResponse(status: 200, data: Data("[1]".utf8))
    }
}

struct ParallelUnauthorizedRequestsTests {
    @Test func fiveParallel401sTriggerExactlyOneRefresh() async throws {
        let refresher = CountingRefresher()
        let provider = TokenProvider(
            store: InMemoryTokenStore(TokenSet(accessToken: "old", refreshToken: "r1",
                                               expiresAt: Date().addingTimeInterval(3600))),
            refresher: refresher
        )
        let transport = TokenCheckingTransport()
        let client = APIClient(baseURL: URL(string: "https://api.example.test")!, transport: transport,
                               retryPolicy: .none, tokens: provider)

        try await withThrowingTaskGroup(of: [Int].self) { group in
            for _ in 0..<5 { group.addTask { try await client.send(Endpoint<[Int]>(path: "/accounts")) } }
            for try await result in group { #expect(result == [1]) }
        }

        #expect(await refresher.calls == 1)
        #expect(await transport.requests == 10) // 5 rejected + 5 retried
    }
}

@MainActor
struct SignInServiceTests {
    @Test func signInStoresTokens() async throws {
        let store = InMemoryTokenStore()
        let service = SignInService(configuration: .stub, authenticator: StubWebAuthenticator(),
                                    exchanger: StubTokenClient(), store: store)
        try await service.signIn()
        #expect(await service.isSignedIn())
        #expect(await store.load()?.accessToken == "stub-access-0")
    }

    @Test func tamperedStateIsRejectedAndNothingIsStored() async {
        let store = InMemoryTokenStore()
        let service = SignInService(configuration: .stub, authenticator: StubWebAuthenticator(tamperWithState: true),
                                    exchanger: StubTokenClient(), store: store)
        await #expect(throws: AuthError.stateMismatch) { try await service.signIn() }
        #expect(await store.load() == nil)
    }

    @Test func signOutClearsTokens() async throws {
        let store = InMemoryTokenStore()
        let service = SignInService(configuration: .stub, authenticator: StubWebAuthenticator(),
                                    exchanger: StubTokenClient(), store: store)
        try await service.signIn()
        await service.signOut()
        #expect(await service.isSignedIn() == false)
    }
}

struct AllowlistTests {
    private let allowlist = NavigationAllowlist(hosts: ["example.com"])

    @Test func allowsListedHTTPSHost() {
        #expect(allowlist.allows(URL(string: "https://example.com/statements/2026-10")!))
        #expect(allowlist.allows(URL(string: "https://EXAMPLE.com/")!))
    }

    @Test(arguments: ["http://example.com/", "https://evil.com/", "https://example.com.evil.com/", "javascript:alert(1)"])
    func blocksEverythingElse(_ link: String) {
        #expect(!allowlist.allows(URL(string: link)!))
    }
}

struct FormEncodingTests {
    @Test func encodesReservedCharacters() {
        let body = String(decoding: OAuthTokenClient.formEncode(["redirect_uri": "maplewallet://callback", "a": "b c"]), as: UTF8.self)
        #expect(body == "a=b%20c&redirect_uri=maplewallet%3A%2F%2Fcallback")
    }
}
