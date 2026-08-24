import SwiftUI
import UIKit

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }

    init(hexString string: String, alpha: Double = 1) {
        var sanitized = string.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") { sanitized.removeFirst() }
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        if sanitized.count == 8 {
            self.init(hex: UInt((value >> 8) & 0xFFFFFF), alpha: Double(value & 0xFF) / 255 * alpha)
        } else {
            self.init(hex: UInt(value & 0xFFFFFF), alpha: alpha)
        }
    }

    static let ink = Color(hex: 0x0A0A0E)
    static let panel = Color(hex: 0x121218)
    static let panelHi = Color(hex: 0x1B1B23)
    static let valRed = Color(hex: 0xFF4655)
    static let cream = Color(hex: 0xECE8E1)
    static let mint = Color(hex: 0x8CE3E9)
    static let gold = Color(hex: 0xF2C94C)
    static let dim = Color.white.opacity(0.55)
    static let faint = Color.white.opacity(0.28)
    static let line = Color.white.opacity(0.08)
}

/// Lets `.cream`, `.valRed`, `.dim` … resolve in `foregroundStyle`,
/// `fill`, `stroke` and every other `some ShapeStyle` context.
extension ShapeStyle where Self == Color {
    static var ink: Color { .ink }
    static var panel: Color { .panel }
    static var panelHi: Color { .panelHi }
    static var valRed: Color { .valRed }
    static var cream: Color { .cream }
    static var mint: Color { .mint }
    static var gold: Color { .gold }
    static var dim: Color { .dim }
    static var faint: Color { .faint }
    static var line: Color { .line }
}

extension Font {
    static func display(_ size: CGFloat, _ weight: UIFont.Weight = .black) -> Font {
        Font(UIFont.systemFont(ofSize: size, weight: weight, width: .condensed))
    }

    static func mono(_ size: CGFloat, _ weight: UIFont.Weight = .medium) -> Font {
        Font(UIFont.monospacedSystemFont(ofSize: size, weight: weight))
    }
}

enum Haptics {
    static func tap() {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func thud() {
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
    }

    static func win() {
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}

extension String {
    var cleanedEnum: String {
        split(separator: ":").last.map(String.init) ?? self
    }

    var isoDate: Date? {
        let fractional = ISO8601DateFormatter()
        fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let plain = ISO8601DateFormatter()
        return fractional.date(from: self) ?? plain.date(from: self)
    }
}

extension Date {
    var stampText: String {
        formatted(.dateTime.month(.abbreviated).day().year())
    }
}
