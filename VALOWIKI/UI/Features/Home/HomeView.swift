import SwiftUI
import Combine

struct HomeView: View {
    @Environment(LibraryStore.self) private var store
    @State private var rotation = 0
    @State private var showSearch = false

    private var featured: Agent? {
        guard !store.agents.isEmpty else { return nil }
        return store.agents[abs(rotation) % store.agents.count]
    }

    private var tickerMessage: String {
        var parts = ["LIVE FROM VALORANT-API.COM"]
        if let version = store.version {
            parts.append("BUILD \(version.buildVersion ?? "?")")
        }
        parts.append("\(store.agents.count) AGENTS")
        parts.append("\(store.maps.count) MAPS")
        parts.append("\(store.weapons.count) WEAPONS")
        parts.append("\(store.skins.count) SKINS")
        parts.append("STAY FUNKY")
        return parts.joined(separator: "  ///  ")
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Backdrop()
                ScrollView {
                    VStack(spacing: 28) {
                        header
                        hero
                        TickerStrip(message: tickerMessage)
                        vault
                        mapRail
                        footer
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 44)
                }
                .scrollIndicators(.hidden)
            }
            .toolbar(.hidden, for: .navigationBar)
            .appRoutes()
            .sheet(isPresented: $showSearch) { SearchView() }
            .refreshable { await store.loadAll() }
            .onReceive(Timer.publish(every: 6, on: .main, in: .common).autoconnect()) { _ in
                guard store.agents.count > 1 else { return }
                withAnimation(.easeInOut(duration: 0.7)) { rotation += 1 }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: 7) {
                    Rectangle()
                        .fill(Color.valRed)
                        .frame(width: 11, height: 11)
                    Text("VALOWIKI")
                        .font(.mono(13, .bold))
                        .tracking(3.5)
                        .foregroundStyle(.cream)
                }
                Text("EVERY ENDPOINT. ZERO MERCY.")
                    .font(.mono(8.5))
                    .tracking(2)
                    .foregroundStyle(.dim)
            }
            Spacer()
            Button {
                Haptics.tap()
                showSearch = true
            } label: {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)
                    .frame(width: 38, height: 38)
                    .background(Circle().fill(Color.cream))
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var hero: some View {
        if let agent = featured {
            NavigationLink(value: agent) {
                HeroAgentCard(agent: agent, index: abs(rotation))
            }
            .buttonStyle(.plain)
            .id(agent.uuid)
            .transition(.opacity.combined(with: .scale(scale: 1.03)))
        } else {
            HeroAgentCard.placeholder
        }
    }

    private var vault: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "The Vault", corner: "ALL ENDPOINTS // ONE APP")
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                NavigationLink(value: Endpoint.maps) { VaultTile(endpoint: .maps, count: store.maps.count) }.buttonStyle(.plain)
                NavigationLink(value: Endpoint.weapons) { VaultTile(endpoint: .weapons, count: store.weapons.count) }.buttonStyle(.plain)
                NavigationLink(value: Endpoint.skins) { VaultTile(endpoint: .skins, count: store.skins.count) }.buttonStyle(.plain)
                NavigationLink(value: Endpoint.ranks) { VaultTile(endpoint: .ranks, count: store.tiers.count) }.buttonStyle(.plain)
                NavigationLink(value: Endpoint.modes) { VaultTile(endpoint: .modes, count: store.gameModes.count) }.buttonStyle(.plain)
                NavigationLink(value: Endpoint.seasons) { VaultTile(endpoint: .seasons, count: store.seasons.count) }.buttonStyle(.plain)
                NavigationLink(value: Endpoint.contracts) { VaultTile(endpoint: .contracts, count: store.contracts.count) }.buttonStyle(.plain)
                NavigationLink(value: Endpoint.events) { VaultTile(endpoint: .events, count: store.events.count) }.buttonStyle(.plain)
                NavigationLink(value: Endpoint.bundles) { VaultTile(endpoint: .bundles, count: store.bundles.count) }.buttonStyle(.plain)
            }
        }
    }

    private var mapRail: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionHeader(title: "On Rotation", corner: "KNOW YOUR GROUND")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(store.maps) { map in
                        NavigationLink(value: map) {
                            MapRailCard(map: map)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            DotMatrix(color: .white, spacing: 9, strength: 0.22)
                .frame(height: 48)
                .opacity(0.55)
            HStack(spacing: 8) {
                PulseDot()
                Text("DATA STREAMING FROM VALORANT-API.COM")
                    .font(.mono(8.5))
                    .tracking(1.5)
                    .foregroundStyle(.dim)
                Spacer()
                if !store.failedEndpoints.isEmpty {
                    Text("\(store.failedEndpoints.count) DEGRADED")
                        .font(.mono(8.5, .bold))
                        .foregroundStyle(.valRed)
                }
                if let version = store.version {
                    Text("BUILD \(version.buildVersion ?? "0")")
                        .font(.mono(8.5, .bold))
                        .foregroundStyle(.cream)
                }
            }
        }
    }
}

struct HeroAgentCard: View {
    let agent: Agent
    var index: Int = 0

    static var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(Color.panel)
            DotMatrix(color: .white, spacing: 12, strength: 0.14)
            VStack(spacing: 10) {
                Text("SELECT YOUR AGENT")
                    .font(.display(34))
                    .foregroundStyle(.cream)
                PulseDot(color: .valRed)
            }
        }
        .frame(height: 420)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Color.line))
    }

    private var gradient: LinearGradient {
        let colors = agent.gradientColors.compactMap { Color(hexString: $0) }
        return LinearGradient(
            colors: colors.isEmpty ? [Color(hex: 0x1A1A24), Color(hex: 0x0B0B10)] : colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(gradient)
            DotMatrix(color: .white, spacing: 13, strength: 0.08)
            GlowBlob(color: .white.opacity(0.45), size: 210, offsetX: -70, offsetY: -120)
            GlowBlob(color: .valRed.opacity(0.75), size: 240, offsetX: 80, offsetY: 40)
            RemoteImage(url: agent.portrait, contentMode: .fill)
                .padding(.top, 34)
                .padding(.horizontal, 26)
            LinearGradient(colors: [.clear, .black.opacity(0.82)], startPoint: .center, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 5) {
                HStack(spacing: 8) {
                    Chip(text: agent.role?.displayName ?? "AGENT", filled: true)
                    CornerTag(text: "FILE // \(agent.developerName ?? "???")")
                }
                Text(agent.displayName.uppercased())
                    .font(.display(52))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            VStack {
                HStack(alignment: .top) {
                    CornerTag(text: "ROLE // \(agent.role?.displayName ?? "?")")
                    Spacer()
                    CornerTag(text: String(format: "AGENT %02d", (index % 30) + 1))
                }
                .padding(16)
                Spacer()
                HStack {
                    Spacer()
                    CornerTag(text: "TAP TO BRIEF →")
                }
                .padding(16)
            }
        }
        .frame(height: 430)
        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 26, style: .continuous).strokeBorder(Color.line))
    }
}

struct MapRailCard: View {
    let map: GameMap

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RemoteImage(url: map.splash ?? map.listViewIcon, contentMode: .fill)
                .frame(width: 232, height: 122)
            LinearGradient(colors: [.clear, .black.opacity(0.85)], startPoint: .top, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 2) {
                Text(map.displayName.uppercased())
                    .font(.display(20))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                CornerTag(text: map.coordinates ?? "CLASSIFIED")
            }
            .padding(12)
        }
        .frame(width: 232, height: 122)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).strokeBorder(Color.line))
    }
}

struct VaultTile: View {
    let endpoint: Endpoint
    var count: Int? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.panel)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.line)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: endpoint.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.valRed)
                    Spacer()
                    if let count {
                        Text("\(count)")
                            .font(.mono(10, .bold))
                            .foregroundStyle(.faint)
                    }
                }
                Spacer()
                Text(endpoint.title.uppercased())
                    .font(.display(21))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(endpoint.blurb)
                    .font(.mono(7.5))
                    .tracking(1)
                    .foregroundStyle(.dim)
                    .lineLimit(1)
            }
            .padding(14)
        }
        .frame(height: 110)
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
