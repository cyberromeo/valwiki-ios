import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let status: Int
    let data: T
}

enum APIError: LocalizedError {
    case badStatus(Int)
    case badPayload

    var errorDescription: String? {
        switch self {
        case .badStatus(let code): return "UPLINK ERROR // STATUS \(code)"
        case .badPayload: return "UPLINK ERROR // BAD PAYLOAD"
        }
    }
}

enum ValorantAPI {
    static let base = URL(string: "https://valorant-api.com/v1")!

    static func url(_ path: String) -> URL {
        URL(string: path, relativeTo: base) ?? base
    }

    static func fetch<T: Decodable>(_ path: String) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url(path))
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.badStatus(code)
        }
        do {
            return try JSONDecoder().decode(APIResponse<T>.self, from: data).data
        } catch {
            throw APIError.badPayload
        }
    }

    static func fetchRaw(_ path: String) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(from: url(path))
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? -1
            throw APIError.badStatus(code)
        }
        return data
    }
}
