import SwiftUI

struct GalleryView: View {
    @Environment(AppRouter.self) private var router
    @Environment(\.services) private var services
    @State private var viewModel: GalleryViewModel?

    private var vm: GalleryViewModel {
        viewModel ?? GalleryViewModel(galleryService: services.gallery)
    }

    var body: some View {
        let galleryVM = vm
        ZStack {
            Color.Theme.bg.ignoresSafeArea()

            if galleryVM.isLoading {
                loadingView
            } else if let error = galleryVM.errorMessage {
                errorView(error)
            } else if galleryVM.artworks.isEmpty {
                emptyView
            } else if galleryVM.isGridMode {
                GalleryGridView(artworks: galleryVM.artworks) { artwork in
                    router.showDetail(artwork: artwork)
                }
            } else {
                carouselView(galleryVM.artworks)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                avatarButton
            }
            ToolbarItem(placement: .principal) {
                BrutalBadge(text: "My Gallery", icon: "photo.stack.fill")
            }
            ToolbarItem(placement: .topBarTrailing) {
                BrutalCircleButton(
                    icon: galleryVM.isGridMode ? "square.fill.on.square.fill" : "square.grid.2x2.fill",
                    size: 36
                ) {
                    galleryVM.toggleViewMode()
                }
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = GalleryViewModel(galleryService: services.gallery)
            }
            Task {
                await vm.loadGallery()
            }
        }
    }

    // MARK: - Subviews

    private var avatarButton: some View {
        ZStack {
            Circle()
                .fill(Color.Theme.peach)
                .frame(width: 36, height: 36)
                .overlay(
                    Circle()
                        .stroke(Color.Theme.brutalBorder, lineWidth: 2)
                )
                .shadow(color: Color.Theme.brutalShadow, radius: 0, x: 2, y: 2)

            Text("😊")
                .font(.system(size: 18))
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Loading gallery...")
                .font(.system(size: 16))
                .foregroundColor(.gray)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text(message)
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            BrutalButton(title: "Retry", backgroundColor: Color.Theme.red) {
                Task { await vm.loadGallery() }
            }
            .frame(width: 160)
        }
        .padding()
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.stack")
                .font(.system(size: 64))
                .foregroundColor(.gray.opacity(0.5))
            Text("Gallery is empty.\nCreate your first artwork!")
                .font(.system(size: 18))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
    }

    private func carouselView(_ artworks: [Artwork]) -> some View {
        TabView {
            ForEach(artworks) { artwork in
                ArtworkCard(artwork: artwork) {
                    router.showDetail(artwork: artwork)
                }
                .padding(.horizontal, 20)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .frame(height: 520)
    }
}

#Preview {
    NavigationStack {
        GalleryView()
    }
    .environment(AppRouter())
    .environment(\.services, .mock)
}
