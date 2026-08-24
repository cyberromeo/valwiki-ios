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

        async let a: Void = loadList("agents?isPlayableCharacter=true") { $0.agents = $1 }
        async let b: Void = loadList("maps") { $0.maps = $1 }
        async let c: Void = loadList("weapons") { $0.weapons = $1 }
        async let d: Void = loadList("weapons/skins") { $0.skins = $1 }
        async let e: Void = loadList("weapons/skinchromas") { $0.skinChromas = $1 }
        async let f: Void = loadList("weapons/skinlevels") { $0.skinLevels = $1 }

        async let g: Void = loadList("buddies") { $0.buddies = $1 }
        async let h: Void = loadList("buddies/levels") { $0.buddyLevels = $1 }
        async let i: Void = loadList("playercards") { $0.playerCards = $1 }
        async let j: Void = loadList("sprays") { $0.sprays = $1 }
        async let k: Void = loadList("sprays/levels") { $0.sprayLevels = $1 }
        async let l: Void = loadList("playertitles") { $0.titles = $1 }

        async let m: Void = loadList("currencies") { $0.currencies = $1 }
        async let n: Void = loadList("gamemodes") { $0.gameModes = $1 }
        async let o: Void = loadList("gear") { $0.gear = $1 }
        async let p: Void = loadList("seasons") { $0.seasons = $1 }
        async let q: Void = loadList("contracts") { $0.contracts = $1 }
        async let r: Void = loadList("themes") { $0.themes = $1 }

        async let s: Void = loadList("bundles") { $0.bundles = $1 }
        async let t: Void = loadList("ceremonies") { $0.ceremonies = $1 }
        async let u: Void = loadList("gamemodes/equippables") { $0.equippables = $1 }
        async let v: Void = loadList("contenttiers") { $0.contentTiers = $1 }
        async let w: Void = loadList("events") { $0.events = $1 }

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

    private func loadList<T: Decodable>(_ path: String,
                                       assign: (LibraryStore, [T]) -> Void) async {
        do {
            let items = try await fetchList(path)
            assign(self, items)
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
