#if canImport(UIKit)
import Core
import DesignSystem

extension TransactionRow {
    init(_ transaction: Transaction) {
        let formatted = transaction.amount.formatted()
        self.init(
            merchant: transaction.merchant,
            detail: "\(transaction.category), \(transaction.date.formatted(date: .abbreviated, time: .omitted))",
            amount: transaction.isCredit ? "+\(formatted)" : formatted,
            isCredit: transaction.isCredit,
            spokenAmount: transaction.amount.spokenDescription()
        )
    }
}
#endif
