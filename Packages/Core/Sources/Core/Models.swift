import Foundation

public struct Account: Sendable, Codable, Hashable, Identifiable {
    public enum Kind: String, Sendable, Codable, Hashable {
        case chequing, savings, credit
    }

    public let id: String
    public let name: String
    public let kind: Kind
    public let balance: Money
    public let lastFour: String

    public init(id: String, name: String, kind: Kind, balance: Money, lastFour: String) {
        self.id = id
        self.name = name
        self.kind = kind
        self.balance = balance
        self.lastFour = lastFour
    }
}

public struct Transaction: Sendable, Codable, Hashable, Identifiable {
    public let id: String
    public let accountID: Account.ID
    public let merchant: String
    public let category: String
    public let amount: Money
    public let date: Date

    public init(id: String, accountID: Account.ID, merchant: String, category: String, amount: Money, date: Date) {
        self.id = id
        self.accountID = accountID
        self.merchant = merchant
        self.category = category
        self.amount = amount
        self.date = date
    }

    /// Money coming in. Never show this with colour alone: pair it with a sign and an icon.
    public var isCredit: Bool { amount.minorUnits > 0 }
}
