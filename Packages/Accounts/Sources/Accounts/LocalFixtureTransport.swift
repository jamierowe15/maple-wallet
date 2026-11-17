import Core
import Foundation
import Networking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A pretend server that answers from the JSON files in `Fixtures/`.
/// Works in the Simulator, in tests and on Windows. No internet needed.
public struct LocalFixtureTransport: HTTPTransport {
    private let latency: Duration
    private let isOffline: @Sendable () -> Bool

    public init(latency: Duration = .milliseconds(250), isOffline: @escaping @Sendable () -> Bool = { false }) {
        self.latency = latency
        self.isOffline = isOffline
    }

    public func send(_ request: URLRequest) async throws -> HTTPResponse {
        try await Task.sleep(for: latency)
        if isOffline() { throw URLError(.notConnectedToInternet) }

        let parts = (request.url?.path ?? "").split(separator: "/").map(String.init)
        let method = request.httpMethod ?? "GET"
        let accounts = try Self.load([Account].self, "accounts")
        let transactions = try Self.load([Transaction].self, "transactions")

        switch (method, parts) {
        case ("GET", ["accounts"]):
            return try Self.ok(accounts)
        case ("GET", let path) where path.count == 2 && path[0] == "accounts":
            guard let account = accounts.first(where: { $0.id == path[1] }) else { return Self.notFound }
            return try Self.ok(account)
        case ("GET", let path) where path.count == 3 && path[0] == "accounts" && path[2] == "transactions":
            return try Self.ok(transactions.filter { $0.accountID == path[1] }.sorted { $0.date > $1.date })
        case ("POST", ["transfers"]):
            return HTTPResponse(status: 201, data: Data(#"{"confirmation":"MW-\#(Int.random(in: 100_000...999_999))"}"#.utf8))
        default:
            return Self.notFound
        }
    }

    private static let notFound = HTTPResponse(status: 404, data: Data())

    private static func load<T: Decodable>(_ type: T.Type, _ name: String) throws -> T {
        guard let url = Bundle.module.url(forResource: name, withExtension: "json") else {
            throw URLError(.fileDoesNotExist)
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(T.self, from: Data(contentsOf: url))
    }

    private static func ok<T: Encodable>(_ value: T) throws -> HTTPResponse {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return HTTPResponse(status: 200, headers: ["Content-Type": "application/json"], data: try encoder.encode(value))
    }
}
