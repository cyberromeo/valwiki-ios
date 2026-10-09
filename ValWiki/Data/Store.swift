import Foundation
import Observation

enum LoadPhase {
    case idle
    case loading
    case loaded
    case failed(String)
}

@MainActor
@Observable
final class Store {
    var phase: LoadPhase = .idle
    var refreshing = false

    var agents: [Agent] = []
    var weapons: [Weapon] = []
    var maps: [GameMap] = []
    var version: GameVersion?
    var seasons: [Season] = []
    var tiers: [ContentTier] = []

    var ranks: [Rank] = []
    var modes: [GameMode] = []
    var bundles: [StoreBundle] = []
    var extrasLoaded = false
    var extrasLoading = false

    /// skin uuid -> weapon uuid
    private(set) var skinOwner: [String: String] = [:]
    private(set) var allSkins: [Skin] = []

    static let roleOrder = ["Duelist", "Initiator", "Controller", "Sentinel"]
    static let categoryOrder = ["Sidearm", "SMG", "Shotgun", "Rifle", "Sniper", "Heavy", "Melee"]

    func load(force: Bool = false) async {
        if case .loading = phase { return }
        let alreadyLoaded: Bool
        if case .loaded = phase { alreadyLoaded = true } else { alreadyLoaded = false }
        if alreadyLoaded && !force { return }

        if alreadyLoaded { refreshing = true } else { phase = .loading }
        defer { refreshing = false }

        do {
            async let a = API.list("agents?isPlayableCharacter=true", Agent.self)
            async let w = API.list("weapons", Weapon.self)
            async let m = API.list("maps", GameMap.self)
            async let v = API.oneOrNil("version", GameVersion.self)
            async let s = API.listOrEmpty("seasons", Season.self)
            async let t = API.listOrEmpty("contenttiers", ContentTier.self)

            let agentList = try await a
            let weaponList = try await w
            let mapList = try await m
            let ver = await v
            let seasonList = await s
            let tierList = await t

            apply(agents: agentList, weapons: weaponList, maps: mapList)
            version = ver
            seasons = seasonList
            tiers = tierList.sorted { ($0.rank?.value ?? 0) < ($1.rank?.value ?? 0) }
            phase = .loaded
            if force { extrasLoaded = false; await loadExtras() }
        } catch {
            if !alreadyLoaded {
                phase = .failed(error.localizedDescription)
            }
        }
    }

    private func apply(agents agentList: [Agent], weapons weaponList: [Weapon], maps mapList: [GameMap]) {
        var seen = Set<String>()
        agents = agentList
            .filter { $0.isPlayableCharacter != false }
            .filter { seen.insert($0.displayName).inserted }
            .sorted { $0.displayName < $1.displayName }

        weapons = weaponList.sorted { l, r in
            let li = Store.categoryOrder.firstIndex(of: l.categoryName) ?? 99
            let ri = Store.categoryOrder.firstIndex(of: r.categoryName) ?? 99
            if li != ri { return li < ri }
            if l.cost != r.cost { return l.cost < r.cost }
            return l.displayName < r.displayName
        }

        var owner: [String: String] = [:]
        var skins: [Skin] = []
        for weapon in weapons {
            for skin in weapon.realSkins {
                owner[skin.uuid] = weapon.uuid
                skins.append(skin)
            }
        }
        skinOwner = owner
        allSkins = skins.sorted { $0.displayName < $1.displayName }

        var seenMaps = Set<String>()
        maps = mapList
            .filter { seenMaps.insert($0.displayName).inserted }
            .sorted { l, r in
                if l.isCompetitive != r.isCompetitive { return l.isCompetitive }
                return l.displayName < r.displayName
            }
    }

    func loadExtras() async {
        if extrasLoaded || extrasLoading { return }
        extrasLoading = true
        defer { extrasLoading = false }
        async let c = API.listOrEmpty("competitivetiers", CompetitiveTierSet.self)
        async let g = API.listOrEmpty("gamemodes", GameMode.self)
        async let b = API.listOrEmpty("bundles", StoreBundle.self)
        let sets = await c
        let latest = sets.last?.tiers?.items ?? []
        ranks = latest.filter { r in
            let n = (r.tierName ?? "").lowercased()
            return link(r.largeIcon) != nil && !n.contains("unused") && !n.contains("unranked")
        }
        var seenModes = Set<String>()
        modes = (await g)
            .filter { ($0.displayName ?? "").isEmpty == false }
            .filter { seenModes.insert($0.displayName ?? "").inserted }
            .sorted { ($0.displayName ?? "") < ($1.displayName ?? "") }
        bundles = Array((await b).reversed())
        extrasLoaded = true
    }

    // MARK: - Lookups

    func agent(_ id: String) -> Agent? { agents.first { $0.uuid == id } }
    func weapon(_ id: String) -> Weapon? { weapons.first { $0.uuid == id } }
    func map(_ id: String) -> GameMap? { maps.first { $0.uuid == id } }
    func tier(_ id: String?) -> ContentTier? {
        guard let id else { return nil }
        return tiers.first { $0.uuid == id }
    }
    func owner(of skin: Skin) -> Weapon? { skinOwner[skin.uuid].flatMap { weapon($0) } }

    var currentAct: Season? { seasons.first { $0.isAct && $0.isCurrent() } }
    var currentEpisode: Season? {
        guard let parent = currentAct?.parentUuid else { return nil }
        return seasons.first { $0.uuid == parent }
    }
    var skinCount: Int { allSkins.count }
    var competitiveMaps: [GameMap] { maps.filter { $0.isCompetitive } }

    func teammates(of agent: Agent) -> [Agent] {
        agents.filter { $0.role?.uuid == agent.role?.uuid && $0.uuid != agent.uuid }
    }

    func neighbours(of agent: Agent) -> (prev: Agent?, next: Agent?) {
        guard let i = agents.firstIndex(where: { $0.uuid == agent.uuid }), agents.count > 1 else { return (nil, nil) }
        let prev = agents[(i - 1 + agents.count) % agents.count]
        let next = agents[(i + 1) % agents.count]
        return (prev, next)
    }
}
