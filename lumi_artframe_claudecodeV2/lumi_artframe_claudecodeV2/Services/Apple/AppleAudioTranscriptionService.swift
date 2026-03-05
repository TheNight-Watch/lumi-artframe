import Foundation
import Speech

final class AppleAudioTranscriptionService: AudioTranscriptionServiceProtocol, @unchecked Sendable {
    func transcribe(audioURL: URL) async throws -> String {
        let authorized = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }

        guard authorized else {
            throw AudioTranscriptionError.speechRecognizerUnavailable
        }

        guard let recognizer = SFSpeechRecognizer(), recognizer.isAvailable else {
            throw AudioTranscriptionError.speechRecognizerUnavailable
        }

        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        request.shouldReportPartialResults = false

        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<SFSpeechRecognitionResult, Error>) in
            recognizer.recognitionTask(with: request) { result, error in
                if let error {
                    continuation.resume(throwing: AudioTranscriptionError.recognitionFailed(error.localizedDescription))
                    return
                }
                guard let result, result.isFinal else { return }
                continuation.resume(returning: result)
            }
        }

        let transcript = result.bestTranscription.formattedString
        guard !transcript.isEmpty else {
            throw AudioTranscriptionError.noTranscription
        }

        return transcript
    }
}
