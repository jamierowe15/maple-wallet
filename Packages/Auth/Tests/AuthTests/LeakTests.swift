import Foundation
import Testing
@testable import Auth

struct TokenProviderLeakTests {
    @Test func providerIsFreedAfterARefresh() async throws {
        weak var weakProvider: TokenProvider?
        do {
            let provider = TokenProvider(
                store: InMemoryTokenStore(TokenSet(accessToken: "old", refreshToken: "r1", expiresAt: .distantPast)),
                refresher: StubTokenClient(lifetime: 3600)
            )
            weakProvider = provider
            _ = try await provider.validToken()
        }
        #expect(weakProvider == nil)
    }
}
