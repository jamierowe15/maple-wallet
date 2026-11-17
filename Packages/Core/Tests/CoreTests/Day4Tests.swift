import Foundation
import Testing
@testable import Core

struct MoneyParsingTests {
    @Test(arguments: zip(
        ["42", "42.5", "42.50", "$1,234.56", ".99", " 7 ", "0.01"],
        [Int64(4200), 4250, 4250, 123_456, 99, 700, 1]
    ))
    func parsesValidInput(text: String, expectedCents: Int64) {
        #expect(Money(parsing: text)?.minorUnits == expectedCents)
    }

    @Test(arguments: ["", "abc", "-5", "1.234", "1.2.3", "12a", "٣"])
    func rejectsInvalidInput(_ text: String) {
        #expect(Money(parsing: text) == nil)
    }

    @Test func plainStringRoundTrips() {
        #expect(Money(minorUnits: 4205).plainString == "42.05")
        #expect(Money(parsing: Money(minorUnits: 123_456).plainString)?.minorUnits == 123_456)
    }
}

struct SpokenMoneyTests {
    @Test func speaksDebits() {
        #expect(Money(minorUnits: -4215).spokenDescription() == "minus forty-two dollars fifteen cents")
    }

    @Test func usesSingularForOne() {
        #expect(Money(minorUnits: 101).spokenDescription() == "one dollar one cent")
    }

    @Test func dropsZeroCents() {
        #expect(Money(minorUnits: 2500).spokenDescription() == "twenty-five dollars")
    }
}

struct DeepLinkRouterTests {
    private let router = DeepLinkRouter()

    @Test(arguments: zip(
        [
            "maplewallet://accounts",
            "maplewallet://accounts/chq-001",
            "maplewallet://accounts/chq-001/transactions/t-100",
            "maplewallet://transfer",
            "https://maplewallet.example/accounts/sav-002",
        ],
        [
            Route.accounts,
            .account(id: "chq-001"),
            .transaction(accountID: "chq-001", id: "t-100"),
            .transfer,
            .account(id: "sav-002"),
        ]
    ))
    func routesKnownLinks(link: String, expected: Route) {
        #expect(router.route(for: URL(string: link)!) == expected)
    }

    @Test(arguments: [
        "maplewallet://settings",
        "https://evil.example/accounts/chq-001",
        "http://maplewallet.example/accounts/chq-001",
        "otherapp://accounts",
    ])
    func ignoresUnknownLinks(_ link: String) {
        #expect(router.route(for: URL(string: link)!) == nil)
    }
}
