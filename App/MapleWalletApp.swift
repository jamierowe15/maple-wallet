import SwiftUI

@main
struct MapleWalletApp: App {
    private let root = CompositionRoot.make()

    var body: some Scene {
        WindowGroup {
            RootView(root: root)
        }
    }
}
