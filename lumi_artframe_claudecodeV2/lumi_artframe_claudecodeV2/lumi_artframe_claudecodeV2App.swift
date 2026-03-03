import SwiftUI

@main
struct lumi_artframe_claudecodeV2App: App {
    @State private var router = AppRouter()
    @State private var services = ServiceContainer.mock

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(router)
                .environment(\.services, services)
        }
    }
}

struct RootView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        switch router.currentRoute {
        case .splash:
            SplashView()
        case .login:
            LoginView()
        case .main:
            MainTabView()
        }
    }
}
