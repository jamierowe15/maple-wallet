#if canImport(UIKit)
import SwiftUI
import UIKit

public enum Spacing {
    public static let xs: CGFloat = 4
    public static let s: CGFloat = 8
    public static let m: CGFloat = 16
    public static let l: CGFloat = 24
    public static let xl: CGFloat = 32
}

public enum Radius {
    public static let card: CGFloat = 16
    public static let button: CGFloat = 12
}

/// Semantic colours. Each one adapts to Dark Mode AND Increase Contrast.
/// (Built in code rather than an asset catalog so package previews work;
/// see docs/adr/0001-modular-spm.md if you change that.)
public enum Palette {
    public static let brand = Color.dynamic(light: 0xB3261E, dark: 0xD32F2F, highContrastLight: 0x8B0000, highContrastDark: 0xB71C1C)
    public static let credit = Color.dynamic(light: 0x1B6E3A, dark: 0x7FD49A, highContrastLight: 0x0B4A22, highContrastDark: 0xB9F6CA)
    public static let debit = Color.dynamic(light: 0x3C3C43, dark: 0xEBEBF5, highContrastLight: 0x000000, highContrastDark: 0xFFFFFF)
    public static let surface = Color(uiColor: .secondarySystemBackground)
    public static let textPrimary = Color(uiColor: .label)
    /// Darker than the system's secondaryLabel so it passes the accessibility audit's contrast check.
    public static let textSecondary = Color.dynamic(light: 0x545458, dark: 0xC7C7CC, highContrastLight: 0x3A3A3C, highContrastDark: 0xE5E5EA)
}

extension Color {
    static func dynamic(light: UInt32, dark: UInt32, highContrastLight: UInt32, highContrastDark: UInt32) -> Color {
        Color(uiColor: UIColor { traits in
            let isDark = traits.userInterfaceStyle == .dark
            let isHighContrast = traits.accessibilityContrast == .high
            switch (isDark, isHighContrast) {
            case (false, false): return UIColor(hex: light)
            case (true, false): return UIColor(hex: dark)
            case (false, true): return UIColor(hex: highContrastLight)
            case (true, true): return UIColor(hex: highContrastDark)
            }
        })
    }
}

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
#endif
