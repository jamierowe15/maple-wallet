import Foundation

public extension Money {
    /// Parses what a person types: "42", "42.5", "$1,234.56", ".99".
    /// Returns nil for negatives, letters or more than two decimal places.
    init?(parsing text: String, currencyCode: String = "CAD") {
        let cleaned = text.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "$", with: "")
            .replacingOccurrences(of: ",", with: "")
        guard !cleaned.isEmpty else { return nil }
        let parts = cleaned.split(separator: ".", omittingEmptySubsequences: false).map(String.init)
        guard parts.count <= 2,
              parts.allSatisfy({ part in part.allSatisfy { $0.isASCII && $0.isNumber } }),
              let whole = Int64(parts[0].isEmpty ? "0" : parts[0]) else { return nil }
        var cents: Int64 = 0
        if parts.count == 2 {
            guard parts[1].count <= 2 else { return nil }
            cents = Int64(parts[1].padding(toLength: 2, withPad: "0", startingAt: 0)) ?? 0
        }
        let (scaled, overflow) = whole.multipliedReportingOverflow(by: 100)
        guard !overflow else { return nil }
        self.init(minorUnits: scaled + cents, currencyCode: currencyCode)
    }

    /// "42.15" with no symbol, for pre-filling a text field.
    var plainString: String {
        let units = magnitude.minorUnits
        let cents = units % 100
        return "\(isNegative ? "-" : "")\(units / 100).\(cents < 10 ? "0" : "")\(cents)"
    }
}
