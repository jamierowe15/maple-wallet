import Core
import Foundation
import Networking

public protocol TransfersService: Sendable {
    /// Returns a confirmation number.
    func submit(from: Account.ID, to: Account.ID, amount: Money) async throws -> String
}

public struct RemoteTransfersService: TransfersService {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    private struct Body: Encodable {
        let fromAccountID: String
        let toAccountID: String
        let amount: Money
    }

    private struct Receipt: Decodable, Sendable {
        let confirmation: String
    }

    public func submit(from: Account.ID, to: Account.ID, amount: Money) async throws -> String {
        let body = try JSONEncoder().encode(Body(fromAccountID: from, toAccountID: to, amount: amount))
        return try await client.send(Endpoint<Receipt>(method: "POST", path: "/transfers", body: body)).confirmation
    }
}

public struct MockTransfersService: TransfersService {
    public var result: Result<String, UserFacingError>
    public var delay: Duration

    public init(result: Result<String, UserFacingError> = .success("MW-482910"), delay: Duration = .milliseconds(400)) {
        self.result = result
        self.delay = delay
    }

    public func submit(from: Account.ID, to: Account.ID, amount: Money) async throws -> String {
        try await Task.sleep(for: delay)
        return try result.get()
    }
}
