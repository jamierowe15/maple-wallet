import Core
import Foundation
import Networking
import Testing
@testable import Auth

struct OAuthTokenClientTests {
    private let fixedNow = Date(timeIntervalSince1970: 1_800_000_000)

    private func client(_ steps: [ScriptedTransport.Step]) -> (OAuthTokenClient, ScriptedTransport) {
        let transport = ScriptedTransport(steps)
        let now = fixedNow
        let client = OAuthTokenClient(configuration: .auth0(domain: "tenant.example.com", clientID: "abc"),
                                      transport: transport, now: { now })
        return (client, transport)
    }

    @Test func exchangesCodeForTokens() async throws {
        let body = Data(#"{"access_token":"a1","refresh_token":"r1","expires_in":3600}"#.utf8)
        let (client, transport) = client([.respond(status: 200, body: body)])
        let tokens = try await client.exchange(code: "code", verifier: "verifier")
        #expect(tokens == TokenSet(accessToken: "a1", refreshToken: "r1", expiresAt: fixedNow.addingTimeInterval(3600)))
        #expect(await transport.requestCount == 1)
    }

    @Test func refreshKeepsTheOldRefreshTokenWhenNoneIsReturned() async throws {
        let body = Data(#"{"access_token":"a2","expires_in":60}"#.utf8)
        let (client, _) = client([.respond(status: 200, body: body)])
        let tokens = try await client.refresh("r-old")
        #expect(tokens.accessToken == "a2")
        #expect(tokens.refreshToken == "r-old")
    }

    @Test func reportsAFailedExchange() async {
        let (client, _) = client([.respond(status: 400, body: Data())])
        await #expect(throws: AuthError.tokenExchangeFailed(status: 400)) {
            try await client.exchange(code: "bad", verifier: "v")
        }
    }
}

struct AuthConfigurationTests {
    @Test func auth0ConfigurationBuildsProviderURLs() {
        let configuration = AuthConfiguration.auth0(domain: "tenant.example.com", clientID: "abc")
        #expect(configuration.authorizeURL.absoluteString == "https://tenant.example.com/authorize")
        #expect(configuration.tokenURL.absoluteString == "https://tenant.example.com/oauth/token")
        #expect(configuration.callbackScheme == "maplewallet")
        #expect(configuration.scopes.contains("offline_access"))
        #expect(!configuration.isStub)
    }

    @Test func audienceIsAddedWhenSet() {
        let configuration = AuthConfiguration.auth0(domain: "tenant.example.com", clientID: "abc", audience: "api")
        let items = URLComponents(url: AuthorizationRequest(configuration: configuration).url,
                                  resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items.contains(URLQueryItem(name: "audience", value: "api")))
    }
}

struct AuthErrorTests {
    @Test func userCancelIsSilent() {
        #expect(AuthError.userCancelled.userFacingError == nil)
    }

    @Test(arguments: [AuthError.stateMismatch, .missingCode, .provider("x"), .tokenExchangeFailed(status: 500)])
    func signInFailuresCanBeRetried(_ error: AuthError) {
        #expect(error.userFacingError?.canRetry == true)
    }

    @Test func signedOutAsksToSignInAgain() {
        #expect(AuthError.notSignedIn.userFacingError?.canRetry == false)
    }
}
