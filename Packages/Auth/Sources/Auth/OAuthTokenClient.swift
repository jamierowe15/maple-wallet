import Foundation
import Networking
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Talks to the identity provider's /oauth/token endpoint. A public (native) client:
/// there is NO client secret anywhere in the app. PKCE replaces it.
public struct OAuthTokenClient: TokenExchanging, TokenRefreshing {
    private let configuration: AuthConfiguration
    private let transport: any HTTPTransport
    private let now: @Sendable () -> Date

    public init(configuration: AuthConfiguration,
                transport: any HTTPTransport = URLSessionTransport(),
                now: @escaping @Sendable () -> Date = { Date() }) {
        self.configuration = configuration
        self.transport = transport
        self.now = now
    }

    public func exchange(code: String, verifier: String) async throws -> TokenSet {
        try await post([
            "grant_type": "authorization_code",
            "client_id": configuration.clientID,
            "code": code,
            "redirect_uri": configuration.redirectURI,
            "code_verifier": verifier,
        ], previousRefreshToken: nil)
    }

    public func refresh(_ refreshToken: String) async throws -> TokenSet {
        try await post([
            "grant_type": "refresh_token",
            "client_id": configuration.clientID,
            "refresh_token": refreshToken,
        ], previousRefreshToken: refreshToken)
    }

    private struct TokenResponse: Decodable {
        let accessToken: String
        let refreshToken: String?
        let expiresIn: Double

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
            case refreshToken = "refresh_token"
            case expiresIn = "expires_in"
        }
    }

    private func post(_ form: [String: String], previousRefreshToken: String?) async throws -> TokenSet {
        var request = URLRequest(url: configuration.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = Self.formEncode(form)

        let response = try await transport.send(request)
        guard (200..<300).contains(response.status) else {
            throw AuthError.tokenExchangeFailed(status: response.status)
        }
        let body = try JSONDecoder().decode(TokenResponse.self, from: response.data)
        return TokenSet(accessToken: body.accessToken,
                        refreshToken: body.refreshToken ?? previousRefreshToken,
                        expiresAt: now().addingTimeInterval(body.expiresIn))
    }

    static func formEncode(_ form: [String: String]) -> Data {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        let pairs = form.sorted { $0.key < $1.key }.map { key, value in
            "\(key)=\(value.addingPercentEncoding(withAllowedCharacters: allowed) ?? "")"
        }
        return Data(pairs.joined(separator: "&").utf8)
    }
}
