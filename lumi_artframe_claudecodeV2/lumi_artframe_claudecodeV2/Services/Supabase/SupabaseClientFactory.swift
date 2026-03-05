import Foundation
import Supabase

final class SupabaseClientFactory: @unchecked Sendable {
    static let shared = SupabaseClientFactory()

    lazy var client: SupabaseClient = {
        guard SupabaseConfig.isConfigured else {
            fatalError("SupabaseClientFactory accessed before Supabase is configured. Check Secrets.xcconfig.")
        }
        return SupabaseClient(
            supabaseURL: URL(string: SupabaseConfig.url)!,
            supabaseKey: SupabaseConfig.anonKey
        )
    }()

    private init() {}
}
