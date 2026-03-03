import Foundation

final class MockGalleryService: GalleryServiceProtocol, @unchecked Sendable {
    private var artworks: [Artwork] = []

    init() {
        loadMockData()
    }

    private func loadMockData() {
        guard let url = Bundle.main.url(forResource: "artworks", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            artworks = Self.fallbackArtworks
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let decoded = try? decoder.decode([Artwork].self, from: data) {
            artworks = decoded
        } else {
            artworks = Self.fallbackArtworks
        }
    }

    func fetchGallery() async throws -> [Artwork] {
        try await Task.sleep(for: .seconds(0.5))
        return artworks
    }

    func getArtwork(id: String) async throws -> Artwork {
        guard let artwork = artworks.first(where: { $0.id == id }) else {
            throw GalleryError.artworkNotFound
        }
        return artwork
    }

    static let fallbackArtworks: [Artwork] = [
        Artwork(
            id: "mock-001",
            title: "Rainbow Dragon",
            imageURL: "https://picsum.photos/seed/art1/400/500",
            videoURL: "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4",
            videoTaskID: "task-001",
            videoStatus: .completed,
            storyTitle: "The Rainbow Dragon's Adventure",
            storyContent: "Once upon a time, in a land of swirling colors, there lived a little dragon named Spectrum. Unlike other dragons who breathed fire, Spectrum breathed beautiful rainbows that painted the sky.",
            videoPrompt: "A colorful cartoon dragon flying through clouds",
            creativityAnalysis: "The child demonstrates exceptional color awareness and imaginative thinking.",
            moodAnalysis: "The artwork conveys joy and optimism.",
            additionalInsights: "This artwork shows advanced symbolic thinking for the age group.",
            createdAt: Date()
        ),
        Artwork(
            id: "mock-002",
            title: "My Family",
            imageURL: "https://picsum.photos/seed/art2/400/500",
            videoURL: nil,
            videoTaskID: "task-002",
            videoStatus: .processing,
            storyTitle: "The Magic Family House",
            storyContent: "In a cozy house on Sunshine Street lived the happiest family in the whole wide world.",
            videoPrompt: "A warm family scene in a cozy house",
            creativityAnalysis: "Family depiction shows strong social awareness.",
            moodAnalysis: "Warm color choices indicate feelings of security and love.",
            additionalInsights: "Attention to domestic details suggests the child values routine and stability.",
            createdAt: Date().addingTimeInterval(-86400)
        ),
        Artwork(
            id: "mock-003",
            title: "Space Adventure",
            imageURL: "https://picsum.photos/seed/art3/400/500",
            videoURL: nil,
            videoTaskID: nil,
            videoStatus: .pending,
            storyTitle: "Captain Star's Mission",
            storyContent: "Captain Star zoomed through the galaxy in her sparkly spaceship, dodging asteroids and waving at friendly aliens.",
            videoPrompt: "A child astronaut in a colorful spaceship flying through space",
            creativityAnalysis: "The space theme demonstrates excellent imaginative range.",
            moodAnalysis: "Adventurous and exploratory mood.",
            additionalInsights: "The character suggests the child sees themselves as capable and brave.",
            createdAt: Date().addingTimeInterval(-172800)
        )
    ]
}

enum GalleryError: LocalizedError {
    case artworkNotFound
    case loadFailed

    var errorDescription: String? {
        switch self {
        case .artworkNotFound: return "Artwork not found"
        case .loadFailed: return "Failed to load gallery"
        }
    }
}
