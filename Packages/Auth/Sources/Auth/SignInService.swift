import Foundation

/// Opens the system web login and returns the redirect URL.
public protocol WebAuthenticating: Sendable {
    @MainActor func authenticate(url: URL, callbackScheme: String) async throws -> URL
}

/// Runs the whole Authorization Code + PKCE flow.
public struct SignInService: Sendable {
    private let configuration: AuthConfiguration
    private let authenticator: any WebAuthenticating
    private let exchanger: any TokenExchanging
    private let store: any TokenStore

    public init(configuration: AuthConfiguration,
                authenticator: any WebAuthenticating,
                exchanger: any TokenExchanging,
                store: any TokenStore) {
        self.configuration = configuration
        self.authenticator = authenticator
        self.exchanger = exchanger
        self.store = store
    }

    @MainActor
    public func signIn() async throws {
        let request = AuthorizationRequest(configuration: configuration)
        let callback = try await authenticator.authenticate(url: request.url,
                                                            callbackScheme: configuration.callbackScheme)
        let code = try CallbackValidator.authorizationCode(from: callback, expectedState: request.state)
        let tokens = try await exchanger.exchange(code: code, verifier: request.pkce.verifier)
        try await store.save(tokens)
    }

    public func signOut() async {
        await store.clear()
    }

    public func isSignedIn() async -> Bool {
        await store.load() != nil
    }
}
