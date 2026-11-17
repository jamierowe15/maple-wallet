import Core
import Foundation

public struct CachedAccounts: Sendable, Codable, Equatable {
    public let accounts: [Account]
    public let savedAt: Date
}

/// Remembers the last good response so the app still shows something offline.
public protocol AccountsCaching: Sendable {
    func save(_ accounts: [Account]) async
    func load() async -> CachedAccounts?
}

/// Stores the last response as a JSON file.
public actor FileAccountsCache: AccountsCaching {
    private let fileURL: URL

    public init(fileURL: URL? = nil) {
        self.fileURL = fileURL ?? FileManager.default
            .urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("accounts-cache.json")
    }

    public func save(_ accounts: [Account]) async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(CachedAccounts(accounts: accounts, savedAt: Date())) else { return }
        // A failed cache write is ignored on purpose: the cache is a convenience, and the next good load tries again.
        try? data.write(to: fileURL, options: [.atomic])
    }

    public func load() async -> CachedAccounts? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(CachedAccounts.self, from: data)
    }
}

/// For tests and previews.
public actor InMemoryAccountsCache: AccountsCaching {
    private var cached: CachedAccounts?

    public init(_ cached: CachedAccounts? = nil) {
        self.cached = cached
    }

    public func save(_ accounts: [Account]) async {
        cached = CachedAccounts(accounts: accounts, savedAt: Date())
    }

    public func load() async -> CachedAccounts? { cached }
}
