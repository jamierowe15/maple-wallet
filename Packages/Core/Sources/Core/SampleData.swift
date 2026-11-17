import Foundation

public extension Account {
    static let samples: [Account] = [
        Account(id: "chq-001", name: "Everyday Chequing", kind: .chequing,
                balance: Money(minorUnits: 1_234_56), lastFour: "4821"),
        Account(id: "sav-002", name: "High Interest Savings", kind: .savings,
                balance: Money(minorUnits: 8_250_00), lastFour: "1177"),
        Account(id: "cc-003", name: "Maple Rewards Visa", kind: .credit,
                balance: Money(minorUnits: -412_89), lastFour: "9034"),
    ]
}

public extension Transaction {
    private static let base = Date(timeIntervalSince1970: 1_793_000_000)

    static let samples: [Transaction] = [
        Transaction(id: "t-100", accountID: "chq-001", merchant: "Payroll deposit", category: "Income",
                    amount: Money(minorUnits: 2_150_00), date: base),
        Transaction(id: "t-101", accountID: "chq-001", merchant: "Groceries", category: "Food",
                    amount: Money(minorUnits: -42_15), date: base.addingTimeInterval(-86_400)),
        Transaction(id: "t-102", accountID: "chq-001", merchant: "TTC fare", category: "Transit",
                    amount: Money(minorUnits: -3_30), date: base.addingTimeInterval(-2 * 86_400)),
        Transaction(id: "t-103", accountID: "chq-001", merchant: "Coffee", category: "Food",
                    amount: Money(minorUnits: -5_45), date: base.addingTimeInterval(-3 * 86_400)),
        Transaction(id: "t-200", accountID: "sav-002", merchant: "Interest", category: "Income",
                    amount: Money(minorUnits: 18_04), date: base.addingTimeInterval(-5 * 86_400)),
        Transaction(id: "t-300", accountID: "cc-003", merchant: "Bookstore", category: "Shopping",
                    amount: Money(minorUnits: -64_99), date: base.addingTimeInterval(-86_400)),
    ]
}
