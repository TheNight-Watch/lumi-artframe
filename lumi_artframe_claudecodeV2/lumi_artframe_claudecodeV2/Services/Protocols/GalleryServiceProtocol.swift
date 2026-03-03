import Foundation

protocol GalleryServiceProtocol: Sendable {
    func fetchGallery() async throws -> [Artwork]
    func getArtwork(id: String) async throws -> Artwork
}
