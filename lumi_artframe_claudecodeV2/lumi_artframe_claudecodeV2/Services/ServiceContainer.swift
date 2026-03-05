import SwiftUI

@Observable
class ServiceContainer {
    let auth: any AuthServiceProtocol
    let gallery: any GalleryServiceProtocol
    let creation: any CreationServiceProtocol
    let audioTranscription: any AudioTranscriptionServiceProtocol

    init(
        auth: any AuthServiceProtocol,
        gallery: any GalleryServiceProtocol,
        creation: any CreationServiceProtocol,
        audioTranscription: any AudioTranscriptionServiceProtocol = MockAudioTranscriptionService()
    ) {
        self.auth = auth
        self.gallery = gallery
        self.creation = creation
        self.audioTranscription = audioTranscription
    }

    static let mock = ServiceContainer(
        auth: MockAuthService(),
        gallery: MockGalleryService(),
        creation: MockCreationService()
    )

    static let mockAuthenticated = ServiceContainer(
        auth: MockAuthService(preAuthenticated: true),
        gallery: MockGalleryService(),
        creation: MockCreationService()
    )

    static var live: ServiceContainer {
        let client = SupabaseClientFactory.shared.client
        return ServiceContainer(
            auth: SupabaseAuthService(client: client),
            gallery: SupabaseGalleryService(client: client),
            creation: SupabaseCreationService(client: client),
            audioTranscription: AppleAudioTranscriptionService()
        )
    }
}

struct ServiceContainerKey: EnvironmentKey {
    static let defaultValue: ServiceContainer = .mock
}

extension EnvironmentValues {
    var services: ServiceContainer {
        get { self[ServiceContainerKey.self] }
        set { self[ServiceContainerKey.self] = newValue }
    }
}
