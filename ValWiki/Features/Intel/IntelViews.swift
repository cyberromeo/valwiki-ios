import SwiftUI

struct RanksView: View {
    @Environment(Store.self) private var store

    var body: some View {
        ScrollView {
            if store.ranks.isEmpty {
                ProgressView().padding(.top, 80)
            } else {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach(store.ranks) { rank in
                        VStack(spacing: 8) {
                            RemoteImage(link(rank.largeIcon))
                                .frame(width: 64, height: 64)
                            Text((rank.tierName ?? "").capitalized)
                                .font(.footnote.weight(.semibold))
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .glassCard(cornerRadius: 20, tint: hexColor(rank.color).opacity(0.25))
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Ranks")
        .navigationBarTitleDisplayMode(.inline)
        .navigationSubtitleIfAvailable("\(store.ranks.count) tiers, Iron to Radiant")
        .task { await store.loadExtras() }
    }
}

struct SeasonsView: View {
    @Environment(Store.self) private var store

    private var episodes: [Grouped<Season>] {
        let acts = store.seasons.filter { $0.isAct }
        let parents = store.seasons.filter { s in !s.isAct && s.parentUuid == nil && acts.contains { $0.parentUuid == s.uuid } }
        return parents
            .sorted { ($0.start ?? .distantPast) > ($1.start ?? .distantPast) }
            .map { p in Grouped(title: p.displayName ?? p.uuid, items: acts.filter { $0.parentUuid == p.uuid }.sorted { ($0.start ?? .distantPast) < ($1.start ?? .distantPast) }) }
    }

    var body: some View {
        List {
            if let act = store.currentAct {
                Section {
                    ActCard(act: act, episode: store.currentEpisode)
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets())
                }
            }
            ForEach(episodes) { pair in
                Section(pair.title) {
                    ForEach(pair.items) { act in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(act.displayName ?? "Act").font(.body.weight(.medium))
                                Text(range(act)).font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if act.isCurrent() {
                                Text("LIVE")
                                    .font(.caption2.weight(.heavy))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(VW.red, in: Capsule())
                            } else if let s = act.start, s > Date() {
                                Text("Upcoming").font(.caption).foregroundStyle(VW.teal)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Episodes & Acts")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func range(_ s: Season) -> String {
        let a = s.start.map { shortDate.string(from: $0) } ?? "?"
        let b = s.end.map { shortDate.string(from: $0) } ?? "?"
        return "\(a) – \(b)"
    }
}

struct ModesView: View {
    @Environment(Store.self) private var store

    var body: some View {
        List {
            if store.modes.isEmpty {
                HStack { Spacer(); ProgressView(); Spacer() }
            }
            ForEach(store.modes) { mode in
                HStack(alignment: .top, spacing: 14) {
                    RemoteImage(link(mode.displayIcon))
                        .frame(width: 34, height: 34)
                        .padding(6)
                        .background(Color(.tertiarySystemFill), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        HStack {
                            Text(mode.displayName ?? "").font(.headline)
                            Spacer()
                            if let d = mode.duration, !d.isEmpty {
                                Text(d.capitalized).font(.caption).foregroundStyle(.secondary)
                            }
                        }
                        if let desc = mode.description, !desc.isEmpty {
                            Text(desc).font(.subheadline).foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Game Modes")
        .navigationBarTitleDisplayMode(.inline)
        .task { await store.loadExtras() }
    }
}

struct BundlesView: View {
    @Environment(Store.self) private var store
    @State private var query = ""

    private var list: [StoreBundle] {
        store.bundles.filter { query.isEmpty || ($0.displayName ?? "").localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        ScrollView {
            if store.bundles.isEmpty {
                ProgressView().padding(.top, 80)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 160), spacing: 12)], spacing: 12) {
                ForEach(list) { b in
                    ZStack(alignment: .bottomLeading) {
                        RemoteImage(link(b.displayIcon), mode: .fill, placeholder: Color(.secondarySystemBackground))
                            .frame(height: 110)
                            .frame(maxWidth: .infinity)
                            .clipped()
                        Text(b.displayName ?? "")
                            .font(.caption.weight(.semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .glassCapsule()
                            .padding(6)
                    }
                    .frame(height: 110)
                    .cardShape(20)
                }
            }
            .padding()
        }
        .navigationTitle("Bundles")
        .navigationBarTitleDisplayMode(.inline)
        .navigationSubtitleIfAvailable("\(store.bundles.count) released")
        .searchable(text: $query, prompt: "Find a bundle")
        .task { await store.loadExtras() }
    }
}
