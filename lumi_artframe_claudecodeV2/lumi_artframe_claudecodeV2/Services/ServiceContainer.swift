import SwiftUI

@Observable
class ServiceContainer {
    let auth: any AuthServiceProtocol
    let gallery: any GalleryServiceProtocol
    let creation: any CreationServiceProtocol

    init(
        auth: any AuthServiceProtocol,
        gallery: any GalleryServiceProtocol,
        creation: any CreationServiceProtocol
    ) {
        self.auth = auth
        self.gallery = gallery
        self.creation = creation
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
