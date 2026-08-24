import Foundation
import SwiftUI

struct Weapon: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let category: String?
    let defaultSkinUuid: String?
    let displayIcon: URL?
    let displayIconSmall: URL?
    let killStreamIcon: URL?
    let weaponStats: WeaponStats?
    let shopData: ShopData?
    let skins: [WeaponSkin]?

    var id: String { uuid }

    var categoryName: String {
        category?.cleanedEnum ?? "Misc"
    }

    /// Skins minus the stock weapon skin.
    var shopSkins: [WeaponSkin] {
        (skins ?? []).filter { $0.uuid != defaultSkinUuid }
    }
}

struct WeaponStats: Decodable, Hashable {
    let fireRate: FlexDouble?
    let magazineSize: Int?
    let runSpeedMultiplier: FlexDouble?
    let equipTimeSeconds: FlexDouble?
    let reloadTimeSeconds: FlexDouble?
    let firstBulletAccuracy: FlexDouble?
    let shotgunPelletCount: Int?
    let wallPenetration: String?
    let feature: String?
    let fireMode: String?
    let altFireType: String?
    let adsStats: ADSStats?
    let altShotgunStats: AltShotgunStats?
    let airBurstStats: AirBurstStats?
    let damageRanges: [DamageRange]?

    var fireRateValue: Double { fireRate?.value ?? 0 }
    var equipTimeValue: Double { equipTimeSeconds?.value ?? 0 }
    var reloadTimeValue: Double { reloadTimeSeconds?.value ?? 0 }
    var wallPenetrationName: String {
        wallPenetration?.cleanedEnum.uppercased() ?? "N/A"
    }
}

struct ADSStats: Decodable, Hashable {
    let zoomMultiplier: FlexDouble?
    let fireRate: FlexDouble?
    let runSpeedMultiplier: FlexDouble?
    let burstCount: Int?
    let firstBulletAccuracy: FlexDouble?
}

struct AltShotgunStats: Decodable, Hashable {
    let shotgunPelletCount: Int?
    let burstRate: FlexDouble?
    let burstDistance: FlexDouble?
}

struct AirBurstStats: Decodable, Hashable {
    let shotgunPelletCount: Int?
    let burstDistance: FlexDouble?
}

struct DamageRange: Decodable, Hashable {
    let rangeStartMeters: Int?
    let rangeEndMeters: Int?
    let headDamage: FlexDouble?
    let bodyDamage: FlexDouble?
    let legDamage: FlexDouble?

    var label: String { "\(rangeStartMeters ?? 0)–\(rangeEndMeters ?? 0)M" }
    var head: Double { headDamage?.value ?? 0 }
    var body: Double { bodyDamage?.value ?? 0 }
    var leg: Double { legDamage?.value ?? 0 }
}

struct ShopData: Decodable, Hashable {
    let cost: Int?
    let category: String?
    let categoryText: String?
    let shopOrderPriority: Int?
    let gridPosition: GridPosition?
    let canBeTrashed: Bool?
    let image: URL?
    let newImage: URL?
    let newImage2: URL?
}

struct GridPosition: Decodable, Hashable {
    let row: Int?
    let column: Int?
}

struct WeaponSkin: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let themeUuid: String?
    let contentTierUuid: String?
    let contentEditionUuid: String?
    let displayIcon: URL?
    let wallpaper: URL?
    let chromas: [SkinChroma]?
    let levels: [SkinLevel]?

    var id: String { uuid }

    var heroRender: URL? {
        chromas?.first?.fullRender ?? wallpaper ?? displayIcon
    }
}

struct SkinChroma: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let displayIcon: URL?
    let fullRender: URL?
    let swatch: URL?
    let streamedVideo: URL?

    var id: String { uuid }

    var preview: URL? {
        swatch ?? displayIcon ?? fullRender
    }
}

struct SkinLevel: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let levelItem: String?
    let displayIcon: URL?
    let wallpaper: URL?
    let streamedVideo: URL?

    var id: String { uuid }

    var levelItemName: String {
        levelItem?.cleanedEnum.uppercased() ?? "VARIANT"
    }
}

/// Maps a skin's `contentTierUuid` to a live /v1/contenttiers record.
/// The registry is filled from the API at launch; the static table is a
/// graceful fallback for the five launch-era tiers.
enum ContentTierMapper {
    private static var registry: [String: ContentTier] = [:]

    static func register(_ tiers: [ContentTier]) {
        registry = Dictionary(tiers.map { ($0.uuid, $0) }, uniquingKeysWith: { _, new in new })
    }

    static func tier(for uuid: String?) -> ContentTier? {
        guard let uuid else { return nil }
        return registry[uuid]
    }

    static func name(for uuid: String?) -> String? {
        tier(for: uuid)?.displayName.uppercased() ?? legacyName(for: uuid)
    }

    static func color(for uuid: String?) -> Color {
        if let tier = tier(for: uuid), let hex = tier.highlightColor {
            return Color(hexString: hex)
        }
        return legacyColor(for: uuid)
    }

    static func rank(for uuid: String?) -> Int {
        tier(for: uuid)?.rank ?? -1
    }

    static func color(forName name: String) -> Color {
        switch name.uppercased() {
        case "SELECT": return Color(hex: 0x9AA0A6)
        case "DELUXE": return Color(hex: 0x15ADA9)
        case "PREMIUM": return Color(hex: 0xE0518F)
        case "ULTRA": return Color(hex: 0xF2C94C)
        case "EXCLUSIVE": return Color(hex: 0x35D0FF)
        default: return Color.cream
        }
    }

    // Fallback for the five launch tiers (stable UUIDs).
    private static func legacyName(for uuid: String?) -> String? {
        switch uuid {
        case "0cebb8be-46d7-c12a-d306-e9907bfcde86": return "SELECT"
        case "60bca009-4182-7998-dee7-b8a2558dc369": return "DELUXE"
        case "411e4a55-4e59-7757-41f0-86a8fba43813": return "PREMIUM"
        case "e046854e-406c-37f4-6607-19a9ba8429fc": return "ULTRA"
        case "12683d76-48d7-84a3-4e09-6985794f0445": return "EXCLUSIVE"
        default: return nil
        }
    }

    private static func legacyColor(for uuid: String?) -> Color {
        switch name(for: uuid) {
        case "SELECT": return Color(hex: 0x9AA0A6)
        case "DELUXE": return Color(hex: 0x15ADA9)
        case "PREMIUM": return Color(hex: 0xE0518F)
        case "ULTRA": return Color(hex: 0xF2C94C)
        case "EXCLUSIVE": return Color(hex: 0x35D0FF)
        default: return Color.white.opacity(0.3)
        }
    }
}
