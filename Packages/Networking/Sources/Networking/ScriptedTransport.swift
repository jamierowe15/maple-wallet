import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A fake transport that replays a script of responses. Used by tests.
public actor ScriptedTransport: HTTPTransport {
    public enum Step: Sendable {
        case respond(status: Int, body: Data)
        case fail(any Error)
    }

    private var steps: [Step]
    public private(set) var requestCount = 0
    public private(set) var authorizationHeaders: [String?] = []

    public init(_ steps: [Step]) {
        self.steps = steps
    }

    public func send(_ request: URLRequest) async throws -> HTTPResponse {
        requestCount += 1
        authorizationHeaders.append(request.value(forHTTPHeaderField: "Authorization"))
        guard !steps.isEmpty else { return HTTPResponse(status: 599, data: Data()) }
        switch steps.removeFirst() {
        case .respond(let status, let body):
            return HTTPResponse(status: status, data: body)
        case .fail(let error):
            throw error
        }
    }
}
