import SwiftUI

struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.services) private var services
    @State private var selectedTab = 0
    @State private var creationVM: CreationViewModel?

    var body: some View {
        @Bindable var router = router
        ZStack(alignment: .bottom) {
            // Content area
            Group {
                switch selectedTab {
                case 0:
                    NavigationStack {
                        GalleryView()
                    }
                default:
                    NavigationStack {
                        ProfileView()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Bottom tab bar
            tabBar
        }
        .ignoresSafeArea(.keyboard)
        .fullScreenCover(isPresented: $router.showCreationFlow) {
            let vm = creationVM ?? CreationViewModel(creationService: services.creation)
            NavigationStack(path: $router.creationPath) {
                CameraView()
                    .navigationDestination(for: CreationRoute.self) { route in
                        switch route {
                        case .camera:
                            CameraView()
                        case .description:
                            DescriptionView()
                        case .generation:
                            GenerationView()
                        case .detail:
                            DetailView()
                        }
                    }
            }
            .environment(router)
            .environment(vm)
            .onAppear {
                if creationVM == nil {
                    creationVM = vm
                }
            }
        }
        .onChange(of: router.showCreationFlow) { _, isShowing in
            if !isShowing {
                creationVM?.reset()
                creationVM = nil
            }
        }
        .fullScreenCover(isPresented: $router.showDetailFromGallery) {
            if let artwork = router.selectedDetailArtwork {
                NavigationStack {
                    DetailView(fallbackArtwork: artwork)
                }
                .environment(router)
            }
        }
    }

    private var tabBar: some View {
        HStack {
            // Gallery tab
            tabButton(icon: "photo.stack.fill", label: "Gallery", index: 0)

            Spacer()

            // FAB - Create button
            Button {
                router.startCreation()
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.Theme.red)
                        .frame(width: 64, height: 64)
                        .overlay(
                            Circle()
                                .stroke(Color.Theme.brutalBorder, lineWidth: BrutalStyle.borderWidth)
                        )
                        .shadow(color: Color.Theme.brutalShadow, radius: 0, x: 4, y: 4)

                    Image(systemName: "plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .accessibilityIdentifier("createButton")
            .offset(y: -20)

            Spacer()

            // Profile tab
            tabButton(icon: "person.crop.circle.fill", label: "Profile", index: 1)
        }
        .padding(.horizontal, 32)
        .padding(.top, 12)
        .padding(.bottom, 34)
        .background(
            Color.Theme.yellow
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(Color.Theme.brutalBorder)
                        .frame(height: 4)
                }
        )
    }

    private func tabButton(icon: String, label: String, index: Int) -> some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                Text(label)
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(selectedTab == index ? .black : .gray)
        }
    }
}

#Preview {
    MainTabView()
        .environment(AppRouter())
        .environment(\.services, .mock)
}
