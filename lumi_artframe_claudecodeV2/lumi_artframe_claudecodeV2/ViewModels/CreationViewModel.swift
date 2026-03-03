import SwiftUI
import AVFoundation

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

    private let creationService: any CreationServiceProtocol

    init(creationService: any CreationServiceProtocol) {
        self.creationService = creationService
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
            // Step 1: Upload image
            uploadProgressText = "Uploading artwork..."
            let uploadResult = try await creationService.uploadImage(imageData: imageData)

            // Step 2: Generate story
            uploadProgressText = "Writing a story..."
            let storyResult = try await creationService.generateStory(
                imageURL: uploadResult.imageURL,
                audioTranscript: nil // TODO: transcribe audio if available
            )

            // Step 3: Submit video generation (async, don't wait)
            uploadProgressText = "Creating animation..."
            let videoResult = try await creationService.generateVideo(
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

            // Start polling for video status
            startVideoPolling()

        } catch {
            errorMessage = error.localizedDescription
            isGenerating = false
        }
    }

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
    }
}
