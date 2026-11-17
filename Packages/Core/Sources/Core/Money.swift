import Foundation

/// An amount of money stored as a whole number of minor units (cents).
/// Never use `Double` for money: 0.1 + 0.2 != 0.3 in binary floating point.
public struct Money: Sendable, Codable, Hashable, Comparable {
    public var minorUnits: Int64
    public var currencyCode: String

    public init(minorUnits: Int64, currencyCode: String = "CAD") {
        self.minorUnits = minorUnits
        self.currencyCode = currencyCode
    }

    public static let zero = Money(minorUnits: 0)

    /// The exact amount as a `Decimal`, e.g. 4215 cents -> 42.15.
    public var amount: Decimal { Decimal(minorUnits) / 100 }

    public var isNegative: Bool { minorUnits < 0 }

    public var magnitude: Money { Money(minorUnits: Swift.abs(minorUnits), currencyCode: currencyCode) }

    public static func < (lhs: Money, rhs: Money) -> Bool {
        precondition(lhs.currencyCode == rhs.currencyCode, "Can't compare different currencies")
        return lhs.minorUnits < rhs.minorUnits
    }

    public static func + (lhs: Money, rhs: Money) -> Money {
        precondition(lhs.currencyCode == rhs.currencyCode, "Can't add different currencies")
        return Money(minorUnits: lhs.minorUnits + rhs.minorUnits, currencyCode: lhs.currencyCode)
    }

    /// "$1,234.56" / "-$42.15" in Canadian English by default.
    public func formatted(locale: Locale = Locale(identifier: "en_CA")) -> String {
        amount.formatted(.currency(code: currencyCode).locale(locale))
    }
}
