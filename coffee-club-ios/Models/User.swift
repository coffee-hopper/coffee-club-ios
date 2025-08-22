import Foundation

struct User: Codable, Equatable {
    let id: Int
    let name: String
    let role: String
    let picture: String?
}
