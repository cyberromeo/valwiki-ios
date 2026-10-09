import SwiftUI

struct MapDetailView: View {
    let map: GameMap
    @State private var region = "All"
    @State private var selected: String?
    @State private var fullscreen = DebugLaunch.screen == "mapfull"

    private var regions: [String] {
        var seen = Set<String>()
        let names = map.calloutList.compactMap { $0.superRegionName }.filter { seen.insert($0).inserted }
        let order: [String] = ["A", "Mid", "B", "C", "Attacker Side", "Defender Side"]
        let sorted: [String] = names.sorted { (l: String, r: String) -> Bool in
            let li: Int = order.firstIndex(of: l) ?? 50
            let ri: Int = order.firstIndex(of: r) ?? 50
            if li != ri { return li < ri }
            return l < r
        }
        return ["All"] + sorted
    }

    private var grouped: [Grouped<Callout>] {
        regions.dropFirst().compactMap { r in
            let items = map.calloutList.filter { $0.superRegionName == r }.sorted { ($0.regionName ?? "") < ($1.regionName ?? "") }
            return items.isEmpty ? nil : Grouped(title: r, items: items)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                hero

                if let story = map.narrativeDescription, !story.isEmpty {
                    Text(story)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                }

                if map.hasMinimap {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            SectionHeader("Callouts", detail: "\(map.calloutList.count)")
                            Button {
                                fullscreen = true
                            } label: {
                                Image(systemName: "arrow.up.left.and.arrow.down.right")
                                    .padding(2)
                            }
                            .glassButton()
                            .accessibilityLabel("Open full-screen minimap")
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            GlassGroup(spacing: 8) {
                                HStack(spacing: 8) {
                                    ForEach(regions, id: \.self) { r in
                                        FilterChip(title: r, selected: region == r) {
                                            withAnimation(.snappy) { region = r; selected = nil }
                                        }
                                    }
                                }
                                .padding(.vertical, 2)
                            }
                        }

                        MinimapView(map: map, region: region, selected: $selected, showAllLabels: false, dotSize: 9)
                            .padding(10)
                            .glassCard(cornerRadius: 28)

                        if let id = selected, let c = map.calloutList.first(where: { $0.id == id }) {
                            HStack {
                                Image(systemName: "mappin.circle.fill").foregroundStyle(VW.red)
                                Text(c.name).font(.headline)
                                Spacer()
                                Text(c.superRegionName ?? "").font(.subheadline).foregroundStyle(.secondary)
                            }
                            .padding(14)
                            .glassCard(cornerRadius: 18)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(grouped) { group in
                            if region == "All" || region == group.title {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(group.title.uppercased())
                                        .font(.caption.weight(.bold))
                                        .tracking(1.2)
                                        .foregroundStyle(VW.red)
                                    FlowLayout(spacing: 6) {
                                        ForEach(group.items) { c in
                                            Button {
                                                Haptics.select()
                                                withAnimation(.snappy) { selected = c.id }
                                            } label: {
                                                Text(c.regionName ?? "")
                                                    .font(.footnote.weight(.medium))
                                                    .foregroundStyle(selected == c.id ? Color.white : Color.primary)
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 6)
                                                    .background(Capsule().fill(selected == c.id ? VW.red : Color(.tertiarySystemFill)))
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                } else if let mini = link(map.displayIcon) {
                    RemoteImage(mini)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)
                }
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .debugScrollAnchor()
        .ignoresSafeArea(edges: .top)
        .navigationTitle(map.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $fullscreen) {
            MinimapFullscreen(map: map, region: region)
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(link(map.splash), mode: .fill, placeholder: Color(.secondarySystemBackground))
                .frame(height: 380)
                .frame(maxWidth: .infinity)
                .clipped()
            LinearGradient(colors: [.clear, .black.opacity(0.65)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 4) {
                if let t = map.tacticalDescription {
                    Text(t.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(1.4)
                        .foregroundStyle(.white.opacity(0.85))
                }
                Text(map.displayName.uppercased())
                    .font(VW.title(64))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                if let c = map.coordinates {
                    Text(c)
                        .font(.caption.monospaced())
                        .foregroundStyle(.white.opacity(0.75))
                }
            }
            .padding()
        }
        .frame(height: 380)
        .clipped()
    }
}

/// The minimap with every callout plotted from the API's world coordinates.
struct MinimapView: View {
    let map: GameMap
    var region: String = "All"
    @Binding var selected: String?
    var showAllLabels: Bool
    var dotSize: CGFloat = 9

    var body: some View {
        GeometryReader { geo in
            let side: CGFloat = min(geo.size.width, geo.size.height)
            ZStack(alignment: .topLeading) {
                RemoteImage(link(map.displayIcon))
                    .frame(width: side, height: side)
                ForEach(map.calloutList) { c in
                    let p: CGPoint = map.normalized(c)
                    let isOn: Bool = region == "All" || c.superRegionName == region
                    let isSelected: Bool = selected == c.id
                    let px: CGFloat = p.x * side
                    let py: CGFloat = p.y * side
                    CalloutPin(
                        name: c.regionName ?? "",
                        active: isOn,
                        selected: isSelected,
                        showLabel: (showAllLabels && isOn) || isSelected,
                        dotSize: dotSize
                    )
                    .onTapGesture {
                        Haptics.select()
                        withAnimation(.snappy) { selected = isSelected ? nil : c.id }
                    }
                    .position(x: px, y: py)
                }
            }
            .frame(width: side, height: side)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct CalloutPin: View {
    let name: String
    let active: Bool
    let selected: Bool
    let showLabel: Bool
    let dotSize: CGFloat

    var body: some View {
        let fill: Color = selected ? VW.red : (active ? VW.teal : Color.gray.opacity(0.5))
        let d: CGFloat = selected ? dotSize * 1.6 : dotSize
        let fontSize: CGFloat = selected ? 12 : 9
        let alpha: Double = (active || selected) ? 1 : 0.35
        let z: Double = selected ? 2 : (showLabel ? 1 : 0)
        ZStack {
            Circle()
                .fill(fill)
                .frame(width: d, height: d)
                .overlay(Circle().stroke(.white.opacity(0.9), lineWidth: 1.2))
                .shadow(color: .black.opacity(0.4), radius: 2)
                .frame(width: 30, height: 30)
                .contentShape(Circle())
            if showLabel {
                Text(name)
                    .font(.system(size: fontSize, weight: .semibold))
                    .fixedSize()
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(.ultraThinMaterial, in: Capsule())
                    .offset(y: -18)
                    .allowsHitTesting(false)
            }
        }
        .opacity(alpha)
        .zIndex(z)
    }
}

struct MinimapFullscreen: View {
    @Environment(\.dismiss) private var dismiss
    let map: GameMap
    let region: String
    @State private var zoom: CGFloat = 2.2
    @State private var selected: String?

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView([.horizontal, .vertical], showsIndicators: false) {
                    MinimapView(map: map, region: region, selected: $selected, showAllLabels: true, dotSize: 8)
                        .frame(width: geo.size.width * zoom, height: geo.size.width * zoom)
                        .padding(40)
                }
                .defaultScrollAnchor(.center)
            }
            .background(Color(.systemBackground))
            .navigationTitle(map.displayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "xmark") }
                        .accessibilityLabel("Close")
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    Button { withAnimation(.snappy) { zoom = max(1, zoom - 0.5) } } label: { Image(systemName: "minus.magnifyingglass") }
                    Spacer()
                    Text("\(formatNumber(Double(zoom), decimals: 1))×").monospacedDigit()
                    Spacer()
                    Button { withAnimation(.snappy) { zoom = min(4, zoom + 0.5) } } label: { Image(systemName: "plus.magnifyingglass") }
                }
            }
        }
    }
}

/// Simple wrapping layout for tag-style chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, widest: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > 0 && x + size.width > maxWidth {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            widest = max(widest, x - spacing)
        }
        return CGSize(width: proposal.width ?? widest, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x > bounds.minX && x + size.width > bounds.maxX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}
