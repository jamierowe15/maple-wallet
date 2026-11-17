/// An error written for a person, not a developer.
public struct UserFacingError: Error, Sendable, Equatable {
    public let title: String
    public let message: String
    public let canRetry: Bool

    public init(title: String, message: String, canRetry: Bool) {
        self.title = title
        self.message = message
        self.canRetry = canRetry
    }

    public static let generic = UserFacingError(
        title: "Something went wrong",
        message: "Please try again in a moment.",
        canRetry: true
    )

    /// Turns any error into copy for the UI. Returns nil for cancellations,
    /// which should never show an alert.
    public static func from(_ error: any Error) -> UserFacingError? {
        if error is CancellationError { return nil }
        if let convertible = error as? any UserFacingErrorConvertible { return convertible.userFacingError }
        if let alreadyFriendly = error as? UserFacingError { return alreadyFriendly }
        return .generic
    }
}

public protocol UserFacingErrorConvertible: Error {
    /// nil means "stay silent", for example a cancelled request.
    var userFacingError: UserFacingError? { get }
}
