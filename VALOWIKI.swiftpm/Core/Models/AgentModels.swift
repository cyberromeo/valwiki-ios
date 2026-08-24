import Foundation

struct Agent: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let description: String?
    let developerName: String?
    let releaseDate: String?
    let displayIcon: URL?
    let displayIconSmall: URL?
    let bustPortrait: URL?
    let fullPortrait: URL?
    let fullPortraitV2: URL?
    let killfeedPortrait: URL?
    let minimapPortrait: URL?
    let background: URL?
    let backgroundGradientColors: [String]?
    let backgroundPosition: String?
    let role: AgentRole?
    let abilities: [AgentAbility]?
    let voiceLine: LenientBox<VoiceLine>?
    let isPlayableCharacter: Bool?
    let isAvailableForTest: Bool?
    let isBaseContent: Bool?

    var id: String { uuid }

    var portrait: URL? {
        fullPortraitV2 ?? fullPortrait ?? bustPortrait ?? displayIcon
    }

    var gradientColors: [String] {
        backgroundGradientColors ?? []
    }
}

struct AgentRole: Decodable, Hashable {
    let uuid: String?
    let displayName: String?
    let description: String?
    let displayIcon: URL?
}

struct AgentAbility: Decodable, Hashable {
    let slot: String?
    let displayName: String?
    let description: String?
    let displayIcon: URL?
}

struct VoiceLine: Decodable, Hashable {
    let uuid: String?
    let displayName: String?
    let minDuration: [Double]?
    let maxDuration: [Double]?
    let mediaList: [VoiceMedia]?
}

struct VoiceMedia: Decodable, Hashable {
    let id: Int?
    let wwise: String?
    let wave: URL?
}

extension Agent {
    var voiceLineData: VoiceLine? { voiceLine?.value }
    var voiceLineURL: URL? {
        voiceLineData?.mediaList?.first(where: { $0.wave != nil })?.wave
    }
}
