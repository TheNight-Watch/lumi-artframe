import Foundation
import Supabase

final class SupabaseGalleryService: GalleryServiceProtocol, @unchecked Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func fetchGallery() async throws -> [Artwork] {
        let response: [Artwork] = try await client
            .from("artworks")
            .select()
            .order("created_at", ascending: false)
            .execute()
            .value
        return response
    }

    func getArtwork(id: String) async throws -> Artwork {
        let response: Artwork = try await client
            .from("artworks")
            .select()
            .eq("id", value: id)
            .single()
            .execute()
            .value
        return response
    }
}
