import Foundation
#if canImport(CryptoKit)
import CryptoKit
#else
import Crypto
#endif

/// The set of server public keys we trust, stored as base64 SHA-256 hashes.
/// Pin at least two keys (current + backup) so a key rotation can't lock users out.
public struct PinSet: Sendable, Equatable {
    public let hashes: Set<String>

    public init(hashes: Set<String>) {
        self.hashes = hashes
    }

    public static func hash(ofPublicKey keyData: Data) -> String {
        Data(SHA256.hash(data: keyData)).base64EncodedString()
    }

    public func trusts(publicKey keyData: Data) -> Bool {
        hashes.contains(Self.hash(ofPublicKey: keyData))
    }
}

#if canImport(Security)
import Security

/// URLSession delegate that rejects any server whose leaf key isn't pinned.
/// Hashes the raw key from SecKeyCopyExternalRepresentation (not full SPKI): see docs/security.md.
public final class PinnedSessionDelegate: NSObject, URLSessionDelegate, Sendable {
    private let pins: PinSet

    public init(pins: PinSet) {
        self.pins = pins
    }

    public func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge
    ) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust,
              SecTrustEvaluateWithError(trust, nil),
              let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let leaf = chain.first,
              let key = SecCertificateCopyKey(leaf),
              let keyData = SecKeyCopyExternalRepresentation(key, nil) as Data?,
              pins.trusts(publicKey: keyData)
        else {
            return (.cancelAuthenticationChallenge, nil)
        }
        return (.useCredential, URLCredential(trust: trust))
    }
}
#endif
