import SwiftUI
import UIKit

/// Native iOS look, Valorant red as the accent.
enum VW {
    static let red = Color(hex: "ff4655")
    static let teal = Color(hex: "3df5c8")
    static let navy = Color(hex: "0f1923")

    /// SF Pro condensed heavy: a native nod to Valorant's condensed type.
    static func title(_ size: CGFloat, weight: Font.Weight = .heavy) -> Font {
        .system(size: size, weight: weight).width(.condensed)
    }
}

extension Color {
    /// Accepts "RRGGBB" or "RRGGBBAA" (the API's own colour format), with or without "#".
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)
        let r, g, b, a: Double
        if s.count == 8 {
            r = Double((v >> 24) & 0xFF) / 255
            g = Double((v >> 16) & 0xFF) / 255
            b = Double((v >> 8) & 0xFF) / 255
            a = Double(v & 0xFF) / 255
        } else {
            r = Double((v >> 16) & 0xFF) / 255
            g = Double((v >> 8) & 0xFF) / 255
            b = Double(v & 0xFF) / 255
            a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

extension View {
    /// Liquid Glass on iOS 26, frosted material before it.
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat = 22, tint: Color? = nil, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(
                interactive ? Glass.regular.tint(tint).interactive() : Glass.regular.tint(tint),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
        } else {
            self.background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
    }

    /// Capsule-shaped glass (chips, small badges, floating labels).
    @ViewBuilder
    func glassCapsule(tint: Color? = nil, interactive: Bool = false) -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(interactive ? Glass.regular.tint(tint).interactive() : Glass.regular.tint(tint), in: Capsule())
        } else {
            self.background(.ultraThinMaterial, in: Capsule())
        }
    }

    /// Prominent glass button on iOS 26, bordered prominent before it.
    @ViewBuilder
    func glassProminentButton() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glassProminent)
        } else {
            self.buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    func glassButton() -> some View {
        if #available(iOS 26.0, *) {
            self.buttonStyle(.glass)
        } else {
            self.buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    func minimizingTabBar() -> some View {
        if #available(iOS 26.0, *) {
            self.tabBarMinimizeBehavior(.onScrollDown)
        } else {
            self
        }
    }

    func cardShape(_ radius: CGFloat = 22) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

/// Wraps glass siblings so they blend and morph together on iOS 26.
struct GlassGroup<Content: View>: View {
    var spacing: CGFloat = 12
    @ViewBuilder var content: () -> Content

    var body: some View {
        if #available(iOS 26.0, *) {
            GlassEffectContainer(spacing: spacing) { content() }
        } else {
            content()
        }
    }
}

/// A titled group of items for sectioned lists.
struct Grouped<T>: Identifiable {
    let title: String
    let items: [T]
    var id: String { title }
}

enum Haptics {
    static func tap() { UIImpactFeedbackGenerator(style: .light).impactOccurred() }
    static func select() { UISelectionFeedbackGenerator().selectionChanged() }
    static func success() { UINotificationFeedbackGenerator().notificationOccurred(.success) }
}

/// Gradient built from the API's RRGGBBAA agent colours.
func agentGradient(_ agent: Agent) -> LinearGradient {
    let colors = (agent.backgroundGradientColors ?? []).map { Color(hex: $0) }
    let stops = colors.isEmpty ? [VW.navy, VW.red.opacity(0.5)] : colors
    return LinearGradient(colors: stops, startPoint: .topLeading, endPoint: .bottomTrailing)
}

func formatNumber(_ v: Double, decimals: Int = 0) -> String {
    if decimals == 0 || v.rounded() == v { return String(Int(v.rounded())) }
    return String(format: "%.\(decimals)f", v)
}

let shortDate: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .medium
    f.timeStyle = .none
    return f
}()

/// Small caps label used above titles.
struct Eyebrow: View {
    let text: String
    var color: Color = VW.red

    init(_ text: String, color: Color = VW.red) {
        self.text = text
        self.color = color
    }

    var body: some View {
        Text(text.uppercased())
            .font(.caption.weight(.bold))
            .tracking(1.2)
            .foregroundStyle(color)
    }
}

/// Section header for ScrollView-based screens.
struct SectionHeader: View {
    let title: String
    var detail: String? = nil

    init(_ title: String, detail: String? = nil) {
        self.title = title
        self.detail = detail
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.title2.bold())
            Spacer()
            if let detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

/// The ValWiki "V" mark: two angled red blades with a teal tick.
struct LogoMark: View {
    var size: CGFloat = 40

    var body: some View {
        Canvas { ctx, s in
            let w = s.width, h = s.height
            var left = Path()
            left.move(to: CGPoint(x: w * 0.06, y: h * 0.18))
            left.addLine(to: CGPoint(x: w * 0.22, y: h * 0.18))
            left.addLine(to: CGPoint(x: w * 0.56, y: h * 0.82))
            left.addLine(to: CGPoint(x: w * 0.40, y: h * 0.82))
            left.closeSubpath()
            ctx.fill(left, with: .color(VW.red))
            var right = Path()
            right.move(to: CGPoint(x: w * 0.94, y: h * 0.18))
            right.addLine(to: CGPoint(x: w * 0.78, y: h * 0.18))
            right.addLine(to: CGPoint(x: w * 0.60, y: h * 0.52))
            right.addLine(to: CGPoint(x: w * 0.68, y: h * 0.67))
            right.closeSubpath()
            ctx.fill(right, with: .color(VW.red))
            ctx.fill(Path(CGRect(x: w * 0.06, y: h * 0.88, width: w * 0.18, height: h * 0.04)), with: .color(VW.teal))
        }
        .frame(width: size, height: size)
    }
}
