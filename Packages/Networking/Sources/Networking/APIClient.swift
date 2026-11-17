import Core
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A `Sendable` struct with only immutable state, so it is thread-safe by construction.
/// Mutable token state lives in an actor (`TokenProvider`, Day 3), not here.
public struct APIClient: Sendable {
    public let baseURL: URL
    private let transport: any HTTPTransport
    private let retryPolicy: RetryPolicy
    private let tokens: (any AccessTokenProviding)?
    private let sleep: @Sendable (Duration) async throws -> Void

    public init(
        baseURL: URL,
        transport: any HTTPTransport = URLSessionTransport(),
        retryPolicy: RetryPolicy = .standard,
        tokens: (any AccessTokenProviding)? = nil,
        sleep: @escaping @Sendable (Duration) async throws -> Void = { try await Task.sleep(for: $0) }
    ) {
        self.baseURL = baseURL
        self.transport = transport
        self.retryPolicy = retryPolicy
        self.tokens = tokens
        self.sleep = sleep
    }

    public func send<Response>(_ endpoint: Endpoint<Response>) async throws(APIError) -> Response {
        var retriesUsed = 0
        while true {
            do throws(APIError) {
                return try await sendOnce(endpoint, allowRefresh: true)
            } catch {
                guard error.isRetryable, retriesUsed < retryPolicy.delays.count else { throw error }
                do {
                    try await sleep(retryPolicy.delays[retriesUsed])
                } catch {
                    throw APIError.cancelled
                }
                retriesUsed += 1
            }
        }
    }

    private func sendOnce<Response>(_ endpoint: Endpoint<Response>, allowRefresh: Bool) async throws(APIError) -> Response {
        if Task.isCancelled { throw APIError.cancelled }

        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = endpoint.method
        request.httpBody = endpoint.body
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if endpoint.body != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        var usedToken: String?
        if let tokens {
            do {
                let token = try await tokens.validToken()
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
                usedToken = token
            } catch {
                throw APIError.unauthorized
            }
        }

        let response: HTTPResponse
        do {
            response = try await transport.send(request)
        } catch {
            throw APIError(transportError: error)
        }

        switch response.status {
        case 200..<300:
            do {
                return try Self.makeDecoder().decode(Response.self, from: response.data)
            } catch {
                throw APIError.decoding
            }
        case 401:
            guard allowRefresh, let tokens, let usedToken else { throw APIError.unauthorized }
            do {
                _ = try await tokens.refreshToken(rejecting: usedToken)
            } catch {
                throw APIError.unauthorized
            }
            return try await sendOnce(endpoint, allowRefresh: false)
        default:
            throw APIError.server(status: response.status)
        }
    }

    static func makeDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
