import Foundation

public struct TokenSet: Sendable, Codable, Equatable {
    public var accessToken: String
    public var refreshToken: String?
    public var expiresAt: Date

    public init(accessToken: String, refreshToken: String?, expiresAt: Date) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
    }
}

public protocol TokenStore: Sendable {
    func load() async -> TokenSet?
    func save(_ tokens: TokenSet) async throws
    func clear() async
}

public protocol TokenRefreshing: Sendable {
    func refresh(_ refreshToken: String) async throws -> TokenSet
}

public protocol TokenExchanging: Sendable {
    func exchange(code: String, verifier: String) async throws -> TokenSet
}

/// For tests, previews and UI tests. Never used for real tokens.
public actor InMemoryTokenStore: TokenStore {
    private var tokens: TokenSet?

    public init(_ tokens: TokenSet? = nil) {
        self.tokens = tokens
    }

    public func load() async -> TokenSet? { tokens }
    public func save(_ tokens: TokenSet) async throws { self.tokens = tokens }
    public func clear() async { tokens = nil }
}
