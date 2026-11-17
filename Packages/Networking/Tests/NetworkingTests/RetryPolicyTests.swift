import Foundation
import Testing
@testable import Networking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

actor SleepLog {
    private(set) var delays: [Duration] = []
    func record(_ delay: Duration) { delays.append(delay) }
}

struct RetryPolicyTests {
    private let offline = ScriptedTransport.Step.fail(URLError(.notConnectedToInternet))
    private let ok = ScriptedTransport.Step.respond(status: 200, body: Data("[1,2]".utf8))

    @Test func retriesOfflineWithExponentialBackoff() async throws {
        let transport = ScriptedTransport([offline, offline, offline, ok])
        let log = SleepLog()
        let client = APIClient(baseURL: testURL, transport: transport, sleep: { await log.record($0) })

        let numbers = try await client.send(Endpoint<[Int]>(path: "/numbers"))

        #expect(numbers == [1, 2])
        #expect(await transport.requestCount == 4)
        #expect(await log.delays == [.milliseconds(500), .seconds(1), .seconds(2)])
    }

    @Test func givesUpAfterThreeRetries() async {
        let transport = ScriptedTransport([offline, offline, offline, offline, ok])
        let client = APIClient(baseURL: testURL, transport: transport, sleep: { _ in })

        await #expect(throws: APIError.offline) {
            try await client.send(Endpoint<[Int]>(path: "/numbers"))
        }
        #expect(await transport.requestCount == 4)
    }

    @Test func retries5xx() async throws {
        let transport = ScriptedTransport([.respond(status: 503, body: Data()), ok])
        let client = APIClient(baseURL: testURL, transport: transport, sleep: { _ in })
        _ = try await client.send(Endpoint<[Int]>(path: "/numbers"))
        #expect(await transport.requestCount == 2)
    }

    @Test func neverRetries4xx() async {
        let transport = ScriptedTransport([.respond(status: 400, body: Data()), ok])
        let client = APIClient(baseURL: testURL, transport: transport, sleep: { _ in })
        await #expect(throws: APIError.server(status: 400)) {
            try await client.send(Endpoint<[Int]>(path: "/numbers"))
        }
        #expect(await transport.requestCount == 1)
    }

    @Test func stopsRetryingWhenCancelled() async {
        let transport = ScriptedTransport([offline, ok])
        let client = APIClient(baseURL: testURL, transport: transport, sleep: { _ in throw CancellationError() })
        await #expect(throws: APIError.cancelled) {
            try await client.send(Endpoint<[Int]>(path: "/numbers"))
        }
    }
}
