import Core
import Foundation

/// Owns token refresh. An actor, so only one caller touches `refreshTask` at a time.
///
/// When five requests get a 401 together, the first one starts a refresh Task and
/// the other four await the SAME task: one network call, five happy requests.
public actor TokenProvider: AccessTokenProviding {
    private let store: any TokenStore
    private let refresher: any TokenRefreshing
    private let now: @Sendable () -> Date
    private let refreshMargin: TimeInterval
    private var refreshTask: Task<TokenSet, any Error>?

    /// - Parameter refreshMargin: refresh this many seconds before expiry, so a token can't expire mid-request.
    public init(store: any TokenStore,
                refresher: any TokenRefreshing,
                refreshMargin: TimeInterval = 30,
                now: @escaping @Sendable () -> Date = { Date() }) {
        self.store = store
        self.refresher = refresher
        self.refreshMargin = refreshMargin
        self.now = now
    }

    public func validToken() async throws -> String {
        guard let tokens = await store.load() else { throw AuthError.notSignedIn }
        // Refresh a little early so a token doesn't expire mid-request.
        if tokens.expiresAt > now().addingTimeInterval(refreshMargin) { return tokens.accessToken }
        return try await refreshToken(rejecting: tokens.accessToken)
    }

    public func refreshToken(rejecting rejectedToken: String) async throws -> String {
        if let refreshTask {
            return try await refreshTask.value.accessToken
        }
        // No `await` between the check above and setting refreshTask below,
        // so no other caller can sneak in and start a second refresh.
        let task = Task { [store, refresher] () async throws -> TokenSet in
            guard let current = await store.load(), let refreshToken = current.refreshToken else {
                throw AuthError.notSignedIn
            }
            // Someone already refreshed after this token was rejected: reuse their result.
            if current.accessToken != rejectedToken { return current }
            let fresh = try await refresher.refresh(refreshToken)
            try await store.save(fresh)
            return fresh
        }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value.accessToken
    }
}
