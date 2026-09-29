import SwiftUI
import UIKit

// Identitate vizuală „stadion nocturn” — aceleași culori ca style.css
// (temă întunecată implicit, cu variantă luminoasă).

extension UIColor {
    convenience init(hex: UInt32) {
        self.init(red: CGFloat((hex >> 16) & 0xFF) / 255,
                  green: CGFloat((hex >> 8) & 0xFF) / 255,
                  blue: CGFloat(hex & 0xFF) / 255,
                  alpha: 1)
    }
}

extension Color {
    static func dynamic(dark: UInt32, light: UInt32) -> Color {
        Color(UIColor { traits in
            traits.userInterfaceStyle == .light ? UIColor(hex: light) : UIColor(hex: dark)
        })
    }

    static let hwcBackground = dynamic(dark: 0x0A0F0D, light: 0xF3F1E7)
    static let hwcPanel = dynamic(dark: 0x121A16, light: 0xFFFFFF)
    static let hwcPanel2 = dynamic(dark: 0x182620, light: 0xF0ECE0)
    static let hwcPitch = dynamic(dark: 0x1F8A4C, light: 0x1F8A4C)
    static let hwcPitch2 = dynamic(dark: 0x2FB361, light: 0x17703C)
    static let hwcGold = dynamic(dark: 0xE0B84B, light: 0xA97C13)
    static let hwcGold2 = dynamic(dark: 0xF4D37A, light: 0x8A6410)
    static let hwcRed = dynamic(dark: 0xD1453B, light: 0xB23127)
    static let hwcText = dynamic(dark: 0xEEF4EF, light: 0x14211A)
    static let hwcTextDim = dynamic(dark: 0xA9B8AE, light: 0x4C5E53)
    static let hwcBorder = dynamic(dark: 0x26362D, light: 0xDDD6C0)
}

extension Font {
    /// Tipografie condensată tip tablă de scor, pentru titluri.
    static func scoreboard(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight).width(.condensed)
    }

    /// Monospace pentru scoruri și statistici.
    static func stat(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

enum AppTheme: String, CaseIterable {
    case dark, light, system

    var colorScheme: ColorScheme? {
        switch self {
        case .dark: return .dark
        case .light: return .light
        case .system: return nil
        }
    }

    var next: AppTheme {
        switch self {
        case .dark: return .light
        case .light: return .system
        case .system: return .dark
        }
    }

    var icon: String {
        switch self {
        case .dark: return "moon.fill"
        case .light: return "sun.max.fill"
        case .system: return "circle.lefthalf.filled"
        }
    }
}
