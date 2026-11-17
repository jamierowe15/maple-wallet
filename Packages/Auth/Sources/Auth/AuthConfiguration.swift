import Foundation

public struct AuthConfiguration: Sendable, Equatable {
    public var authorizeURL: URL
    public var tokenURL: URL
    public var clientID: String
    public var redirectURI: String
    public var scopes: [String]
    public var audience: String?
    public var isStub: Bool

    public var callbackScheme: String {
        URLComponents(string: redirectURI)?.scheme ?? "maplewallet"
    }

    public static func auth0(domain: String, clientID: String, audience: String? = nil) -> AuthConfiguration {
        AuthConfiguration(
            authorizeURL: URL(string: "https://\(domain)/authorize")!,
            tokenURL: URL(string: "https://\(domain)/oauth/token")!,
            clientID: clientID,
            redirectURI: "maplewallet://callback",
            scopes: ["openid", "profile", "email", "offline_access"],
            audience: audience,
            isStub: false
        )
    }

    /// No tenant needed: the stub authenticator fakes the login page and token exchange.
    public static let stub = AuthConfiguration(
        authorizeURL: URL(string: "https://auth.maplewallet.example/authorize")!,
        tokenURL: URL(string: "https://auth.maplewallet.example/oauth/token")!,
        clientID: "stub-client",
        redirectURI: "maplewallet://callback",
        scopes: ["openid", "offline_access"],
        audience: nil,
        isStub: true
    )
}

/// Everything needed to start one sign-in attempt.
public struct AuthorizationRequest: Sendable {
    public let url: URL
    public let state: String
    public let pkce: PKCE

    public init(configuration: AuthConfiguration,
                pkce: PKCE = .generate(),
                state: String = PKCE.randomURLSafeString(byteCount: 16)) {
        self.pkce = pkce
        self.state = state
        var components = URLComponents(url: configuration.authorizeURL, resolvingAgainstBaseURL: false)!
        var items = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: configuration.clientID),
            URLQueryItem(name: "redirect_uri", value: configuration.redirectURI),
            URLQueryItem(name: "scope", value: configuration.scopes.joined(separator: " ")),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "code_challenge", value: pkce.challenge),
            URLQueryItem(name: "code_challenge_method", value: pkce.method),
        ]
        if let audience = configuration.audience {
            items.append(URLQueryItem(name: "audience", value: audience))
        }
        components.queryItems = items
        self.url = components.url!
    }
}

public enum CallbackValidator {
    /// Pulls the authorization code out of the redirect, rejecting it if `state` doesn't match.
    /// A mismatched state means the callback wasn't started by us (CSRF / injected code).
    public static func authorizationCode(from callback: URL, expectedState: String) throws(AuthError) -> String {
        let items = URLComponents(url: callback, resolvingAgainstBaseURL: false)?.queryItems ?? []
        func value(_ name: String) -> String? { items.first { $0.name == name }?.value }

        if let providerError = value("error") { throw .provider(providerError) }
        guard let state = value("state"), state == expectedState else { throw .stateMismatch }
        guard let code = value("code"), !code.isEmpty else { throw .missingCode }
        return code
    }
}
