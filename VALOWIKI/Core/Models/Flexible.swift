import Foundation

/// The API mixes JSON numbers and numeric strings for the same fields
/// (e.g. `fireRate: 11` vs `equipTimeSeconds: "0.75"`), so every risky
/// numeric decodes through this lossless wrapper.
enum FlexDouble: Decodable, Hashable {
    case double(Double)
    case string(String)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let double = try? container.decode(Double.self) {
            self = .double(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else {
            self = .double(0)
        }
    }

    var value: Double? {
        switch self {
        case .double(let double): return double
        case .string(let string): return Double(string)
        }
    }
}

/// Lenient box: if Riot ever reshapes an optional nested payload, the whole
/// parent decodes anyway and the feature degrades to nil instead of failing.
struct LenientBox<T: Decodable>: Decodable {
    let value: T?

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        value = try? container.decode(T.self)
    }
}

extension LenientBox: Hashable where T: Hashable {}
