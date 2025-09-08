import Foundation

protocol AuthServiceProtocol {
    @MainActor
    func signIn() async throws -> (token: String, user: User)

    func fetchProfile(token: String) async throws -> User

    @MainActor
    func signOut()
}
