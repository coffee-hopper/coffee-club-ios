import Foundation

protocol AuthServiceProtocol {
    /// Starts Google OAuth, returns JWT token + user profile
    func signIn() async throws -> (token: String, user: User)
    /// Fetches profile with an existing token (used on restore)
    func fetchProfile(token: String) async throws -> User
}

