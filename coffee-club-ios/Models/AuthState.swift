import Foundation

enum AuthState: Equatable {
    case idle
    case loading
    case authenticated(user: User, token: String)
    case signedOut
    case error(message: String)
}
