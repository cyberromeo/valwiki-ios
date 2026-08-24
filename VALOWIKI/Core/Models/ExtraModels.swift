import Foundation

// MARK: - /v1/bundles

struct ItemBundle: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let displayNameSubText: String?
    let description: String?
    let extraDescription: String?
    let promoDescription: String?
    let useAdditionalContext: Bool?
    let displayIcon: URL?
    let displayIcon2: URL?
    let displayIcon3: URL?
    let logoIcon: URL?
    let verticalPromoImage: URL?

    var id: String { uuid }
}

// MARK: - /v1/ceremonies

struct Ceremony: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String

    var id: String { uuid }
}

// MARK: - /v1/gamemodes/equippables

struct GameModeEquippable: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let category: String?
    let displayIcon: URL?
    let killStreamIcon: URL?

    var id: String { uuid }

    var categoryName: String {
        category?.cleanedEnum.uppercased() ?? "ITEM"
    }
}

// MARK: - /v1/contenttiers

struct ContentTier: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let devName: String?
    let rank: Int?
    let juiceValue: Int?
    let juiceCost: Int?
    let highlightColor: String?
    let displayIcon: URL?

    var id: String { uuid }
}
