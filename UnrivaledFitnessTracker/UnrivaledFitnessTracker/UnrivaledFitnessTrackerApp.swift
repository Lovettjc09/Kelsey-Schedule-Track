import SwiftUI

@main
struct UnrivaledFitnessTrackerApp: App {
    @StateObject private var store = TaskStore.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
