import Foundation

enum APIError: LocalizedError {
    case badStatus(Int)
    case offline(String)

    var errorDescription: String? {
        switch self {
        case .badStatus(let code): return "The server answered \(code)."
        case .offline(let message): return message
        }
    }
}

/// Talks to the public valorant-api.com. Every successful response is also
/// written to the caches folder, so the app still opens without a signal.
enum API {
    static let base = URL(string: "https://valorant-api.com/v1/")!

    static let session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.urlCache = URLCache(memoryCapacity: 32 * 1024 * 1024, diskCapacity: 256 * 1024 * 1024)
        cfg.requestCachePolicy = .useProtocolCachePolicy
        cfg.timeoutIntervalForRequest = 30
        cfg.waitsForConnectivity = false
        return URLSession(configuration: cfg)
    }()

    private static var cacheDir: URL {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("api", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    private static func cacheFile(_ path: String) -> URL {
        let safe = path.map { $0.isLetter || $0.isNumber ? $0 : "_" }
        return cacheDir.appendingPathComponent(String(safe) + ".json")
    }

    static func data(_ path: String) async throws -> Data {
        guard let url = URL(string: path, relativeTo: base) else { throw URLError(.badURL) }
        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                throw APIError.badStatus(http.statusCode)
            }
            try? data.write(to: cacheFile(path), options: .atomic)
            return data
        } catch {
            if let saved = try? Data(contentsOf: cacheFile(path)) { return saved }
            throw error
        }
    }

    static func list<T: Decodable>(_ path: String, _ type: T.Type) async throws -> [T] {
        let raw = try await data(path)
        return try JSONDecoder().decode(Envelope<Lossy<T>>.self, from: raw).data.items
    }

    static func one<T: Decodable>(_ path: String, _ type: T.Type) async throws -> T {
        let raw = try await data(path)
        return try JSONDecoder().decode(Envelope<T>.self, from: raw).data
    }

    static func listOrEmpty<T: Decodable>(_ path: String, _ type: T.Type) async -> [T] {
        (try? await list(path, type)) ?? []
    }

    static func oneOrNil<T: Decodable>(_ path: String, _ type: T.Type) async -> T? {
        try? await one(path, type)
    }
}
