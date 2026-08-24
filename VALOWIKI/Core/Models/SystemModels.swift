import Foundation

struct GameVersion: Decodable, Hashable {
    let manifestId: String?
    let branch: String?
    let version: String?
    let buildVersion: String?
    let engineVersion: String?
    let riotClientVersion: String?
    let riotClientBuild: String?
    let buildDate: String?
}

struct SkinTheme: Identifiable, Decodable, Hashable {
    let uuid: String
    let displayName: String
    let displayIcon: URL?
    let storeFeaturedImage: URL?

    var id: String { uuid }
}
