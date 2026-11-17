import Foundation

/// What the app shares with the Home Screen widget through the App Group.
public struct WidgetSnapshot: Codable, Sendable, Equatable {
    public static let appGroup = "group.com.jamierowe.maplewallet"
    public static let defaultsKey = "widgetSnapshot"

    public var accountName: String
    public var balance: Money
    public var updatedAt: Date

    public init(accountName: String, balance: Money, updatedAt: Date) {
        self.accountName = accountName
        self.balance = balance
        self.updatedAt = updatedAt
    }
}
