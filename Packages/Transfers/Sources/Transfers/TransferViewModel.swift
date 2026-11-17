import Core
import Foundation
import Observation

@Observable @MainActor
public final class TransferViewModel {
    public enum Phase: Equatable {
        case editing
        case reviewing
        case submitting
        case done(confirmation: String)
        case failed(UserFacingError)
    }

    public let accounts: [Account]
    public var fromID: Account.ID?
    public var toID: Account.ID?
    public var amountText: String
    public private(set) var phase: Phase = .editing

    private let service: any TransfersService

    public init(accounts: [Account], service: any TransfersService, prefillAmount: Money? = nil) {
        self.accounts = accounts
        self.service = service
        let from = accounts.first { $0.kind != .credit }
        fromID = from?.id
        toID = accounts.first { $0.id != from?.id }?.id
        amountText = prefillAmount?.magnitude.plainString ?? ""
    }

    public var from: Account? { accounts.first { $0.id == fromID } }
    public var to: Account? { accounts.first { $0.id == toID } }
    public var amount: Money? { Money(parsing: amountText) }

    /// Plain-language reason the transfer can't go yet, or nil if it can.
    public var validationMessage: String? {
        guard let from, let to else { return "Choose an account to send from and one to send to." }
        if from.id == to.id { return "Choose two different accounts." }
        guard let amount, amount.minorUnits > 0 else { return "Enter an amount greater than zero." }
        if amount > from.balance { return "That's more than the balance in \(from.name)." }
        return nil
    }

    public var canReview: Bool { validationMessage == nil }

    public func review() {
        guard canReview else { return }
        phase = .reviewing
    }

    public func edit() {
        phase = .editing
    }

    public func confirm() async {
        guard canReview, let from, let to, let amount else { return }
        phase = .submitting
        do {
            let confirmation = try await service.submit(from: from.id, to: to.id, amount: amount)
            phase = .done(confirmation: confirmation)
        } catch {
            phase = UserFacingError.from(error).map(Phase.failed) ?? .reviewing
        }
    }

    public func startOver() {
        amountText = ""
        phase = .editing
    }
}
