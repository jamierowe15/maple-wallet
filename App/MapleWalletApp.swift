import Accounts
import SwiftUI

@main
struct MapleWalletApp: App {
    private let root = CompositionRoot.make()

    var body: some Scene {
        WindowGroup {
            AccountsView(viewModel: root.makeAccountsViewModel())
        }
    }
}
