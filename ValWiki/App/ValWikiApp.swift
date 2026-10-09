import SwiftUI

@main
struct ValWikiApp: App {
    @State private var store = Store()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(VW.red)
        }
    }
}
