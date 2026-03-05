import Foundation
import Supabase

final class SupabaseAuthService: AuthServiceProtocol, @unchecked Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func login(email: String, password: String) async throws -> AuthUser {
        let session = try await client.auth.signIn(email: email, password: password)
        return AuthUser(id: session.user.id.uuidString, email: session.user.email ?? email)
    }

    func signup(email: String, password: String) async throws {
        _ = try await client.auth.signUp(email: email, password: password)
    }

    func logout() async throws {
        try await client.auth.signOut()
    }

    func currentUser() async -> AuthUser? {
        guard let user = try? await client.auth.session.user else { return nil }
        return AuthUser(id: user.id.uuidString, email: user.email ?? "")
    }

    func isAuthenticated() async -> Bool {
        return (try? await client.auth.session) != nil
    }
}
