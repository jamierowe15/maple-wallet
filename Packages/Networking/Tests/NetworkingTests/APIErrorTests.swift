import Foundation
import Testing
@testable import Networking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

let testURL = URL(string: "https://api.example.test")!

struct APIErrorTests {
    @Test func mapsNoConnectionToOffline() {
        #expect(APIError(transportError: URLError(.notConnectedToInternet)) == .offline)
        #expect(APIError(transportError: URLError(.timedOut)) == .offline)
    }

    @Test func mapsCancellation() {
        #expect(APIError(transportError: CancellationError()) == .cancelled)
        #expect(APIError(transportError: URLError(.cancelled)) == .cancelled)
    }

    @Test(arguments: [400, 403, 404, 422, 500, 503])
    func mapsHTTPStatusToServerError(status: Int) async {
        let client = APIClient(baseURL: testURL,
                               transport: ScriptedTransport([.respond(status: status, body: Data())]),
                               retryPolicy: .none)
        await #expect(throws: APIError.server(status: status)) {
            try await client.send(Endpoint<[Int]>(path: "/numbers"))
        }
    }

    @Test func mapsBadJSONToDecoding() async {
        let client = APIClient(baseURL: testURL,
                               transport: ScriptedTransport([.respond(status: 200, body: Data("{oops".utf8))]),
                               retryPolicy: .none)
        await #expect(throws: APIError.decoding) {
            try await client.send(Endpoint<[Int]>(path: "/numbers"))
        }
    }

    @Test func onlyOfflineAnd5xxAreRetryable() {
        #expect(APIError.offline.isRetryable)
        #expect(APIError.server(status: 503).isRetryable)
        #expect(!APIError.server(status: 404).isRetryable)
        #expect(!APIError.unauthorized.isRetryable)
        #expect(!APIError.decoding.isRetryable)
        #expect(!APIError.cancelled.isRetryable)
    }

    @Test func everyErrorHasFriendlyCopyExceptCancel() {
        for error in [APIError.offline, .unauthorized, .server(status: 500), .decoding] {
            #expect(error.userFacingError != nil)
        }
        #expect(APIError.cancelled.userFacingError == nil)
        #expect(APIError.unauthorized.userFacingError?.canRetry == false)
    }
}
