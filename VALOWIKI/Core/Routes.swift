import SwiftUI

enum Endpoint: String, CaseIterable, Identifiable, Hashable {
    case agents
    case maps
    case weapons
    case skins
    case ranks
    case modes
    case seasons
    case contracts
    case events
    case buddies
    case buddyLevels
    case cards
    case sprays
    case sprayLevels
    case titles
    case currencies
    case chromas
    case skinLevels
    case themes
    case bundles
    case ceremonies
    case equippables
    case contentTiers
    case gear
    case version
    case raw

    var id: String { rawValue }

    var title: String {
        switch self {
        case .agents: return "Agents"
        case .maps: return "Maps"
        case .weapons: return "Weapons"
        case .skins: return "Skins"
        case .ranks: return "Competitive Tiers"
        case .modes: return "Game Modes"
        case .seasons: return "Seasons"
        case .contracts: return "Contracts"
        case .events: return "Events"
        case .buddies: return "Buddies"
        case .buddyLevels: return "Buddy Levels"
        case .cards: return "Player Cards"
        case .sprays: return "Sprays"
        case .sprayLevels: return "Spray Levels"
        case .titles: return "Player Titles"
        case .currencies: return "Currencies"
        case .chromas: return "Skin Chromas"
        case .skinLevels: return "Skin Levels"
        case .themes: return "Skin Themes"
        case .bundles: return "Bundles"
        case .ceremonies: return "Ceremonies"
        case .equippables: return "Mode Items"
        case .contentTiers: return "Rarity Tiers"
        case .gear: return "Gear"
        case .version: return "Game Version"
        case .raw: return "Raw Feed"
        }
    }

    var icon: String {
        switch self {
        case .agents: return "person.fill"
        case .maps: return "map.fill"
        case .weapons: return "crosshair"
        case .skins: return "paintbrush.fill"
        case .ranks: return "crown.fill"
        case .modes: return "gamecontroller.fill"
        case .seasons: return "calendar"
        case .contracts: return "doc.text.fill"
        case .events: return "bolt.fill"
        case .buddies: return "gift.fill"
        case .buddyLevels: return "gift"
        case .cards: return "creditcard.fill"
        case .sprays: return "drop.fill"
        case .sprayLevels: return "drop"
        case .titles: return "textformat"
        case .currencies: return "banknote.fill"
        case .chromas: return "paintpalette.fill"
        case .skinLevels: return "slider.horizontal.3"
        case .themes: return "paintpalette"
        case .bundles: return "shippingbox.fill"
        case .ceremonies: return "hands.clap.fill"
        case .equippables: return "wrench.fill"
        case .contentTiers: return "seal.fill"
        case .gear: return "shield.fill"
        case .version: return "server.rack"
        case .raw: return "curlybraces"
        }
    }

    var blurb: String {
        switch self {
        case .agents: return "ROSTER + ABILITIES"
        case .maps: return "SPLASH + CALLOUTS"
        case .weapons: return "STATS + DAMAGE"
        case .skins: return "TIERS + CHROMAS"
        case .ranks: return "THE LADDER"
        case .modes: return "HOW TO QUEUE"
        case .seasons: return "EPISODES + ACTS"
        case .contracts: return "GRIND TRACKS"
        case .events: return "PASS EVENTS"
        case .buddies: return "GUN CHARMS"
        case .buddyLevels: return "CHARM LEVELS"
        case .cards: return "IDENTITY ART"
        case .sprays: return "WALL TAGS"
        case .sprayLevels: return "SPRAY LEVELS"
        case .titles: return "FLEX STRINGS"
        case .currencies: return "ECONOMY"
        case .chromas: return "COLORWAYS"
        case .skinLevels: return "UPGRADE STEPS"
        case .themes: return "SKIN FAMILIES"
        case .bundles: return "STORE DROPS"
        case .ceremonies: return "MATCH RITUALS"
        case .equippables: return "MODE LOADOUT"
        case .contentTiers: return "RARETY SCALE"
        case .gear: return "SHIELDS"
        case .version: return "LIVE BUILD"
        case .raw: return "TERMINAL JSON"
        }
    }

    var apiPath: String {
        switch self {
        case .ranks: return "competitivetiers"
        case .cards: return "playercards"
        case .titles: return "playertitles"
        case .modes: return "gamemodes"
        case .skins: return "weapons/skins"
        case .chromas: return "weapons/skinchromas"
        case .skinLevels: return "weapons/skinlevels"
        case .buddyLevels: return "buddies/levels"
        case .sprayLevels: return "sprays/levels"
        case .equippables: return "gamemodes/equippables"
        case .contentTiers: return "contenttiers"
        default: return rawValue
        }
    }
}

enum AppRoute: Hashable {
    case agent(Agent)
    case map(GameMap)
    case weapon(Weapon)
    case skin(WeaponSkin)
}

struct SearchHit: Identifiable {
    let id: String
    let kind: String
    let title: String
    let subtitle: String
    let image: URL?
    let route: AppRoute?
}

extension View {
    func appRoutes() -> some View {
        navigationDestination(for: Agent.self) { AgentDetailView(agent: $0) }
            .navigationDestination(for: GameMap.self) { MapDetailView(map: $0) }
            .navigationDestination(for: Weapon.self) { WeaponDetailView(weapon: $0) }
            .navigationDestination(for: WeaponSkin.self) { SkinDetailView(skin: $0) }
            .navigationDestination(for: Contract.self) { ContractDetailView(contract: $0) }
            .navigationDestination(for: Endpoint.self) { EndpointScreen(endpoint: $0) }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .agent(let agent): AgentDetailView(agent: agent)
                case .map(let map): MapDetailView(map: map)
                case .weapon(let weapon): WeaponDetailView(weapon: weapon)
                case .skin(let skin): SkinDetailView(skin: skin)
                }
            }
    }
}
