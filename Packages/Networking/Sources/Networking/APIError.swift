import Core
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// Every network failure the app can see, in one place.
public enum APIError: Error, Equatable, Sendable {
    case offline
    case unauthorized
    case server(status: Int)
    case decoding
    case cancelled

    /// Retry only when trying again could help: no connection, or the server's fault (5xx).
    /// Never retry 4xx: the request itself is wrong.
    public var isRetryable: Bool {
        switch self {
        case .offline: true
        case .server(let status): status >= 500
        case .unauthorized, .decoding, .cancelled: false
        }
    }

    public init(transportError error: any Error) {
        if let apiError = error as? APIError { self = apiError; return }
        if error is CancellationError { self = .cancelled; return }
        if let urlError = error as? URLError, urlError.code == .cancelled { self = .cancelled; return }
        self = .offline
    }
}

extension APIError: UserFacingErrorConvertible {
    public var userFacingError: UserFacingError? {
        switch self {
        case .offline:
            UserFacingError(title: "You're offline",
                            message: "Check your connection and try again.", canRetry: true)
        case .unauthorized:
            UserFacingError(title: "Please sign in again",
                            message: "For your security, your session has ended.", canRetry: false)
        case .server:
            UserFacingError(title: "We're having trouble",
                            message: "Something went wrong on our side. Please try again in a moment.", canRetry: true)
        case .decoding:
            UserFacingError(title: "Something went wrong",
                            message: "We couldn't read the latest information. Please try again.", canRetry: true)
        case .cancelled:
            nil
        }
    }
}
