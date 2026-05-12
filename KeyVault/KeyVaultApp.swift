import SwiftUI

@main
struct KeyVaultApp: App {
    @State private var store = ProfileStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .frame(minWidth: 600, minHeight: 400)
        }
    }
}
