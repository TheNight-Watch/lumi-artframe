import Foundation

final class MockAudioTranscriptionService: AudioTranscriptionServiceProtocol, @unchecked Sendable {
    func transcribe(audioURL: URL) async throws -> String {
        try await Task.sleep(for: .seconds(0.5))
        return "This is a drawing of a beautiful rainbow with flowers and a happy sun in the sky"
    }
}
