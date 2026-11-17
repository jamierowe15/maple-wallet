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
    func clear() async
}

/// Stores the last response as an encrypted-at-rest JSON file that's excluded from backups.
public actor FileAccountsCache: AccountsCaching {
    private let fileURL: URL

    public init(fileURL: URL? = nil) {
        if let fileURL {
            self.fileURL = fileURL
        } else {
            let folder = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            self.fileURL = folder.appendingPathComponent("accounts-cache.json")
        }
    }

    public func save(_ accounts: [Account]) async {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(CachedAccounts(accounts: accounts, savedAt: Date())) else { return }
        #if os(iOS)
        // Unreadable while the device is locked.
        try? data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        var url = fileURL
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try? url.setResourceValues(values)
        #else
        try? data.write(to: fileURL, options: [.atomic])
        #endif
    }

    public func load() async -> CachedAccounts? {
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(CachedAccounts.self, from: data)
    }

    public func clear() async {
        try? FileManager.default.removeItem(at: fileURL)
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
    public func clear() async { cached = nil }
}
