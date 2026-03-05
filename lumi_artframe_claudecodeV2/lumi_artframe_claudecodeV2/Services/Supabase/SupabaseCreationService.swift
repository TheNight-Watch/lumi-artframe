import Foundation
import Supabase

final class SupabaseCreationService: CreationServiceProtocol, @unchecked Sendable {
    private let client: SupabaseClient

    init(client: SupabaseClient) {
        self.client = client
    }

    func uploadImage(imageData: Data) async throws -> UploadResult {
        // Get current user
        let user = try await client.auth.session.user

        // Upload to Supabase Storage directly (bypasses upload-image Edge Function)
        let fileName = "\(user.id.uuidString)/\(Int(Date().timeIntervalSince1970))_artwork.jpg"
        try await client.storage
            .from("artworks")
            .upload(fileName, data: imageData, options: .init(contentType: "image/jpeg"))

        // Get public URL
        let publicURL = try client.storage
            .from("artworks")
            .getPublicURL(path: fileName)

        // Create artwork record in database
        struct InsertPayload: Encodable {
            let user_id: String
            let image_url: String
        }
        let payload = InsertPayload(user_id: user.id.uuidString, image_url: publicURL.absoluteString)

        struct ArtworkRow: Decodable {
            let id: String
            let image_url: String
        }
        let row: ArtworkRow = try await client
            .from("artworks")
            .insert(payload)
            .select("id, image_url")
            .single()
            .execute()
            .value

        return UploadResult(id: row.id, imageURL: row.image_url)
    }

    func generateStory(artworkId: String, imageURL: String, audioTranscript: String?) async throws -> StoryResult {
        struct RequestBody: Encodable {
            let artwork_id: String
            let image_url: String
            let audio_transcript: String?
        }
        let body = RequestBody(artwork_id: artworkId, image_url: imageURL, audio_transcript: audioTranscript)
        return try await client.functions.invoke(
            "generate-story",
            options: .init(body: body)
        )
    }

    func generateVideo(artworkId: String, imageURL: String, prompt: String) async throws -> VideoSubmitResult {
        struct RequestBody: Encodable {
            let artwork_id: String
            let image_url: String
            let prompt: String
        }
        let body = RequestBody(artwork_id: artworkId, image_url: imageURL, prompt: prompt)
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
