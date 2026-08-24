import SwiftUI

struct MapDetailView: View {
    let map: GameMap

    @State private var selectedCallout: MapCallout?

    private var calloutGroups: [(String, [MapCallout])] {
        let groups = Dictionary(grouping: map.callouts ?? []) { $0.superRegionName ?? "OTHER" }
        return groups.sorted { $0.key < $1.key }
    }

    var body: some View {
        ZStack {
            Backdrop(blobColor: .mint)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    hero
                    if let narrative = map.narrativeDescription {
                        Text(narrative)
                            .font(.mono(10.5))
                            .tracking(0.3)
                            .foregroundStyle(.white.opacity(0.72))
                            .lineSpacing(4)
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.panel))
                            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.line))
                    }
                    if !calloutGroups.isEmpty {
                        callouts
                    }
                    minimap
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
        }
    }

    private var hero: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(url: map.splash ?? map.listViewIconTall, contentMode: .fill)
                .frame(height: 250)
                .frame(maxWidth: .infinity)
            LinearGradient(colors: [.clear, .ink.opacity(0.95)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Chip(text: "MAP", filled: true, color: .mint)
                    if let tactical = map.tacticalDescription {
                        Chip(text: tactical, color: .mint)
                    }
                }
                Text(map.displayName.uppercased())
                    .font(.display(44))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let coordinates = map.coordinates {
                    CornerTag(text: "COORDS // \(coordinates)")
                }
            }
            .padding(18)
        }
        .frame(height: 250)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Color.line))
    }

    private var callouts: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Callouts", corner: "COMM GRID // \(map.callouts?.count ?? 0) PINGS")
            ForEach(calloutGroups, id: \.0) { group in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text(group.0.uppercased())
                            .font(.mono(10, .bold))
                            .tracking(2)
                            .foregroundStyle(.valRed)
                        Rectangle().fill(Color.line).frame(height: 1)
                        Text("\(group.1.count)")
                            .font(.mono(9, .bold))
                            .foregroundStyle(.faint)
                    }
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 86), spacing: 8)], spacing: 8) {
                        ForEach(Array(group.1.enumerated()), id: \.offset) { _, callout in
                            Text(callout.regionName?.uppercased() ?? "??")
                                .font(.mono(9, .semibold))
                                .tracking(1)
                                .foregroundStyle(.cream)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .frame(maxWidth: .infinity)
                                .background(RoundedRectangle(cornerRadius: 10).fill(Color.panel))
                                .overlay(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.line))
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var minimap: some View {
        if let icon = map.displayIcon {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("TACTICAL FEED")
                        .font(.mono(9, .bold))
                        .tracking(2.4)
                        .foregroundStyle(.dim)
                    Spacer()
                    if let selected = selectedCallout {
                        Text("\(selected.regionName?.uppercased() ?? "??") // \(selected.superRegionName?.cleanedEnum.uppercased() ?? "?")")
                            .font(.mono(8.5, .bold))
                            .tracking(1.2)
                            .foregroundStyle(.mint)
                            .lineLimit(1)
                    } else {
                        Text("TAP A PING")
                            .font(.mono(8, .semibold))
                            .tracking(1.4)
                            .foregroundStyle(.faint)
                    }
                }
                ZStack {
                    RemoteImage(url: icon, contentMode: .fit)
                    GeometryReader { geo in
                        ForEach(map.callouts ?? []) { callout in
                            let position = callout.relativePosition(in: map)
                            let isSelected = selectedCallout?.regionName == callout.regionName
                                && selectedCallout?.superRegionName == callout.superRegionName
                            Circle()
                                .fill(calloutColor(callout.superRegionName))
                                .frame(width: isSelected ? 13 : 7, height: isSelected ? 13 : 7)
                                .overlay(Circle().strokeBorder(.black, lineWidth: 1))
                                .shadow(color: calloutColor(callout.superRegionName).opacity(0.9), radius: isSelected ? 8 : 2)
                                .position(x: position.x * geo.size.width,
                                          y: position.y * geo.size.height)
                                .onTapGesture {
                                    Haptics.tap()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedCallout = callout
                                    }
                                }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 18, style: .continuous).fill(Color.panel))
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.line))
                HStack(spacing: 10) {
                    ForEach(["A", "B", "C"], id: \.self) { site in
                        HStack(spacing: 5) {
                            Circle()
                                .fill(calloutColor("ECalloutSuperRegion::\(site)"))
                                .frame(width: 6, height: 6)
                            Text("SITE \(site)")
                                .font(.mono(7.5, .semibold))
                                .tracking(1.2)
                                .foregroundStyle(.dim)
                        }
                    }
                    Spacer()
                    Text("\(map.callouts?.count ?? 0) PINGS")
                        .font(.mono(7.5, .bold))
                        .foregroundStyle(.faint)
                }
            }
        }
    }

    private func calloutColor(_ superRegion: String?) -> Color {
        switch superRegionNameKey(superRegion) {
        case "A": return .valRed
        case "B": return Color(hex: 0x53DDF0)
        case "C": return Color(hex: 0xF2C94C)
        case "M": return .mint
        default: return Color.white.opacity(0.55)
        }
    }

    private func superRegionNameKey(_ superRegion: String?) -> String {
        (superRegion?.cleanedEnum.uppercased()).map { String($0.prefix(1)) } ?? "?"
    }
}
