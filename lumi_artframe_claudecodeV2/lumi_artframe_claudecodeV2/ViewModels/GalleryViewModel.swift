import SwiftUI

@Observable
class GalleryViewModel {
    var artworks: [Artwork] = []
    var isLoading = false
    var errorMessage: String?
    var isGridMode = false

    private let galleryService: any GalleryServiceProtocol

    init(galleryService: any GalleryServiceProtocol) {
        self.galleryService = galleryService
    }

    func loadGallery() async {
        isLoading = true
        errorMessage = nil
        do {
            artworks = try await galleryService.fetchGallery()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func toggleViewMode() {
        withAnimation {
            isGridMode.toggle()
        }
    }
}
