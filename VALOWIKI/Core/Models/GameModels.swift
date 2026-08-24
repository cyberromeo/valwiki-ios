import Foundation

struct GameMode: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let description: String?
    let duration: String?
    let allowsMatchTimeouts: Bool?
    let allowsCustomGameReplays: Bool?
    let isTeamVoiceAllowed: Bool?
    let isMinimapHidden: Bool?
    let orbCount: Int?
    let roundsPerHalf: Int?
    let displayIcon: URL?
    let listViewIconTall: URL?

    var id: String { uuid }
}

struct GearItem: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let description: String?
    let descriptions: [String]?
    let details: [GearDetail]?
    let displayIcon: URL?
    let shopData: GearShopData?

    var id: String { uuid }
}

struct GearDetail: Decodable, Hashable {
    let name: String?
    let value: String?
}

struct GearShopData: Decodable, Hashable {
    let cost: Int?
    let category: String?
    let categoryText: String?
    let canBeTrashed: Bool?
    let newImage: URL?
}

struct Season: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let title: String?
    let type: String?
    let startTime: String?
    let endTime: String?
    let parentUuid: String?

    var id: String { uuid }

    var typeName: String {
        type?.cleanedEnum.uppercased() ?? "SEASON"
    }

    var rangeText: String? {
        guard let start = startTime?.isoDate else { return nil }
        let startText = start.formatted(.dateTime.month(.abbreviated).day().year())
        if let end = endTime?.isoDate {
            return "\(startText) → \(end.formatted(.dateTime.month(.abbreviated).day().year()))"
        }
        return startText
    }

    var isLive: Bool {
        guard let start = startTime?.isoDate, let end = endTime?.isoDate else { return false }
        return start <= Date() && Date() <= end
    }
}

struct CompetitiveTierList: Decodable, Hashable {
    let uuid: String
    let assetObjectName: String?
    let tiers: [Tier]?

    var episodeLabel: String {
        let digits = (assetObjectName ?? "").filter(\.isNumber)
        return digits.isEmpty ? (assetObjectName?.cleanedEnum.uppercased() ?? "EPISODE") : "EP \(digits)"
    }
}

struct Tier: Identifiable, Decodable, Hashable {
    let tier: Int
    let tierName: String?
    let division: String?
    let divisionName: String?
    let color: String?
    let backgroundColor: String?
    let smallIcon: URL?
    let largeIcon: URL?
    let rankTriangleDownIcon: URL?
    let rankTriangleUpIcon: URL?

    var id: Int { tier }
}

/// Matches the live /v1/contracts payload: chapters live under `content`
/// and every level wraps a `reward` object.
struct Contract: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String?
    let displayIcon: URL?
    let shipIt: Bool?
    let useLevelVPCostOverride: Bool?
    let levelVPCostOverride: Int?
    let freeRewardScheduleUuid: String?
    let content: ContractContent?
    let premiumRewardScheduleUuid: String?
    let premiumVPCost: Int?

    var id: String { uuid }

    var title: String {
        guard let displayName, !displayName.isEmpty else { return "AGENT CONTRACT" }
        return displayName.uppercased()
    }

    var chapters: [ContractChapter] {
        content?.chapters ?? []
    }

    var levelCount: Int {
        chapters.reduce(0) { $0 + ($1.levels?.count ?? 0) }
    }
}

struct ContractContent: Decodable, Hashable {
    let relationType: String?
    let relationUuid: String?
    let chapters: [ContractChapter]?
    let premiumRewardScheduleUuid: String?
    let premiumVPCost: Int?
}

struct ContractChapter: Decodable, Hashable {
    let isEpilogue: Bool?
    let levels: [ContractLevel]?
}

struct ContractLevel: Decodable, Hashable {
    let reward: ContractReward?
    let xp: Int?
    let vpCost: Int?
    let isPurchasableWithVP: Bool?
    let doughCost: Int?
    let isPurchasableWithDough: Bool?
}

struct ContractReward: Decodable, Hashable {
    let type: String?
    let uuid: String?
    let amount: Int?
    let isHighlighted: Bool?

    var typeName: String {
        (type ?? "REWARD").cleanedEnum.uppercased()
    }
}

struct EsportsEvent: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let shortDisplayName: String?
    let startTime: String?
    let endTime: String?

    var id: String { uuid }

    var rangeText: String? {
        guard let start = startTime?.isoDate else { return nil }
        let startText = start.formatted(.dateTime.month(.abbreviated).day().year())
        if let end = endTime?.isoDate {
            return "\(startText) → \(end.formatted(.dateTime.month(.abbreviated).day().year()))"
        }
        return startText
    }

    var isLive: Bool {
        guard let start = startTime?.isoDate, let end = endTime?.isoDate else { return false }
        return start <= Date() && Date() <= end
    }
}
