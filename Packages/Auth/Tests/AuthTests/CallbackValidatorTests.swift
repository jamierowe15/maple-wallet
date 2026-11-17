import Foundation
import Testing
@testable import Auth

struct CallbackValidatorTests {
    @Test func returnsCodeWhenStateMatches() throws {
        let url = URL(string: "maplewallet://callback?code=abc&state=xyz")!
        #expect(try CallbackValidator.authorizationCode(from: url, expectedState: "xyz") == "abc")
    }

    @Test func rejectsStateMismatch() {
        let url = URL(string: "maplewallet://callback?code=abc&state=attacker")!
        #expect(throws: AuthError.stateMismatch) {
            try CallbackValidator.authorizationCode(from: url, expectedState: "xyz")
        }
    }

    @Test func rejectsMissingState() {
        let url = URL(string: "maplewallet://callback?code=abc")!
        #expect(throws: AuthError.stateMismatch) {
            try CallbackValidator.authorizationCode(from: url, expectedState: "xyz")
        }
    }

    @Test func rejectsMissingCode() {
        let url = URL(string: "maplewallet://callback?state=xyz")!
        #expect(throws: AuthError.missingCode) {
            try CallbackValidator.authorizationCode(from: url, expectedState: "xyz")
        }
    }

    @Test func surfacesProviderError() {
        let url = URL(string: "maplewallet://callback?error=access_denied&state=xyz")!
        #expect(throws: AuthError.provider("access_denied")) {
            try CallbackValidator.authorizationCode(from: url, expectedState: "xyz")
        }
    }

    @Test func authorizeURLCarriesPKCEAndState() {
        let request = AuthorizationRequest(configuration: .stub)
        let items = URLComponents(url: request.url, resolvingAgainstBaseURL: false)?.queryItems ?? []
        #expect(items.contains(URLQueryItem(name: "code_challenge", value: request.pkce.challenge)))
        #expect(items.contains(URLQueryItem(name: "code_challenge_method", value: "S256")))
        #expect(items.contains(URLQueryItem(name: "state", value: request.state)))
        #expect(!items.contains { $0.name == "client_secret" })
    }
}
