import SwiftUI

@main
struct DeepSeekBarApp: App {
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "api_key") ?? ""
    @State private var hasAPIKey: Bool

    init() {
        let key = UserDefaults.standard.string(forKey: "api_key") ?? ""
        _hasAPIKey = State(initialValue: !key.isEmpty)
        if !key.isEmpty {
            DeepSeekAPIService.shared.setAPIKey(key)
        }
    }

    var body: some Scene {
        MenuBarExtra {
            if hasAPIKey {
                ContentView(apiKey: $apiKey, hasAPIKey: $hasAPIKey)
            } else {
                APIKeySetupView(apiKey: $apiKey, hasAPIKey: $hasAPIKey, isEditing: .constant(false))
            }
        } label: {
            Image("MenuIcon")
                .renderingMode(.template)
        }
        .menuBarExtraStyle(.window)
    }
}
