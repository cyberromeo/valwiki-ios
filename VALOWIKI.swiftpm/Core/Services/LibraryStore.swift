import Foundation
import Observation

@MainActor
@Observable
final class LibraryStore {
    static let shared = LibraryStore()

    enum UplinkState: Equatable {
        case idle
        case loading
        case ready
        case failed(String)
    }

    var state: UplinkState = .idle
    var failedEndpoints: [String] = []

    var agents: [Agent] = []
    var maps: [GameMap] = []
    var weapons: [Weapon] = []
    var skins: [WeaponSkin] = []
    var skinChromas: [SkinChroma] = []
    var skinLevels: [SkinLevel] = []
    var buddies: [Buddy] = []
    var buddyLevels: [BuddyLevel] = []
    var playerCards: [PlayerCard] = []
    var sprays: [Spray] = []
    var sprayLevels: [SprayLevel] = []
    var titles: [PlayerTitle] = []
    var currencies: [Currency] = []
    var gameModes: [GameMode] = []
    var gear: [GearItem] = []
    var seasons: [Season] = []
    var contracts: [Contract] = []
    var themes: [SkinTheme] = []
    var bundles: [ItemBundle] = []
    var ceremonies: [Ceremony] = []
    var equippables: [GameModeEquippable] = []
    var contentTiers: [ContentTier] = []
    var events: [EsportsEvent] = []
    var tierLists: [CompetitiveTierList] = []
    var version: GameVersion?

    var tiers: [Tier] { tierLists.last?.tiers ?? [] }

    private init() {}

    /// 25 live endpoints, fetched in parallel. Decoding happens off the main
    /// actor so the splash screen keeps animating.
    func loadAll() async {
        state = .loading
        failedEndpoints.removeAll()

        async let a: Void = loadList(into: \.agents, "agents?isPlayableCharacter=true")
        async let b: Void = loadList(into: \.maps, "maps")
        async let c: Void = loadList(into: \.weapons, "weapons")
        async let d: Void = loadList(into: \.skins, "weapons/skins")
        async let e: Void = loadList(into: \.skinChromas, "weapons/skinchromas")
        async let f: Void = loadList(into: \.skinLevels, "weapons/skinlevels")

        async let g: Void = loadList(into: \.buddies, "buddies")
        async let h: Void = loadList(into: \.buddyLevels, "buddies/levels")
        async let i: Void = loadList(into: \.playerCards, "playercards")
        async let j: Void = loadList(into: \.sprays, "sprays")
        async let k: Void = loadList(into: \.sprayLevels, "sprays/levels")
        async let l: Void = loadList(into: \.titles, "playertitles")

        async let m: Void = loadList(into: \.currencies, "currencies")
        async let n: Void = loadList(into: \.gameModes, "gamemodes")
        async let o: Void = loadList(into: \.gear, "gear")
        async let p: Void = loadList(into: \.seasons, "seasons")
        async let q: Void = loadList(into: \.contracts, "contracts")
        async let r: Void = loadList(into: \.themes, "themes")

        async let s: Void = loadList(into: \.bundles, "bundles")
        async let t: Void = loadList(into: \.ceremonies, "ceremonies")
        async let u: Void = loadList(into: \.equippables, "gamemodes/equippables")
        async let v: Void = loadList(into: \.contentTiers, "contenttiers")
        async let w: Void = loadList(into: \.events, "events")

        async let x: Void = loadTierLists()
        async let y: Void = loadVersion()

        _ = await (a, b, c, d, e, f)
        _ = await (g, h, i, j, k, l)
        _ = await (m, n, o, p, q, r)
        _ = await (s, t, u, v, w)
        _ = await (x, y)

        ContentTierMapper.register(contentTiers)

        let total = 25
        if failedEndpoints.count >= total {
            state = .failed("UPLINK SEVERED — CHECK YOUR CONNECTION")
        } else {
            state = .ready
        }
    }

    private nonisolated func fetchList<T: Decodable>(_ path: String) async throws -> [T] {
        let response: APIResponse<[T]> = try await ValorantAPI.fetch(path)
        return response.data
    }

    private func loadList<T: Decodable>(into keyPath: WritableKeyPath<LibraryStore, [T]>, _ path: String) async {
        do {
            self[keyPath: keyPath] = try await fetchList(path)
        } catch {
            failedEndpoints.append(path)
        }
    }

    private func loadTierLists() async {
        do {
            let response: APIResponse<[CompetitiveTierList]> = try await ValorantAPI.fetch("competitivetiers")
            tierLists = response.data
        } catch {
            failedEndpoints.append("competitivetiers")
        }
    }

    private func loadVersion() async {
        do {
            let response: APIResponse<GameVersion> = try await ValorantAPI.fetch("version")
            version = response.data
        } catch {
            failedEndpoints.append("version")
        }
    }

    func count(for endpoint: Endpoint) -> Int {
        switch endpoint {
        case .agents: return agents.count
        case .maps: return maps.count
        case .weapons: return weapons.count
        case .skins: return skins.count
        case .ranks: return tiers.count
        case .modes: return gameModes.count
        case .seasons: return seasons.count
        case .contracts: return contracts.count
        case .events: return events.count
        case .buddies: return buddies.count
        case .buddyLevels: return buddyLevels.count
        case .cards: return playerCards.count
        case .sprays: return sprays.count
        case .sprayLevels: return sprayLevels.count
        case .titles: return titles.count
        case .currencies: return currencies.count
        case .chromas: return skinChromas.count
        case .skinLevels: return skinLevels.count
        case .themes: return themes.count
        case .bundles: return bundles.count
        case .ceremonies: return ceremonies.count
        case .equippables: return equippables.count
        case .contentTiers: return contentTiers.count
        case .gear: return gear.count
        case .version: return version == nil ? 0 : 1
        case .raw: return RawFeed.feedPaths.count
        }
    }

    func searchHits(for query: String) -> [SearchHit] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return [] }
        var hits: [SearchHit] = []

        func add(_ kind: String, _ title: String, _ subtitle: String, _ image: URL?, _ route: AppRoute?) {
            hits.append(SearchHit(id: kind + title, kind: kind, title: title, subtitle: subtitle, image: image, route: route))
        }

        for agent in agents where agent.displayName.localizedCaseInsensitiveContains(trimmed) {
            add("AGENT", agent.displayName, agent.role?.displayName ?? "AGENT", agent.displayIcon, .agent(agent))
        }
        for map in maps where map.displayName.localizedCaseInsensitiveContains(trimmed) {
            add("MAP", map.displayName, map.coordinates ?? "", map.listViewIcon, .map(map))
        }
        for weapon in weapons where weapon.displayName.localizedCaseInsensitiveContains(trimmed) {
            add("WEAPON", weapon.displayName, weapon.categoryName, weapon.displayIcon, .weapon(weapon))
        }
        for skin in skins where skin.displayName.localizedCaseInsensitiveContains(trimmed) {
            add("SKIN", skin.displayName, ContentTierMapper.name(for: skin.contentTierUuid) ?? "SKIN", skin.displayIcon, .skin(skin))
        }
        for buddy in buddies where buddy.displayName.localizedCaseInsensitiveContains(trimmed) {
            add("BUDDY", buddy.displayName, "GUN CHARM", buddy.displayIcon, nil)
        }
        for card in playerCards where card.displayName.localizedCaseInsensitiveContains(trimmed) {
            add("CARD", card.displayName, "PLAYER CARD", card.smallArt, nil)
        }
        for spray in sprays where spray.displayName.localizedCaseInsensitiveContains(trimmed) {
            add("SPRAY", spray.displayName, "SPRAY", spray.displayIcon, nil)
        }
        for bundle in bundles where bundle.displayName.localizedCaseInsensitiveContains(trimmed) {
            add("BUNDLE", bundle.displayName, "STORE DROP", bundle.displayIcon2 ?? bundle.displayIcon, nil)
        }
        for title in titles where title.displayName.localizedCaseInsensitiveContains(trimmed) || (title.titleText?.localizedCaseInsensitiveContains(trimmed) ?? false) {
            add("TITLE", title.displayName, title.titleText ?? "PLAYER TITLE", nil, nil)
        }
        return Array(hits.prefix(80))
    }
}
