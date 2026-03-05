import Foundation

struct UploadResult: Sendable {
    let id: String
    let imageURL: String
}

struct StoryResult: Codable, Sendable {
    let id: String
    let storyTitle: String
    let storyContent: String
    let videoPrompt: String
    let creativityAnalysis: String
    let moodAnalysis: String
    let additionalInsights: String

    enum CodingKeys: String, CodingKey {
        case id
        case storyTitle = "story_title"
        case storyContent = "story_content"
        case videoPrompt = "video_prompt"
        case creativityAnalysis = "creativity_analysis"
        case moodAnalysis = "mood_analysis"
        case additionalInsights = "additional_insights"
    }
}

struct VideoSubmitResult: Sendable {
    let taskID: String
    let status: String
}

protocol CreationServiceProtocol: Sendable {
    func uploadImage(imageData: Data) async throws -> UploadResult
    func generateStory(artworkId: String, imageURL: String, audioTranscript: String?) async throws -> StoryResult
    func generateVideo(artworkId: String, imageURL: String, prompt: String) async throws -> VideoSubmitResult
    func checkVideoStatus(taskID: String) async throws -> Artwork.VideoStatus
    func getVideoURL(taskID: String) async throws -> String?
}
