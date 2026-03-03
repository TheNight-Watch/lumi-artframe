import SwiftUI

struct ProfileView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.services) private var services
    @State private var viewModel: AuthViewModel?
    @State private var artworkCount = 0
    @State private var userEmail = ""

    private var vm: AuthViewModel {
        viewModel ?? AuthViewModel(authService: services.auth)
    }

    var body: some View {
        ZStack {
            Color.Theme.bg.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    // Avatar area
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.Theme.peach)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
                                )
                                .shadow(color: Color.Theme.brutalShadow, radius: 0, x: BrutalStyle.shadowOffset, y: BrutalStyle.shadowOffset)

                            Text("😊")
                                .font(.system(size: 60))
                        }

                        Text(username)
                            .font(Typography.headline)
                            .foregroundColor(.black)

                        Text(maskedEmail)
                            .font(Typography.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)

                    // Menu items
                    VStack(spacing: 12) {
                        ProfileRow(
                            icon: "star.fill",
                            iconBackground: Color.Theme.yellow,
                            title: "My Achievements",
                            subtitle: artworkCount > 0 ? "\(artworkCount) artworks created" : "Create your first artwork!"
                        )

                        ProfileRow(
                            icon: "lock.fill",
                            iconBackground: .gray.opacity(0.3),
                            title: "Parental Controls",
                            subtitle: "Screen time management"
                        )

                        ProfileRow(
                            icon: "gearshape.fill",
                            iconBackground: .white,
                            title: "General Settings",
                            subtitle: "Sound, notifications & cache"
                        )

                        ProfileRow(
                            icon: "questionmark.circle.fill",
                            iconBackground: .white,
                            title: "Help & Feedback",
                            subtitle: ""
                        )
                    }
                    .padding(.horizontal)

                    // Logout button
                    Button {
                        Task {
                            await vm.logout(router: router)
                        }
                    } label: {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.system(size: 18))
                            Text("Logout")
                                .font(.system(size: 18, weight: .bold))
                        }
                        .foregroundColor(Color.Theme.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: BrutalStyle.cornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: BrutalStyle.cornerRadius)
                                .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
                        )
                        .shadow(color: Color.Theme.brutalShadow, radius: 0, x: BrutalStyle.shadowOffset, y: BrutalStyle.shadowOffset)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    Spacer(minLength: 100)
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = AuthViewModel(authService: services.auth)
            }
            Task {
                let user = await services.auth.currentUser()
                userEmail = user?.email ?? ""
                let artworks = (try? await services.gallery.fetchGallery()) ?? []
                artworkCount = artworks.count
            }
        }
    }

    private var username: String {
        if let atIndex = userEmail.firstIndex(of: "@") {
            return String(userEmail[userEmail.startIndex..<atIndex])
        }
        return "User"
    }

    private var maskedEmail: String {
        guard !userEmail.isEmpty else { return "" }
        guard let atIndex = userEmail.firstIndex(of: "@") else { return userEmail }
        let prefix = userEmail[userEmail.startIndex..<atIndex]
        if prefix.count <= 2 {
            return userEmail
        }
        let visible = String(prefix.prefix(2))
        let domain = String(userEmail[atIndex...])
        return "\(visible)***\(domain)"
    }
}

struct ProfileRow: View {
    let icon: String
    var iconBackground: Color = .white
    let title: String
    var subtitle: String = ""

    var body: some View {
        BrutalCard {
            HStack(spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .frame(width: 40, height: 40)
                    .background(iconBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
            .padding(16)
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView()
    }
    .environment(AppRouter())
    .environment(\.services, .mock)
}
