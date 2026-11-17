import Foundation

public extension Money {
    /// "minus forty-two dollars fifteen cents": what VoiceOver should say instead of "-$42.15".
    func spokenDescription(locale: Locale = Locale(identifier: "en_CA")) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .spellOut
        formatter.locale = locale
        func words(_ number: Int64) -> String { formatter.string(from: NSNumber(value: number)) ?? "\(number)" }

        let units = magnitude.minorUnits
        let dollars = units / 100
        let cents = units % 100
        var spoken = "\(words(dollars)) \(dollars == 1 ? "dollar" : "dollars")"
        if cents > 0 { spoken += " \(words(cents)) \(cents == 1 ? "cent" : "cents")" }
        return isNegative ? "minus \(spoken)" : spoken
    }
}
