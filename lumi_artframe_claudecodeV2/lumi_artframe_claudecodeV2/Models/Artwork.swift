import Foundation

struct Artwork: Identifiable, Codable, Equatable, Sendable {
    let id: String
    var title: String?
    let imageURL: String
    var videoURL: String?
    var videoTaskID: String?
    var videoStatus: VideoStatus
    var storyTitle: String?
    var storyContent: String?
    var videoPrompt: String?
    var creativityAnalysis: String?
    var moodAnalysis: String?
    var additionalInsights: String?
    let createdAt: Date

    enum VideoStatus: String, Codable, Sendable {
        case pending
        case processing
        case completed
        case failed
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case imageURL = "image_url"
        case videoURL = "video_url"
        case videoTaskID = "video_task_id"
        case videoStatus = "video_status"
        case storyTitle = "story_title"
        case storyContent = "story_content"
        case videoPrompt = "video_prompt"
        case creativityAnalysis = "creativity_analysis"
        case moodAnalysis = "mood_analysis"
        case additionalInsights = "additional_insights"
        case createdAt = "created_at"
    }
}
