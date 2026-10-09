import SwiftUI

struct HomeView: View {
    @Environment(Store.self) private var store
    @Binding var tab: AppTab
    @State private var featuredID: String?

    private var featured: Agent? {
        if let id = featuredID, let a = store.agent(id) { return a }
        return store.agents.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if let agent = featured {
                    FeaturedHero(agent: agent) { shuffle() }
                }

                GlassGroup(spacing: 12) {
                    HStack(spacing: 12) {
                        PatchCard(version: store.version)
                        NavigationLink(value: Route.seasons) {
                            ActCard(act: store.currentAct, episode: store.currentEpisode)
                        }
                        .buttonStyle(.plain)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader("Browse")
                    LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                        QuickTile(value: store.agents.count, label: "Agents", icon: "person.3.fill") { tab = .agents }
                        QuickTile(value: store.weapons.count, label: "Weapons", icon: "scope") { tab = .arsenal }
                        QuickTile(value: store.skinCount, label: "Skins", icon: "sparkles") { tab = .arsenal }
                        QuickTile(value: store.maps.count, label: "Maps", icon: "map.fill") { tab = .maps }
                    }
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader("Map Pool", detail: "\(store.competitiveMaps.count) maps")
                        .padding(.horizontal)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(store.competitiveMaps) { map in
                                NavigationLink(value: Route.map(map.uuid)) {
                                    MapPoster(map: map)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                }

                VStack(alignment: .leading, spacing: 12) {
                    SectionHeader("Intel")
                    VStack(spacing: 0) {
                        IntelRow(icon: "chart.bar.fill", color: .orange, title: "Competitive Ranks", subtitle: "Iron to Radiant", route: .ranks)
                        Divider().padding(.leading, 60)
                        IntelRow(icon: "calendar", color: .blue, title: "Episodes & Acts", subtitle: "What's live and what's next", route: .seasons)
                        Divider().padding(.leading, 60)
                        IntelRow(icon: "gamecontroller.fill", color: .purple, title: "Game Modes", subtitle: "Every mode and how long it runs", route: .modes)
                        Divider().padding(.leading, 60)
                        IntelRow(icon: "bag.fill", color: .pink, title: "Store Bundles", subtitle: "Every bundle released", route: .bundles)
                        Divider().padding(.leading, 60)
                        IntelRow(icon: "target", color: VW.red, title: "Aim Trainer", subtitle: "30 seconds. Beat your best.", route: .trainer)
                    }
                    .glassCard(cornerRadius: 24)
                }
                .padding(.horizontal)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Data from the public valorant-api.com. Not affiliated with Riot Games.")
                    if let v = store.version?.riotClientVersion { Text(v).monospaced() }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            }
            .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemBackground))
        .toolbar(.hidden, for: .navigationBar)
        .refreshable { await store.load(force: true) }
        .onAppear { if featuredID == nil { shuffle() } }
    }

    private func shuffle() {
        let pool = store.agents.filter { $0.uuid != featuredID }
        withAnimation(.smooth(duration: 0.45)) { featuredID = pool.randomElement()?.uuid }
    }
}

struct FeaturedHero: View {
    let agent: Agent
    var onShuffle: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            agentGradient(agent)
            RemoteImage(link(agent.background), mode: .fit)
                .opacity(0.25)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            RemoteImage(agent.portrait, mode: .fill)
                .frame(height: 500)
                .offset(x: 60, y: 40)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                .clipped()
                .id(agent.uuid)
                .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .opacity))
            LinearGradient(colors: [.clear, .black.opacity(0.55)], startPoint: UnitPoint(x: 0.5, y: 0.4), endPoint: .bottom)
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    LogoMark(size: 22)
                    Text("ValWiki").font(.headline).foregroundStyle(.white)
                }
                Spacer()
                Text("Featured · \(agent.roleName)".uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(.white.opacity(0.85))
                Text(agent.displayName.uppercased())
                    .font(VW.title(64))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
                GlassGroup(spacing: 10) {
                    HStack(spacing: 10) {
                        NavigationLink(value: Route.agent(agent.uuid)) {
                            Label("Open Dossier", systemImage: "person.text.rectangle")
                                .font(.headline)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                        }
                        .glassProminentButton()
                        Button {
                            Haptics.tap()
                            onShuffle()
                        } label: {
                            Image(systemName: "shuffle")
                                .font(.headline)
                                .padding(4)
                        }
                        .glassButton()
                        .accessibilityLabel("Shuffle featured agent")
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 64)
            .padding(.bottom, 20)
        }
        .frame(height: 540)
        .clipped()
    }
}

struct PatchCard: View {
    let version: GameVersion?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Patch", systemImage: "bolt.fill")
                .font(.caption.weight(.semibold))
                .foregroundStyle(VW.teal)
            Text(version?.patch ?? "—")
                .font(VW.title(34))
            if let d = version?.date {
                Text("Built \(shortDate.string(from: d))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .glassCard()
    }
}

struct ActCard: View {
    let act: Season?
    let episode: Season?

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Current Act", systemImage: "flag.checkered")
                .font(.caption.weight(.semibold))
                .foregroundStyle(VW.red)
            Text(act?.displayName ?? "—")
                .font(VW.title(34))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            if let act, let start = act.start, let end = act.end {
                let total: Double = max(end.timeIntervalSince(start), 1)
                let elapsed: Double = Date().timeIntervalSince(start) / total
                let done: Double = min(max(elapsed, 0), 1)
                let days: Int = max(0, Int(ceil(end.timeIntervalSinceNow / 86_400)))
                let caption: String = "\(episode?.displayName ?? "") · \(days) day\(days == 1 ? "" : "s") left"
                ProgressView(value: done)
                    .tint(VW.red)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .contentShape(Rectangle())
        .glassCard(interactive: true)
    }
}

struct QuickTile: View {
    let value: Int
    let label: String
    let icon: String
    var action: () -> Void

    var body: some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(value)")
                        .font(VW.title(30))
                        .contentTransition(.numericText())
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(VW.red)
            }
            .padding(16)
            .contentShape(Rectangle())
            .glassCard(interactive: true)
        }
        .buttonStyle(.plain)
    }
}

struct MapPoster: View {
    let map: GameMap
    var width: CGFloat = 150
    var height: CGFloat = 210

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(link(map.listViewIconTall) ?? link(map.splash), mode: .fill, placeholder: Color(.secondarySystemBackground))
                .frame(width: width, height: height)
                .clipped()
            VStack(alignment: .leading, spacing: 2) {
                Text(map.displayName)
                    .font(.headline)
                if let t = map.tacticalDescription {
                    Text(t).font(.caption2).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassCard(cornerRadius: 16)
            .padding(8)
        }
        .frame(width: width, height: height)
        .cardShape(24)
    }
}

struct IntelRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    let route: Route

    var body: some View {
        NavigationLink(value: route) {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 32, height: 32)
                    .background(color.gradient, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                VStack(alignment: .leading, spacing: 1) {
                    Text(title).font(.body.weight(.medium))
                    Text(subtitle).font(.footnote).foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
