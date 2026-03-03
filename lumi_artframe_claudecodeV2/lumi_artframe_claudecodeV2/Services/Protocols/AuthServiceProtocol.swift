import Foundation

struct AuthUser: Sendable {
    let id: String
    let email: String
}

protocol AuthServiceProtocol: Sendable {
    func login(email: String, password: String) async throws -> AuthUser
    func signup(email: String, password: String) async throws
    func logout() async throws
    func currentUser() async -> AuthUser?
    func isAuthenticated() async -> Bool
}
