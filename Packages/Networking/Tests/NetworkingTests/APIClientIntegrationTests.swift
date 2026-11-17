import Core
import Foundation
import Testing
@testable import Networking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Fake token provider: "old" is rejected by the server, refresh hands out "new".
actor FakeTokens: AccessTokenProviding {
    private var current = "old"
    private(set) var refreshes = 0

    func validToken() async throws -> String { current }

    func refreshToken(rejecting rejectedToken: String) async throws -> String {
        if current == rejectedToken {
            refreshes += 1
            current = "new"
        }
        return current
    }
}

actor HeaderSpy: HTTPTransport {
    private(set) var contentType: String?

    func send(_ request: URLRequest) async throws -> HTTPResponse {
        contentType = request.value(forHTTPHeaderField: "Content-Type")
        return HTTPResponse(status: 200, data: Data("[]".utf8))
    }
}

struct APIClientIntegrationTests {
    @Test func refreshesOnceThenRetriesWithNewToken() async throws {
        let transport = ScriptedTransport([
            .respond(status: 401, body: Data()),
            .respond(status: 200, body: Data("[7]".utf8)),
        ])
        let tokens = FakeTokens()
        let client = APIClient(baseURL: testURL, transport: transport, retryPolicy: .none, tokens: tokens)

        #expect(try await client.send(Endpoint<[Int]>(path: "/accounts")) == [7])
        #expect(await tokens.refreshes == 1)
        #expect(await transport.authorizationHeaders == ["Bearer old", "Bearer new"])
    }

    @Test func secondUnauthorizedGivesUp() async {
        let transport = ScriptedTransport([
            .respond(status: 401, body: Data()),
            .respond(status: 401, body: Data()),
        ])
        let client = APIClient(baseURL: testURL, transport: transport, retryPolicy: .none, tokens: FakeTokens())
        await #expect(throws: APIError.unauthorized) {
            try await client.send(Endpoint<[Int]>(path: "/accounts"))
        }
        #expect(await transport.requestCount == 2)
    }

    @Test func decodingFailureIsReported() async {
        let transport = ScriptedTransport([.respond(status: 200, body: Data(#"{"not":"an array"}"#.utf8))])
        let client = APIClient(baseURL: testURL, transport: transport, retryPolicy: .none)
        await #expect(throws: APIError.decoding) {
            try await client.send(Endpoint<[Int]>(path: "/accounts"))
        }
    }

    @Test func sendsJSONHeadersForBodies() async throws {
        let spy = HeaderSpy()
        let client = APIClient(baseURL: testURL, transport: spy, retryPolicy: .none)
        _ = try await client.send(Endpoint<[Int]>(method: "POST", path: "/transfers", body: Data("{}".utf8)))
        #expect(await spy.contentType == "application/json")
    }

    #if canImport(Darwin)
    @Test func worksThroughRealURLSessionWithStubProtocol() async throws {
        StubURLProtocol.routes = ["/accounts": (200, Data("[1,2,3]".utf8))]
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [StubURLProtocol.self]
        let client = APIClient(baseURL: testURL, transport: URLSessionTransport(session: URLSession(configuration: config)),
                               retryPolicy: .none)
        #expect(try await client.send(Endpoint<[Int]>(path: "/accounts")) == [1, 2, 3])
    }
    #endif
}
