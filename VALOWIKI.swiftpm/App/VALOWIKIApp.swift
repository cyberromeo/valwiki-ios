import SwiftUI

@main
struct VALOWIKIApp: App {
    @State private var store = LibraryStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .preferredColorScheme(.dark)
                .tint(.valRed)
        }
    }
}
