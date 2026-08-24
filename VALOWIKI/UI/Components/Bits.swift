import SwiftUI

struct Chip: View {
    let text: String
    var filled: Bool = false
    var color: Color = .valRed

    var body: some View {
        Text(text.uppercased())
            .font(.mono(9, .semibold))
            .tracking(1.2)
            .padding(.horizontal, 9)
            .padding(.vertical, 5)
            .background {
                if filled {
                    Capsule().fill(color)
                } else {
                    Capsule().fill(color.opacity(0.14))
                }
            }
            .foregroundStyle(filled ? Color.black : color)
    }
}

struct StatBar: View {
    let label: String
    let value: String
    let fraction: Double
    var tint: Color = .valRed

    @State private var animated = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label.uppercased())
                    .font(.mono(9, .semibold))
                    .tracking(1.4)
                    .foregroundStyle(.dim)
                Spacer()
                Text(value)
                    .font(.mono(11, .bold))
                    .foregroundStyle(.cream)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.07))
                    Capsule()
                        .fill(tint)
                        .frame(width: geo.size.width * CGFloat(min(max(animated ? fraction : 0, 0), 1)))
                }
            }
            .frame(height: 5)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.1)) { animated = true }
        }
    }
}

struct SectionHeader: View {
    let title: String
    var corner: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if !corner.isEmpty {
                Text(corner.uppercased())
                    .font(.mono(9, .semibold))
                    .tracking(2)
                    .foregroundStyle(.valRed)
            }
            Text(title.uppercased())
                .font(.display(36))
                .tracking(-0.5)
                .foregroundStyle(.cream)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CornerTag: View {
    let text: String
    var color: Color = .white.opacity(0.65)

    var body: some View {
        Text(text.uppercased())
            .font(.mono(8.5, .semibold))
            .tracking(1.6)
            .foregroundStyle(color)
    }
}

struct PulseDot: View {
    var color: Color = .mint

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 7, height: 7)
            .shadow(color: color, radius: 4)
            .modifier(PulseEffect())
    }
}

struct MarqueeText: View {
    let text: String
    var font: Font = .mono(10, .bold)
    var color: Color = .black
    var speed: Double = 42

    var body: some View {
        GeometryReader { geo in
            let width = max(geo.size.width, 1)
            TimelineView(.animation(minimumInterval: 0.016)) { context in
                let elapsed = context.date.timeIntervalSinceReferenceDate
                let phase = (elapsed * speed).truncatingRemainder(dividingBy: width) / width
                HStack(spacing: 48) {
                    ForEach(0..<4, id: \.self) { _ in
                        Text(text)
                            .font(font)
                            .tracking(1.5)
                            .foregroundStyle(color)
                            .lineLimit(1)
                            .fixedSize()
                    }
                }
                .offset(x: -phase * width)
            }
        }
        .clipped()
    }
}

struct TickerStrip: View {
    let message: String

    var body: some View {
        ZStack {
            Rectangle().fill(Color.valRed)
            MarqueeText(text: message)
        }
        .frame(height: 26)
        .clipShape(Rectangle())
        .rotationEffect(.degrees(-1.2))
        .shadow(color: Color.valRed.opacity(0.35), radius: 12, y: 4)
    }
}

struct EmptyState: View {
    let title: String
    var subtitle: String = ""

    var body: some View {
        VStack(spacing: 12) {
            DotMatrix(color: .valRed, spacing: 10, strength: 0.5)
                .frame(width: 130, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 14))
            Text(title.uppercased())
                .font(.display(20))
                .foregroundStyle(.cream)
            if !subtitle.isEmpty {
                Text(subtitle.uppercased())
                    .font(.mono(9))
                    .tracking(1.2)
                    .foregroundStyle(.dim)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 36)
    }
}

struct PanelCard<Content: View>: View {
    var cornerRadius: CGFloat = 18
    @ViewBuilder var content: Content

    var body: some View {
        content
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.line)
            )
    }
}

extension View {
    func panelCard(cornerRadius: CGFloat = 18) -> some View {
        self
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.panel)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.line)
            )
    }
}
