import SwiftUI
import AVFoundation
import Supabase

@Observable
class CreationViewModel {
    var imageData: Data?
    var audioURL: URL?
    var isRecording = false
    var uploadProgressText = ""
    var isGenerating = false
    var generatedArtwork: Artwork?
    var errorMessage: String?

    // Video polling state
    var videoTaskID: String?
    var videoStatus: Artwork.VideoStatus = .pending
    private var pollingTimer: Timer?

    // Realtime subscription
    private var realtimeChannel: RealtimeChannelV2?
    private var realtimeTask: Task<Void, Never>?

    private let creationService: any CreationServiceProtocol
    private let audioTranscriptionService: any AudioTranscriptionServiceProtocol

    init(
        creationService: any CreationServiceProtocol,
        audioTranscriptionService: any AudioTranscriptionServiceProtocol = MockAudioTranscriptionService()
    ) {
        self.creationService = creationService
        self.audioTranscriptionService = audioTranscriptionService
    }

    var hasImage: Bool { imageData != nil }

    func submitCreation(image: Data, audioUrl: URL?) {
        imageData = image
        audioURL = audioUrl
    }

    func executeMagicGeneration() async {
        guard let imageData else { return }
        isGenerating = true
        errorMessage = nil

        do {
            // Step 0: Transcribe audio if available (non-blocking)
            var audioTranscript: String?
            if let audioURL {
                uploadProgressText = "Listening to your description..."
                audioTranscript = try? await audioTranscriptionService.transcribe(audioURL: audioURL)
            }

            // Step 1: Upload image
            uploadProgressText = "Uploading artwork..."
            let uploadResult = try await creationService.uploadImage(imageData: imageData)

            // Step 2: Generate story
            uploadProgressText = "Writing a story..."
            let storyResult = try await creationService.generateStory(
                artworkId: uploadResult.id,
                imageURL: uploadResult.imageURL,
                audioTranscript: audioTranscript
            )

            // Step 3: Submit video generation (async, don't wait)
            uploadProgressText = "Creating animation..."
            let videoResult = try await creationService.generateVideo(
                artworkId: uploadResult.id,
                imageURL: uploadResult.imageURL,
                prompt: storyResult.videoPrompt
            )
            videoTaskID = videoResult.taskID

            // Create artwork from results
            generatedArtwork = Artwork(
                id: uploadResult.id,
                title: storyResult.storyTitle,
                imageURL: uploadResult.imageURL,
                videoURL: nil,
                videoTaskID: videoResult.taskID,
                videoStatus: .processing,
                storyTitle: storyResult.storyTitle,
                storyContent: storyResult.storyContent,
                videoPrompt: storyResult.videoPrompt,
                creativityAnalysis: storyResult.creativityAnalysis,
                moodAnalysis: storyResult.moodAnalysis,
                additionalInsights: storyResult.additionalInsights,
                createdAt: Date()
            )

            uploadProgressText = "Done!"
            isGenerating = false

            // Start monitoring video status (polling + Realtime)
            startVideoPolling()
            if SupabaseConfig.isConfigured {
                await subscribeToVideoStatus(artworkId: uploadResult.id)
            }

        } catch {
            errorMessage = error.localizedDescription
            isGenerating = false
        }
    }

    // MARK: - Realtime Subscription

    func subscribeToVideoStatus(artworkId: String) async {
        guard SupabaseConfig.isConfigured else { return }

        let client = SupabaseClientFactory.shared.client
        let channel = client.realtimeV2.channel("artwork-\(artworkId)")

        let changes = channel.postgresChange(
            UpdateAction.self,
            schema: "public",
            table: "artworks",
            filter: .eq("id", value: artworkId)
        )

        try? await channel.subscribeWithError()
        realtimeChannel = channel

        // Listen for changes in background
        realtimeTask = Task { [weak self] in
            for await change in changes {
                guard let self else { return }
                await MainActor.run {
                    self.handleRealtimeUpdate(change)
                }
            }
        }
    }

    @MainActor
    private func handleRealtimeUpdate(_ change: UpdateAction) {
        // Decode the updated record as an Artwork
        if let artwork = try? change.decodeRecord(as: ArtworkRealtimePayload.self, decoder: JSONDecoder()) {
            if let status = Artwork.VideoStatus(rawValue: artwork.video_status ?? "") {
                videoStatus = status
                generatedArtwork?.videoStatus = status

                if status == .completed {
                    generatedArtwork?.videoURL = artwork.video_url
                    stopVideoPolling()
                    unsubscribeFromRealtime()
                } else if status == .failed {
                    stopVideoPolling()
                    unsubscribeFromRealtime()
                }
            }
        }
    }

    private func unsubscribeFromRealtime() {
        realtimeTask?.cancel()
        realtimeTask = nil
        Task {
            await realtimeChannel?.unsubscribe()
            realtimeChannel = nil
        }
    }

    // MARK: - Polling Fallback

    func startVideoPolling() {
        guard let taskID = videoTaskID else { return }
        pollingTimer?.invalidate()
        pollingTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                await self.checkVideoStatus(taskID: taskID)
            }
        }
    }

    func stopVideoPolling() {
        pollingTimer?.invalidate()
        pollingTimer = nil
    }

    @MainActor
    private func checkVideoStatus(taskID: String) async {
        do {
            let status = try await creationService.checkVideoStatus(taskID: taskID)
            videoStatus = status

            if status == .completed {
                stopVideoPolling()
                if let url = try await creationService.getVideoURL(taskID: taskID) {
                    generatedArtwork?.videoURL = url
                    generatedArtwork?.videoStatus = .completed
                }
            } else if status == .failed {
                stopVideoPolling()
                generatedArtwork?.videoStatus = .failed
            }
        } catch {
            // Continue polling on error
        }
    }

    func reset() {
        imageData = nil
        audioURL = nil
        isRecording = false
        uploadProgressText = ""
        isGenerating = false
        generatedArtwork = nil
        errorMessage = nil
        videoTaskID = nil
        videoStatus = .pending
        stopVideoPolling()
        unsubscribeFromRealtime()
    }
}

// MARK: - Realtime Payload

private struct ArtworkRealtimePayload: Decodable {
    let id: String
    let video_status: String?
    let video_url: String?
}
