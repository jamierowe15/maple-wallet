import Accounts
import Core
import DesignSystem
import SwiftUI
import Transfers

struct TransferSeed: Equatable {
    var id = UUID()
    var amount: Money?
}

struct RootView: View {
    enum AppTab: Hashable { case accounts, transfer, more }

    private let root: CompositionRoot
    @State private var session: SessionModel
    @State private var tab: AppTab = .accounts
    @State private var selectedAccount: Account.ID?
    @State private var transferSeed = TransferSeed()
    @State private var pendingRoute: Route?
    @State private var inbox = DeepLinkInbox.shared
    @State private var appLock = AppLock()
    @Environment(\.scenePhase) private var scenePhase

    init(root: CompositionRoot) {
        self.root = root
        _session = State(initialValue: root.makeSessionModel())
    }

    var body: some View {
        content
            .tint(Palette.brand) // system blue is below 4.5:1 contrast on white; the brand red passes
            .privacyShield(isActive: scenePhase != .active && session.phase == .signedIn)
            .overlay {
                if appLock.isLocked && session.phase == .signedIn { LockView(appLock: appLock) }
            }
            .task { await session.restore() }
            .onChange(of: scenePhase) { _, phase in
                if phase == .background { appLock.lockIfEnabled() }
            }
            .onOpenURL { open($0) }
            .onChange(of: inbox.pendingURL) { _, url in
                guard let url else { return }
                open(url)
                inbox.pendingURL = nil
            }
            .onChange(of: session.phase) { _, phase in
                if phase == .signedIn, let route = pendingRoute { apply(route) }
            }
    }

    @ViewBuilder private var content: some View {
        switch session.phase {
        case .checking:
            ProgressView()
        case .signedOut, .signingIn:
            SignInView(session: session)
        case .signedIn:
            TabView(selection: $tab) {
                AccountsView(viewModel: root.makeAccountsViewModel(),
                             selection: $selectedAccount,
                             makeDetailViewModel: root.makeAccountDetailViewModel,
                             onRepeatTransfer: { transaction in
                                 transferSeed = TransferSeed(amount: transaction.amount.magnitude)
                                 tab = .transfer
                             })
                    .tabItem { Label("Accounts", systemImage: "list.bullet.rectangle") }
                    .tag(AppTab.accounts)
                TransferScreen(root: root, seed: transferSeed)
                    .id(transferSeed.id)
                    .tabItem { Label("Transfer", systemImage: "arrow.left.arrow.right") }
                    .tag(AppTab.transfer)
                MoreView(session: session, tokenProvider: root.tokenProvider, appLock: appLock)
                    .tabItem { Label("More", systemImage: "ellipsis.circle") }
                    .tag(AppTab.more)
            }
        }
    }

    private func open(_ url: URL) {
        guard let route = root.router.route(for: url) else { return }
        if session.phase == .signedIn { apply(route) } else { pendingRoute = route }
    }

    private func apply(_ route: Route) {
        pendingRoute = nil
        switch route {
        case .accounts:
            tab = .accounts
            selectedAccount = nil
        case .account(let id), .transaction(let id, _):
            tab = .accounts
            selectedAccount = id
        case .transfer:
            tab = .transfer
        }
    }
}

struct TransferScreen: View {
    let root: CompositionRoot
    let seed: TransferSeed
    @State private var accounts: [Account]?

    var body: some View {
        Group {
            if let accounts {
                TransferView(viewModel: root.makeTransferViewModel(accounts: accounts, prefill: seed.amount))
            } else {
                ProgressView("Loading accounts")
            }
        }
        .task { accounts = (try? await root.accountsService.fetchAccounts()) ?? [] }
    }
}
