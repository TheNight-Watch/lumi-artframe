import SwiftUI

enum AppRoute: Hashable {
    case splash
    case login
    case main
}

enum CreationRoute: Hashable {
    case camera
    case description
    case generation
    case detail
}

@Observable
class AppRouter {
    var currentRoute: AppRoute = .splash
    var creationPath = NavigationPath()
    var showCreationFlow = false
    var selectedDetailArtwork: Artwork?
    var showDetailFromGallery = false

    func navigate(to route: AppRoute) {
        currentRoute = route
    }

    func startCreation() {
        creationPath = NavigationPath()
        showCreationFlow = true
    }

    func dismissCreation() {
        showCreationFlow = false
        creationPath = NavigationPath()
    }

    func showDetail(artwork: Artwork) {
        selectedDetailArtwork = artwork
        showDetailFromGallery = true
    }

    func dismissDetail() {
        showDetailFromGallery = false
        selectedDetailArtwork = nil
    }
}
