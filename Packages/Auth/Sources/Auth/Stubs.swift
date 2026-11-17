import Foundation

/// Pretends to be the login page: immediately "redirects back" with a code and the same state.
public struct StubWebAuthenticator: WebAuthenticating {
    private let tamperWithState: Bool

    public init(tamperWithState: Bool = false) {
        self.tamperWithState = tamperWithState
    }

    @MainActor
    public func authenticate(url: URL, callbackScheme: String) async throws -> URL {
        let state = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first { $0.name == "state" }?.value ?? ""
        let returnedState = tamperWithState ? "evil-\(state)" : state
        return URL(string: "\(callbackScheme)://callback?code=stub-code&state=\(returnedState)")!
    }
}

/// Pretends to be the token endpoint. `lifetime` is short on purpose so you can
/// watch a refresh happen (see the sign-in recording in docs/day-3.md).
public actor StubTokenClient: TokenExchanging, TokenRefreshing {
    private let lifetime: TimeInterval
    public private(set) var refreshCount = 0

    public init(lifetime: TimeInterval = 45) {
        self.lifetime = lifetime
    }

    public func exchange(code: String, verifier: String) async throws -> TokenSet {
        TokenSet(accessToken: "stub-access-0", refreshToken: "stub-refresh",
                 expiresAt: Date().addingTimeInterval(lifetime))
    }

    public func refresh(_ refreshToken: String) async throws -> TokenSet {
        refreshCount += 1
        try await Task.sleep(for: .milliseconds(300))
        return TokenSet(accessToken: "stub-access-\(refreshCount)", refreshToken: refreshToken,
                        expiresAt: Date().addingTimeInterval(lifetime))
    }
}
