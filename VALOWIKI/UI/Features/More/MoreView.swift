import SwiftUI

struct MoreView: View {
    @Environment(LibraryStore.self) private var store

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Backdrop(blobColor: .mint)
                ScrollView {
                    VStack(alignment: .leading, spacing: 26) {
                        SectionHeader(title: "Everything Else", corner: "INDEX // \(Endpoint.allCases.count - 1) ENDPOINTS")
                        group("GAME", [.modes, .seasons, .ranks, .contracts, .events, .equippables])
                        group("COLLECTION", [.buddies, .buddyLevels, .cards, .sprays, .sprayLevels, .titles, .currencies, .ceremonies])
                        group("ARMORY DEEP CUTS", [.bundles, .chromas, .skinLevels, .themes, .contentTiers])
                        group("SYSTEM", [.gear, .version, .raw])
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
        }
    }

    private func group(_ title: String, _ endpoints: [Endpoint]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.mono(9, .bold))
                .tracking(2.6)
                .foregroundStyle(.dim)
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
                ForEach(endpoints) { endpoint in
                    NavigationLink(value: endpoint) {
                        IndexTile(endpoint: endpoint, count: store.count(for: endpoint))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 10) {
            DotMatrix(color: .mint, spacing: 9, strength: 0.3)
                .frame(height: 42)
                .opacity(0.5)
            HStack(spacing: 8) {
                PulseDot()
                Text("VALORANT-API.COM // UNOFFICIAL FAN WIKI")
                    .font(.mono(8.5))
                    .tracking(1.5)
                    .foregroundStyle(.dim)
                Spacer()
            }
        }
    }
}

struct IndexTile: View {
    let endpoint: Endpoint
    var count: Int = 0

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: endpoint.icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.valRed)
                .frame(width: 30)
            VStack(alignment: .leading, spacing: 1) {
                Text(endpoint.title.uppercased())
                    .font(.display(17))
                    .foregroundStyle(.cream)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("\(count) ITEMS")
                    .font(.mono(7.5, .semibold))
                    .tracking(1.2)
                    .foregroundStyle(.dim)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(.faint)
        }
        .padding(12)
        .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color.panel))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(Color.line))
        .contentShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

struct EndpointScreen: View {
    let endpoint: Endpoint

    var body: some View {
        ZStack(alignment: .top) {
            Backdrop()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(title: endpoint.title, corner: "ENDPOINT // /V1/\(endpoint.apiPath.uppercased())")
                    content
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 50)
            }
            .scrollIndicators(.hidden)
        }
        .appRoutes()
    }

    @ViewBuilder
    private var content: some View {
        switch endpoint {
        case .agents: AgentsGrid()
        case .maps: MapsList()
        case .weapons: WeaponList()
        case .skins: SkinsGallery()
        case .ranks: RanksList()
        case .modes: ModesList()
        case .seasons: SeasonsList()
        case .contracts: ContractsList()
        case .events: EventsList()
        case .buddies: BuddiesGrid()
        case .buddyLevels: BuddyLevelsGrid()
        case .cards: PlayerCardsGrid()
        case .sprays: SpraysGrid()
        case .sprayLevels: SprayLevelsGrid()
        case .titles: TitlesList()
        case .currencies: CurrenciesList()
        case .chromas: ChromasGrid()
        case .skinLevels: SkinLevelsGrid()
        case .themes: ThemesList()
        case .bundles: BundlesGrid()
        case .ceremonies: CeremoniesList()
        case .equippables: EquippablesGrid()
        case .contentTiers: ContentTiersList()
        case .gear: GearList()
        case .version: VersionCard()
        case .raw: RawFeed()
        }
    }
}
