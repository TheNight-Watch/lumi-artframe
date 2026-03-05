import Foundation

protocol AudioTranscriptionServiceProtocol: Sendable {
    func transcribe(audioURL: URL) async throws -> String
}

enum AudioTranscriptionError: LocalizedError {
    case speechRecognizerUnavailable
    case recognitionFailed(String)
    case noTranscription

    var errorDescription: String? {
        switch self {
        case .speechRecognizerUnavailable:
            return "Speech recognition is not available on this device"
        case .recognitionFailed(let reason):
            return "Speech recognition failed: \(reason)"
        case .noTranscription:
            return "No speech was detected in the audio"
        }
    }
}
