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
    var lastErrorDetail: String?

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
        lastErrorDetail = nil

        async let a = load(Agent.self, "agents?isPlayableCharacter=true")
        async let b = load(GameMap.self, "maps")
        async let c = load(Weapon.self, "weapons")
        async let d = load(WeaponSkin.self, "weapons/skins")
        async let e = load(SkinChroma.self, "weapons/skinchromas")
        async let f = load(SkinLevel.self, "weapons/skinlevels")

        async let g = load(Buddy.self, "buddies")
        async let h = load(BuddyLevel.self, "buddies/levels")
        async let i = load(PlayerCard.self, "playercards")
        async let j = load(Spray.self, "sprays")
        async let k = load(SprayLevel.self, "sprays/levels")
        async let l = load(PlayerTitle.self, "playertitles")

        async let m = load(Currency.self, "currencies")
        async let n = load(GameMode.self, "gamemodes")
        async let o = load(GearItem.self, "gear")
        async let p = load(Season.self, "seasons")
        async let q = load(Contract.self, "contracts")
        async let r = load(SkinTheme.self, "themes")

        async let s = load(ItemBundle.self, "bundles")
        async let t = load(Ceremony.self, "ceremonies")
        async let u = load(GameModeEquippable.self, "gamemodes/equippables")
        async let v = load(ContentTier.self, "contenttiers")
        async let w = load(EsportsEvent.self, "events")

        async let x = loadTierLists()
        async let y = loadVersion()

        agents = await a ?? agents
        maps = await b ?? maps
        weapons = await c ?? weapons
        skins = await d ?? skins
        skinChromas = await e ?? skinChromas
        skinLevels = await f ?? skinLevels

        buddies = await g ?? buddies
        buddyLevels = await h ?? buddyLevels
        playerCards = await i ?? playerCards
        sprays = await j ?? sprays
        sprayLevels = await k ?? sprayLevels
        titles = await l ?? titles

        currencies = await m ?? currencies
        gameModes = await n ?? gameModes
        gear = await o ?? gear
        seasons = await p ?? seasons
        contracts = await q ?? contracts
        themes = await r ?? themes

        bundles = await s ?? bundles
        ceremonies = await t ?? ceremonies
        equippables = await u ?? equippables
        contentTiers = await v ?? contentTiers
        events = await w ?? events

        tierLists = await x ?? tierLists
        version = await y ?? version

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

    private func recordFailure(_ path: String, _ error: Error) {
        failedEndpoints.append(path)
        guard lastErrorDetail == nil else { return }
        let message = (error as? APIError)?.errorDescription ?? error.localizedDescription
        lastErrorDetail = "\(message) [\(path)]"
    }

    private func load<T: Decodable>(_ type: T.Type, _ path: String) async -> [T]? {
        do {
            return try await fetchList(path)
        } catch {
            recordFailure(path, error)
            return nil
        }
    }

    private func loadTierLists() async -> [CompetitiveTierList]? {
        do {
            return try await fetchList("competitivetiers")
        } catch {
            recordFailure("competitivetiers", error)
            return nil
        }
    }

    private func loadVersion() async -> GameVersion? {
        do {
            let response: APIResponse<GameVersion> = try await ValorantAPI.fetch("version")
            return response.data
        } catch {
            recordFailure("version", error)
            return nil
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
