import Foundation

final class MockCreationService: CreationServiceProtocol, @unchecked Sendable {
    func uploadImage(imageData: Data) async throws -> UploadResult {
        try await Task.sleep(for: .seconds(1.5))
        return UploadResult(
            id: "upload-\(UUID().uuidString.prefix(8))",
            imageURL: "https://picsum.photos/seed/uploaded/400/500"
        )
    }

    func generateStory(imageURL: String, audioTranscript: String?) async throws -> StoryResult {
        try await Task.sleep(for: .seconds(3))
        return StoryResult(
            id: "story-\(UUID().uuidString.prefix(8))",
            storyTitle: "The Magic Garden",
            storyContent: "In a hidden corner of the backyard, little Lily discovered a garden where flowers could sing and butterflies told stories. Every petal held a different melody, and every leaf whispered ancient tales of wonder. Lily spent the whole afternoon listening, and when she finally went home, she carried the music of the garden in her heart forever.",
            videoPrompt: "A magical garden with singing flowers and storytelling butterflies, a little girl listening in wonder, whimsical fantasy animation",
            creativityAnalysis: "The artwork shows remarkable attention to natural detail and a vibrant use of color. The garden setting reflects a nurturing personality with deep appreciation for beauty.",
            moodAnalysis: "The soft, warm colors and peaceful garden imagery suggest a calm and contented emotional state. The child appears to be feeling safe and happy.",
            additionalInsights: "The discovery theme is common in this age group and represents curiosity and a healthy desire for exploration. The singing flowers may symbolize the child's love of music or storytelling."
        )
    }

    func generateVideo(imageURL: String, prompt: String) async throws -> VideoSubmitResult {
        try await Task.sleep(for: .seconds(1))
        return VideoSubmitResult(
            taskID: "mock-task-\(UUID().uuidString.prefix(8))",
            status: "processing"
        )
    }

    func checkVideoStatus(taskID: String) async throws -> Artwork.VideoStatus {
        try await Task.sleep(for: .seconds(1))
        return .completed
    }

    func getVideoURL(taskID: String) async throws -> String? {
        return "https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4"
    }
}
