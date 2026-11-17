import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A plain value for an HTTP response, so it can cross actor boundaries safely.
public struct HTTPResponse: Sendable {
    public let status: Int
    public let headers: [String: String]
    public let data: Data

    public init(status: Int, headers: [String: String] = [:], data: Data) {
        self.status = status
        self.headers = headers
        self.data = data
    }
}

/// The seam that makes networking testable: tests and previews swap in a fake.
public protocol HTTPTransport: Sendable {
    func send(_ request: URLRequest) async throws -> HTTPResponse
}

public struct URLSessionTransport: HTTPTransport {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func send(_ request: URLRequest) async throws -> HTTPResponse {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw APIError.server(status: -1)
        }
        var headers: [String: String] = [:]
        for (key, value) in http.allHeaderFields {
            if let key = key as? String, let value = value as? String { headers[key] = value }
        }
        return HTTPResponse(status: http.statusCode, headers: headers, data: data)
    }
}
