import Foundation
import Testing
@testable import Core

struct MoneyTests {
    @Test func amountIsExactDecimal() {
        #expect(Money(minorUnits: 4215).amount == Decimal(string: "42.15"))
    }

    @Test(arguments: zip(
        [Int64(0), 4215, -4215, 123_456_789],
        ["0.00", "42.15", "42.15", "1,234,567.89"]
    ))
    func formatsCanadianDollars(minorUnits: Int64, expectedDigits: String) {
        #expect(Money(minorUnits: minorUnits).formatted().contains(expectedDigits))
    }

    @Test func negativeAmountsShowASign() {
        #expect(Money(minorUnits: -4215).formatted().contains("-"))
    }

    @Test func comparesAndAdds() {
        #expect(Money(minorUnits: 100) < Money(minorUnits: 200))
        #expect(Money(minorUnits: 100) + Money(minorUnits: 50) == Money(minorUnits: 150))
    }

    @Test func creditMeansMoneyIn() {
        #expect(Transaction.samples.first { $0.id == "t-100" }?.isCredit == true)
        #expect(Transaction.samples.first { $0.id == "t-101" }?.isCredit == false)
    }
}
