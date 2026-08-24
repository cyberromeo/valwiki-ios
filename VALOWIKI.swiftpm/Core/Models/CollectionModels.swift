import Foundation

struct Buddy: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let isHiddenIfNotOwned: Bool?
    let themeUuid: String?
    let displayIcon: URL?
    let levels: [BuddyLevel]?

    var id: String { uuid }
}

struct BuddyLevel: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let charmLevel: Int?
    let hideIfNotOwned: Bool?
    let displayIcon: URL?

    var id: String { uuid }
}

struct PlayerCard: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let isHiddenIfNotOwned: Bool?
    let displayIcon: URL?
    let smallArt: URL?
    let wideArt: URL?
    let largeArt: URL?

    var id: String { uuid }
}

struct Spray: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let hideIfNotOwned: Bool?
    let displayIcon: URL?
    let fullTransparentIcon: URL?
    let isNullSpray: Bool?

    var id: String { uuid }

    enum CodingKeys: String, CodingKey {
        case uuid, displayName, hideIfNotOwned, displayIcon
        case fullTransparentIcon
        case isNullSpray = "isNullSpray"
    }
}

struct SprayLevel: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let sprayLevel: Int?
    let displayIcon: URL?

    var id: String { uuid }
}

struct PlayerTitle: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let titleText: String?
    let isHiddenIfNotOwned: Bool?

    var id: String { uuid }
}

struct Currency: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let displayNameSingular: String?
    let displayIcon: URL?
    let largeIcon: URL?

    var id: String { uuid }
}
