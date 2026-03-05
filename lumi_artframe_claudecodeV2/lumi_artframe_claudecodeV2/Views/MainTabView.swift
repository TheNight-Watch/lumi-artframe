import SwiftUI

struct MainTabView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.services) private var services
    @State private var selectedTab = 0
    @State private var creationVM: CreationViewModel?

    private let isUITesting = ProcessInfo.processInfo.arguments.contains("--uitesting")

    var body: some View {
        @Bindable var router = router
        ZStack {
            // Main tab content
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
                .safeAreaInset(edge: .bottom) {
                    // Reserve space for tab bar so content doesn't extend behind it
                    Color.clear.frame(height: 90)
                }

                // Bottom tab bar
                tabBar
            }

            // In UI testing mode, present creation flow inline (not fullScreenCover)
            // so XCUITest can query all elements in the accessibility tree.
            if isUITesting && router.showCreationFlow, let vm = creationVM {
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
                    if vm.imageData == nil {
                        vm.imageData = UIImage(systemName: "photo.artframe")?.pngData()
                    }
                }
            }
        }
        .ignoresSafeArea(.keyboard)
        // Production mode: use fullScreenCover for creation flow
        .fullScreenCover(isPresented: Binding(
            get: { !isUITesting && router.showCreationFlow },
            set: { router.showCreationFlow = $0 }
        )) {
            if let vm = creationVM {
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
            }
        }
        .onChange(of: router.showCreationFlow) { _, isShowing in
            if isShowing && creationVM == nil {
                creationVM = CreationViewModel(creationService: services.creation, audioTranscriptionService: services.audioTranscription)
            } else if !isShowing {
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
                        .background(
                            Circle()
                                .fill(Color.Theme.brutalShadow)
                                .offset(x: 4, y: 4)
                        )

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
                .ignoresSafeArea(edges: .bottom)
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
        .accessibilityIdentifier("\(label.lowercased())Tab")
    }
}

#Preview {
    MainTabView()
        .environment(AppRouter())
        .environment(\.services, .mock)
}
