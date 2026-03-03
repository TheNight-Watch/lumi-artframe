import SwiftUI

struct LoginView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.services) private var services
    @State private var viewModel: AuthViewModel?

    private var vm: AuthViewModel {
        viewModel ?? AuthViewModel(authService: services.auth)
    }

    var body: some View {
        let authVM = vm
        ZStack {
            Color.Theme.bg.ignoresSafeArea()

            // Floating decorations
            FloatingDecoration()

            ScrollView {
                VStack(spacing: 24) {
                    // Top bar
                    HStack {
                        BrutalCircleButton(icon: "xmark") {}
                        Spacer()
                        BrutalBadge(text: "Pass", icon: "ticket.fill")
                        Spacer()
                        Color.clear.frame(width: 44, height: 44)
                    }
                    .padding(.horizontal)

                    // Title
                    VStack(spacing: 8) {
                        Text(authVM.isLoginMode ? "Login" : "Join")
                            .font(Typography.title)
                            .foregroundColor(.black)
                            .overlay(alignment: .bottom) {
                                Color.Theme.peach
                                    .frame(height: 12)
                                    .offset(y: 4)
                                    .opacity(0.6)
                            }

                        Text("Enter email and password to start the magic!")
                            .font(.system(size: 18))
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)

                    // Form
                    VStack(spacing: 16) {
                        BrutalTextField(label: "Email", text: Binding(
                            get: { authVM.email },
                            set: { authVM.email = $0 }
                        ), keyboardType: .emailAddress)
                        .accessibilityIdentifier("emailField")

                        BrutalSecureField(label: "Password", text: Binding(
                            get: { authVM.password },
                            set: { authVM.password = $0 }
                        ))
                        .accessibilityIdentifier("passwordField")
                    }
                    .padding(.horizontal)

                    // Submit button
                    BrutalButton(
                        title: authVM.isLoginMode ? "Login Now" : "Register",
                        icon: "wand.and.stars",
                        isLoading: authVM.isLoading
                    ) {
                        Task {
                            await authVM.submit(router: router)
                        }
                    }
                    .accessibilityIdentifier("loginButton")
                    .padding(.horizontal)

                    // Mode switch
                    Button {
                        withAnimation {
                            authVM.isLoginMode.toggle()
                        }
                    } label: {
                        Text(authVM.isLoginMode ? "No account? Register" : "Already have an account? Login")
                            .font(.system(size: 16))
                            .foregroundColor(Color.Theme.red)
                    }

                    Spacer(minLength: 40)

                    // Privacy notice
                    Text("By continuing, you agree to our Terms of Service and Children's Privacy Policy")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 16)
            }
        }
        .toast(isPresented: Binding(
            get: { authVM.showToast },
            set: { authVM.showToast = $0 }
        ), message: authVM.toastMessage, type: authVM.toastType)
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(authService: services.auth)
            }
        }
    }
}

// MARK: - Brutal Text Fields

struct BrutalTextField: View {
    let label: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.Theme.bg)
                .offset(x: 16, y: 10)
                .zIndex(1)

            TextField("", text: $text)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .font(.system(size: 18))
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.Theme.brutalBorder, lineWidth: 3)
                )
        }
    }
}

struct BrutalSecureField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.Theme.bg)
                .offset(x: 16, y: 10)
                .zIndex(1)

            SecureField("", text: $text)
                .font(.system(size: 18))
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.Theme.brutalBorder, lineWidth: 3)
                )
        }
    }
}

// MARK: - Floating Decoration

struct FloatingDecoration: View {
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        ZStack {
            Image(systemName: "star.fill")
                .font(.system(size: 30))
                .foregroundColor(Color.Theme.yellow)
                .offset(x: 120, y: -280 + floatOffset)

            Image(systemName: "cloud.fill")
                .font(.system(size: 40))
                .foregroundColor(Color.Theme.peach)
                .offset(x: -140, y: -180 + floatOffset * 0.7)
        }
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
            ) {
                floatOffset = 15
            }
        }
    }
}

#Preview {
    LoginView()
        .environment(AppRouter())
        .environment(\.services, .mock)
}
