import Foundation

enum CodableValue: Codable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    case array([CodableValue])
    case object([String: CodableValue])

    init(from decoder: Decoder) throws {
        let c = try decoder.singleValueContainer()
        if c.decodeNil() {
            self = .null
            return
        }
        if let v = try? c.decode(Bool.self) {
            self = .bool(v)
            return
        }
        if let v = try? c.decode(Int.self) {
            self = .int(v)
            return
        }
        if let v = try? c.decode(Double.self) {
            self = .double(v)
            return
        }
        if let v = try? c.decode(String.self) {
            self = .string(v)
            return
        }
        if let v = try? c.decode([String: CodableValue].self) {
            self = .object(v)
            return
        }
        if let v = try? c.decode([CodableValue].self) {
            self = .array(v)
            return
        }
        throw DecodingError.typeMismatch(
            CodableValue.self,
            .init(codingPath: c.codingPath, debugDescription: "Unsupported JSON")
        )
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        switch self {
        case .null: try c.encodeNil()
        case .bool(let v): try c.encode(v)
        case .int(let v): try c.encode(v)
        case .double(let v): try c.encode(v)
        case .string(let v): try c.encode(v)
        case .object(let v): try c.encode(v)
        case .array(let v): try c.encode(v)
        }
    }
}

struct NotificationDTO: Decodable, Identifiable, Hashable {
    let id: Int
    let type: String
    let title: String
    let body: String
    let code: String
    let metadata: [String: CodableValue]?
    let isRead: Bool
    let readAt: String?
    let createdAt: String
}

struct NotificationListResponse: Decodable {
    let items: [NotificationDTO]
    let nextAfterId: Int?
}
struct UnreadCountResponse: Decodable { let count: Int }
struct UpdatedResponse: Decodable { let updated: Int }
struct DeletedResponse: Decodable { let deleted: Int }
