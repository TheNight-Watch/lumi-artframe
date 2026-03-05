import Foundation

enum AppConfiguration {
    static func resolveServiceContainer() -> ServiceContainer {
        // Use mock services if Supabase is not configured or if running UI tests
        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            return .mockAuthenticated
        }

        if ProcessInfo.processInfo.arguments.contains("-UseMocks") {
            return .mock
        }

        guard SupabaseConfig.isConfigured else {
            print("[AppConfiguration] Supabase not configured, falling back to mock services")
            return .mock
        }

        return .live
    }
}
