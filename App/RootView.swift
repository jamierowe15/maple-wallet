import Accounts
import DesignSystem
import SwiftUI

struct RootView: View {
    private let root: CompositionRoot
    @State private var session: SessionModel
    @Environment(\.scenePhase) private var scenePhase

    init(root: CompositionRoot) {
        self.root = root
        _session = State(initialValue: root.makeSessionModel())
    }

    var body: some View {
        content
            .privacyShield(isActive: scenePhase != .active && session.phase == .signedIn)
            .task { await session.restore() }
    }

    @ViewBuilder private var content: some View {
        switch session.phase {
        case .checking:
            ProgressView()
        case .signedOut, .signingIn:
            SignInView(session: session)
        case .signedIn:
            TabView {
                AccountsView(viewModel: root.makeAccountsViewModel(),
                             makeDetailViewModel: root.makeAccountDetailViewModel)
                    .tabItem { Label("Accounts", systemImage: "list.bullet.rectangle") }
                MoreView(session: session, tokenProvider: root.tokenProvider)
                    .tabItem { Label("More", systemImage: "ellipsis.circle") }
            }
        }
    }
}
