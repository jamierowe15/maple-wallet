/// Lets the network layer attach and refresh tokens without depending on Auth.
/// Implemented by `Auth.TokenProvider` on Day 3.
public protocol AccessTokenProviding: Sendable {
    /// A token that is not known to be expired.
    func validToken() async throws -> String
    /// Called after the server rejected `rejectedToken` with a 401.
    /// Must refresh at most once, however many requests failed at the same time.
    func refreshToken(rejecting rejectedToken: String) async throws -> String
}
