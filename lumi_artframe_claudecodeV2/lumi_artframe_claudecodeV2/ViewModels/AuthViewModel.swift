import SwiftUI

@Observable
class AuthViewModel {
    var email = ""
    var password = ""
    var isLoginMode = true
    var isLoading = false
    var toastMessage = ""
    var toastType: ToastType = .success
    var showToast = false

    private let authService: any AuthServiceProtocol

    init(authService: any AuthServiceProtocol) {
        self.authService = authService
    }

    var isFormValid: Bool {
        email.contains("@") && password.count >= 6
    }

    func submit(router: AppRouter) async {
        guard !email.isEmpty else {
            showError("Please enter your email")
            return
        }
        guard email.contains("@") else {
            showError("Please enter a valid email")
            return
        }
        guard password.count >= 6 else {
            showError("Password must be at least 6 characters")
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            if isLoginMode {
                _ = try await authService.login(email: email, password: password)
                showSuccess("Login successful!")
                try? await Task.sleep(for: .seconds(1))
                router.navigate(to: .main)
            } else {
                try await authService.signup(email: email, password: password)
                showSuccess("Registration successful! Please login")
                isLoginMode = true
                password = ""
            }
        } catch {
            showError(error.localizedDescription)
        }
    }

    func logout(router: AppRouter) async {
        try? await authService.logout()
        router.navigate(to: .login)
    }

    func checkAuth(router: AppRouter) async {
        if await authService.isAuthenticated() {
            router.navigate(to: .main)
        } else {
            router.navigate(to: .login)
        }
    }

    private func showError(_ message: String) {
        toastMessage = message
        toastType = .error
        showToast = true
    }

    private func showSuccess(_ message: String) {
        toastMessage = message
        toastType = .success
        showToast = true
    }
}
