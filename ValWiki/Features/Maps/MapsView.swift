import SwiftUI

struct MapsView: View {
    @Environment(Store.self) private var store
    @State private var pool = 0
    @State private var query = ""

    private var list: [GameMap] {
        store.maps.filter { m in
            (pool == 0 ? m.isCompetitive : !m.isCompetitive) &&
            (query.isEmpty || m.displayName.localizedCaseInsensitiveContains(query))
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                Picker("Pool", selection: $pool.animation(.snappy)) {
                    Text("Competitive").tag(0)
                    Text("Other Modes").tag(1)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                LazyVStack(spacing: 14) {
                    ForEach(list) { map in
                        NavigationLink(value: Route.map(map.uuid)) {
                            MapBanner(map: map)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)

                if list.isEmpty {
                    ContentUnavailableView.search(text: query)
                }
            }
            .padding(.vertical, 8)
        }
        .navigationTitle("Maps")
        .navigationSubtitleIfAvailable("\(store.competitiveMaps.count) in the competitive pool")
        .searchable(text: $query, prompt: "Find a map")
    }
}

struct MapBanner: View {
    let map: GameMap

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(link(map.listViewIcon) ?? link(map.splash), mode: .fill, placeholder: Color(.secondarySystemBackground))
                .frame(height: 130)
                .frame(maxWidth: .infinity)
                .clipped()
            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(map.displayName.uppercased())
                        .font(VW.title(24))
                    if let t = map.tacticalDescription {
                        Text(t).font(.caption).foregroundStyle(.secondary)
                    } else if let c = map.coordinates {
                        Text(c).font(.caption2.monospaced()).foregroundStyle(.secondary)
                    }
                }
                Spacer(minLength: 0)
                if !map.calloutList.isEmpty {
                    Label("\(map.calloutList.count)", systemImage: "mappin.and.ellipse")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassCard(cornerRadius: 18)
            .padding(8)
        }
        .frame(height: 130)
        .cardShape(26)
        .contentShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
    }
}
