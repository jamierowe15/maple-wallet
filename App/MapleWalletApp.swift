import SwiftUI

@main
struct MapleWalletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    private let root = CompositionRoot.make()

    var body: some Scene {
        WindowGroup {
            RootView(root: root)
        }
    }
}
