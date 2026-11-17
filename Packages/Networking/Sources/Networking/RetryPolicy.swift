/// Exponential backoff. `delays.count` is the number of RETRIES after the first attempt.
public struct RetryPolicy: Sendable, Equatable {
    public var delays: [Duration]

    public init(delays: [Duration]) {
        self.delays = delays
    }

    /// 3 retries: wait 0.5 s, then 1 s, then 2 s.
    public static let standard = RetryPolicy(delays: [.milliseconds(500), .seconds(1), .seconds(2)])
    public static let none = RetryPolicy(delays: [])
}
