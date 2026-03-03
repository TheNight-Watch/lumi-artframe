import Foundation

final class MockAuthService: AuthServiceProtocol, @unchecked Sendable {
    private var authenticatedUser: AuthUser?

    init(preAuthenticated: Bool = false) {
        if preAuthenticated {
            authenticatedUser = AuthUser(id: "mock-user-001", email: "alice@example.com")
        }
    }

    func login(email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(for: .seconds(1))
        guard password.count >= 6 else {
            throw AuthError.invalidCredentials
        }
        let user = AuthUser(id: "mock-user-001", email: email)
        authenticatedUser = user
        return user
    }

    func signup(email: String, password: String) async throws {
        try await Task.sleep(for: .seconds(1))
        guard email.contains("@") else {
            throw AuthError.invalidEmail
        }
        guard password.count >= 6 else {
            throw AuthError.weakPassword
        }
    }

    func logout() async throws {
        authenticatedUser = nil
    }

    func currentUser() async -> AuthUser? {
        authenticatedUser
    }

    func isAuthenticated() async -> Bool {
        authenticatedUser != nil
    }
}

enum AuthError: LocalizedError {
    case invalidCredentials
    case invalidEmail
    case weakPassword
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials: return "Invalid email or password"
        case .invalidEmail: return "Please enter a valid email address"
        case .weakPassword: return "Password must be at least 6 characters"
        case .networkError: return "Network connection error, please try again"
        }
    }
}
