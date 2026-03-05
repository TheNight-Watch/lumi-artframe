import Foundation

enum SupabaseConfig {
    static var url: String {
        guard let value = Bundle.main.infoDictionary?["SupabaseURL"] as? String,
              !value.isEmpty,
              !value.contains("YOUR_PROJECT_REF") else {
            return ""
        }
        return value
    }

    static var anonKey: String {
        guard let value = Bundle.main.infoDictionary?["SupabaseAnonKey"] as? String,
              !value.isEmpty,
              value != "YOUR_ANON_KEY" else {
            return ""
        }
        return value
    }

    static var isConfigured: Bool {
        !url.isEmpty && !anonKey.isEmpty
    }
}
