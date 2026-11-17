import Core

public enum AuthError: Error, Equatable, Sendable {
    case stateMismatch
    case missingCode
    case userCancelled
    case notSignedIn
    case provider(String)
    case tokenExchangeFailed(status: Int)
}

extension AuthError: UserFacingErrorConvertible {
    public var userFacingError: UserFacingError? {
        switch self {
        case .userCancelled:
            nil
        case .notSignedIn:
            UserFacingError(title: "Please sign in", message: "Your session has ended.", canRetry: false)
        case .stateMismatch, .missingCode, .provider, .tokenExchangeFailed:
            UserFacingError(title: "We couldn't sign you in",
                            message: "Please try again. If it keeps happening, contact support.", canRetry: true)
        }
    }
}
