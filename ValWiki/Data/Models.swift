import Foundation
import CoreGraphics

// MARK: - Lenient decoding helpers

/// Decodes a JSON array, silently skipping elements that fail to decode,
/// so one odd entry from the API never blanks a whole screen.
struct Lossy<T: Decodable>: Decodable {
    var items: [T]

    init(items: [T]) { self.items = items }

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        var out: [T] = []
        while !container.isAtEnd {
            if let value = try? container.decode(T.self) {
                out.append(value)
            } else {
                _ = try? container.decode(SkipValue.self)
            }
        }
        items = out
    }
}

struct SkipValue: Decodable {
    init(from decoder: Decoder) throws {}
}

/// A number that may arrive as a number, a numeric string or a bool.
struct FlexNum: Decodable {
    let value: Double

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if let d = try? c.decode(Double.self) {
            value = d
        } else if let s = try? c.decode(String.self), let d = Double(s) {
            value = d
        } else if let b = try? c.decode(Bool.self) {
            value = b ? 1 : 0
        } else {
            value = 0
        }
    }
}

struct Envelope<T: Decodable>: Decodable {
    let data: T
}

func link(_ s: String?) -> URL? {
    guard let s, !s.isEmpty else { return nil }
    return URL(string: s)
}

/// "EEquippableCategory::Rifle" -> "Rifle"
func enumTail(_ s: String?) -> String {
    guard let s else { return "" }
    if let r = s.range(of: "::") { return String(s[r.upperBound...]) }
    return s
}

// MARK: - Agents

struct Agent: Decodable, Identifiable {
    let uuid: String
    let displayName: String
    let description: String?
    let developerName: String?
    let displayIcon: String?
    let displayIconSmall: String?
    let fullPortrait: String?
    let fullPortraitV2: String?
    let background: String?
    let backgroundGradientColors: [String]?
    let role: AgentRole?
    let abilities: Lossy<Ability>?
    let isPlayableCharacter: Bool?

    var id: String { uuid }
    var portrait: URL? { link(fullPortraitV2) ?? link(fullPortrait) ?? link(displayIcon) }
    var roleName: String { role?.displayName ?? "Agent" }
    var abilityList: [Ability] {
        let order = ["Ability1", "Ability2", "Grenade", "Ultimate", "Passive"]
        return (abilities?.items ?? []).sorted {
            (order.firstIndex(of: $0.slot ?? "") ?? 9) < (order.firstIndex(of: $1.slot ?? "") ?? 9)
        }
    }
}

struct AgentRole: Decodable {
    let uuid: String
    let displayName: String
    let description: String?
    let displayIcon: String?
}

struct Ability: Decodable, Identifiable {
    let slot: String?
    let displayName: String?
    let description: String?
    let displayIcon: String?

    var id: String { (slot ?? "") + (displayName ?? "") }
    var key: String {
        switch slot {
        case "Ability1": return "Q"
        case "Ability2": return "E"
        case "Grenade": return "C"
        case "Ultimate": return "X"
        case "Passive": return "P"
        default: return "•"
        }
    }
    var slotName: String {
        switch slot {
        case "Ability1": return "Ability"
        case "Ability2": return "Signature"
        case "Grenade": return "Basic"
        case "Ultimate": return "Ultimate"
        case "Passive": return "Passive"
        default: return slot ?? "Ability"
        }
    }
}

// MARK: - Weapons

struct Weapon: Decodable, Identifiable {
    let uuid: String
    let displayName: String
    let category: String?
    let defaultSkinUuid: String?
    let displayIcon: String?
    let killStreamIcon: String?
    let weaponStats: WeaponStats?
    let shopData: ShopData?
    let skins: Lossy<Skin>?

    var id: String { uuid }
    var categoryName: String {
        let tail = enumTail(category)
        switch tail {
        case "Heavy": return "Heavy"
        case "SMG": return "SMG"
        default: return tail.isEmpty ? "Other" : tail
        }
    }
    var cost: Int { Int(shopData?.cost?.value ?? 0) }
    /// Real skins only: no "Standard X" or "Random Favorite Skin" placeholders.
    var realSkins: [Skin] {
        (skins?.items ?? []).filter { $0.contentTierUuid != nil && !$0.displayName.contains("Random Favorite") }
    }
}

struct WeaponStats: Decodable {
    let fireRate: FlexNum?
    let magazineSize: FlexNum?
    let runSpeedMultiplier: FlexNum?
    let equipTimeSeconds: FlexNum?
    let reloadTimeSeconds: FlexNum?
    let firstBulletAccuracy: FlexNum?
    let shotgunPelletCount: FlexNum?
    let wallPenetration: String?
    let feature: String?
    let fireMode: String?
    let altFireType: String?
    let adsStats: AdsStats?
    let damageRanges: Lossy<DamageRange>?
}

struct AdsStats: Decodable {
    let zoomMultiplier: FlexNum?
    let fireRate: FlexNum?
    let runSpeedMultiplier: FlexNum?
    let burstCount: FlexNum?
    let firstBulletAccuracy: FlexNum?
}

struct DamageRange: Decodable, Identifiable {
    let rangeStartMeters: FlexNum?
    let rangeEndMeters: FlexNum?
    let headDamage: FlexNum?
    let bodyDamage: FlexNum?
    let legDamage: FlexNum?

    var id: String { "\(rangeStartMeters?.value ?? 0)-\(rangeEndMeters?.value ?? 0)" }
}

struct ShopData: Decodable {
    let cost: FlexNum?
    let category: String?
    let categoryText: String?
}

struct Skin: Decodable, Identifiable {
    let uuid: String
    let displayName: String
    let themeUuid: String?
    let contentTierUuid: String?
    let displayIcon: String?
    let wallpaper: String?
    let chromas: Lossy<Chroma>?
    let levels: Lossy<SkinLevel>?

    var id: String { uuid }
    var chromaList: [Chroma] { chromas?.items ?? [] }
    var levelList: [SkinLevel] { levels?.items ?? [] }
    var image: URL? {
        link(displayIcon)
            ?? link(chromaList.first?.fullRender)
            ?? link(chromaList.first?.displayIcon)
            ?? link(levelList.first?.displayIcon)
    }
}

struct Chroma: Decodable, Identifiable {
    let uuid: String
    let displayName: String?
    let displayIcon: String?
    let fullRender: String?
    let swatch: String?
    let streamedVideo: String?

    var id: String { uuid }
    var image: URL? { link(fullRender) ?? link(displayIcon) }
}

struct SkinLevel: Decodable, Identifiable {
    let uuid: String
    let displayName: String?
    let levelItem: String?
    let displayIcon: String?
    let streamedVideo: String?

    var id: String { uuid }
    var itemName: String {
        let t = enumTail(levelItem)
        switch t {
        case "": return "Base"
        case "VFX": return "VFX"
        case "SoundEffects": return "Sound effects"
        case "Animation": return "Animation"
        case "Finisher": return "Finisher"
        case "KillCounter": return "Kill counter"
        case "KillBanner": return "Kill banner"
        case "InspectAndKill": return "Inspect & kill"
        case "AttackerDefenderSwap": return "Side swap"
        case "TopFrag": return "Top frag"
        case "HeartbeatAndMapSensor": return "Heartbeat & map sensor"
        case "Transformation": return "Transformation"
        case "Voiceover": return "Voiceover"
        default: return t
        }
    }
}

struct ContentTier: Decodable, Identifiable {
    let uuid: String
    let displayName: String?
    let devName: String?
    let rank: FlexNum?
    let highlightColor: String?
    let displayIcon: String?

    var id: String { uuid }
    var name: String { devName ?? displayName ?? "Edition" }
}

// MARK: - Maps

struct GameMap: Decodable, Identifiable {
    let uuid: String
    let displayName: String
    let narrativeDescription: String?
    let tacticalDescription: String?
    let coordinates: String?
    let displayIcon: String?
    let listViewIcon: String?
    let listViewIconTall: String?
    let splash: String?
    let stylizedBackgroundImage: String?
    let premierBackgroundImage: String?
    let xMultiplier: FlexNum?
    let yMultiplier: FlexNum?
    let xScalarToAdd: FlexNum?
    let yScalarToAdd: FlexNum?
    let callouts: Lossy<Callout>?

    var id: String { uuid }
    var isCompetitive: Bool { (tacticalDescription ?? "").localizedCaseInsensitiveContains("site") }
    var calloutList: [Callout] { callouts?.items ?? [] }
    var hasMinimap: Bool { link(displayIcon) != nil && !calloutList.isEmpty && (xMultiplier?.value ?? 0) != 0 }

    /// Callout world position -> 0...1 position on the minimap image.
    func normalized(_ c: Callout) -> CGPoint {
        let x = (c.location?.y ?? 0) * (xMultiplier?.value ?? 0) + (xScalarToAdd?.value ?? 0)
        let y = (c.location?.x ?? 0) * (yMultiplier?.value ?? 0) + (yScalarToAdd?.value ?? 0)
        return CGPoint(x: x, y: y)
    }
}

struct Callout: Decodable, Identifiable {
    let regionName: String?
    let superRegionName: String?
    let location: CalloutLocation?

    var id: String { "\(superRegionName ?? "")|\(regionName ?? "")|\(location?.x ?? 0)|\(location?.y ?? 0)" }
    var name: String {
        let r = regionName ?? ""
        let s = superRegionName ?? ""
        if s.count <= 1 && !s.isEmpty { return "\(s) \(r)" }
        return r
    }
}

struct CalloutLocation: Decodable {
    let x: Double
    let y: Double
}

// MARK: - Meta

struct GameVersion: Decodable {
    let branch: String?
    let version: String?
    let buildVersion: String?
    let riotClientVersion: String?
    let buildDate: String?

    /// "release-13.06" -> "13.06"
    var patch: String {
        if let b = branch, let r = b.range(of: "release-") { return String(b[r.upperBound...]) }
        if let v = version { return v.split(separator: ".").prefix(2).joined(separator: ".") }
        return "—"
    }
    var date: Date? { buildDate.flatMap(parseDate) }
}

struct Season: Decodable, Identifiable {
    let uuid: String
    let displayName: String?
    let title: String?
    let type: String?
    let startTime: String?
    let endTime: String?
    let parentUuid: String?

    var id: String { uuid }
    var isAct: Bool { (type ?? "").hasSuffix("Act") }
    var start: Date? { startTime.flatMap(parseDate) }
    var end: Date? { endTime.flatMap(parseDate) }
    func isCurrent(_ now: Date = Date()) -> Bool {
        guard let s = start, let e = end else { return false }
        return s <= now && now < e
    }
}

struct CompetitiveTierSet: Decodable {
    let uuid: String
    let tiers: Lossy<Rank>?
}

struct Rank: Decodable, Identifiable {
    let tier: Int
    let tierName: String?
    let divisionName: String?
    let color: String?
    let backgroundColor: String?
    let smallIcon: String?
    let largeIcon: String?

    var id: Int { tier }
}

struct GameMode: Decodable, Identifiable {
    let uuid: String
    let displayName: String?
    let description: String?
    let duration: String?
    let displayIcon: String?
    let listViewIconTall: String?

    var id: String { uuid }
}

struct StoreBundle: Decodable, Identifiable {
    let uuid: String
    let displayName: String?
    let displayNameSubText: String?
    let description: String?
    let displayIcon: String?
    let displayIcon2: String?
    let verticalPromoImage: String?

    var id: String { uuid }
}

private let isoFull: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()
private let isoPlain = ISO8601DateFormatter()

func parseDate(_ s: String) -> Date? {
    isoPlain.date(from: s) ?? isoFull.date(from: s)
}
