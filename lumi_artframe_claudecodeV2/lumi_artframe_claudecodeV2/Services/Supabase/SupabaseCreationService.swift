import Foundation
import Supabase

final class SupabaseCreationService: CreationServiceProtocol, @unchecked Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func uploadImage(imageData: Data) async throws -> UploadResult {
        let result: UploadResponse = try await client.functions.invoke(
            "upload-image",
            options: .init(body: imageData)
        )
        return UploadResult(id: result.id, imageURL: result.imageURL)
    }

    func generateStory(imageURL: String, audioTranscript: String?) async throws -> StoryResult {
        struct RequestBody: Encodable {
            let image_url: String
            let audio_transcript: String?
        }
        let body = RequestBody(image_url: imageURL, audio_transcript: audioTranscript)
        return try await client.functions.invoke(
            "generate-story",
            options: .init(body: body)
        )
    }

    func generateVideo(imageURL: String, prompt: String) async throws -> VideoSubmitResult {
        struct RequestBody: Encodable {
            let image_url: String
            let prompt: String
        }
        let body = RequestBody(image_url: imageURL, prompt: prompt)
        let result: VideoResponse = try await client.functions.invoke(
            "generate-video",
            options: .init(body: body)
        )
        return VideoSubmitResult(taskID: result.taskID, status: result.status)
    }

    func checkVideoStatus(taskID: String) async throws -> Artwork.VideoStatus {
        struct RequestBody: Encodable {
            let task_id: String
        }
        let body = RequestBody(task_id: taskID)
        let result: VideoStatusResponse = try await client.functions.invoke(
            "check-video-status",
            options: .init(body: body)
        )
        return Artwork.VideoStatus(rawValue: result.status) ?? .pending
    }

    func getVideoURL(taskID: String) async throws -> String? {
        struct RequestBody: Encodable {
            let task_id: String
        }
        let body = RequestBody(task_id: taskID)
        let result: VideoStatusResponse = try await client.functions.invoke(
            "check-video-status",
            options: .init(body: body)
        )
        return result.videoURL
    }
}

// MARK: - Response Types

private struct UploadResponse: Decodable {
    let id: String
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case id
        case imageURL = "image_url"
    }
}

private struct VideoResponse: Decodable {
    let taskID: String
    let status: String

    enum CodingKeys: String, CodingKey {
        case taskID = "task_id"
        case status
    }
}

private struct VideoStatusResponse: Decodable {
    let taskID: String
    let status: String
    let videoURL: String?

    enum CodingKeys: String, CodingKey {
        case taskID = "task_id"
        case status
        case videoURL = "video_url"
    }
}
