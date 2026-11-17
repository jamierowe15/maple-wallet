#if canImport(UIKit)
import Core
import DesignSystem
import SwiftUI

/// iPad: accounts list and detail side by side. iPhone: collapses to a stack.
public struct AccountsView: View {
    @State private var viewModel: AccountsViewModel
    @Binding private var selection: Account.ID?
    private let makeDetailViewModel: @MainActor (Account.ID) -> AccountDetailViewModel
    private let onRepeatTransfer: @MainActor (Core.Transaction) -> Void
    @State private var columns: NavigationSplitViewVisibility = .all
    #if DEBUG
    @AppStorage("simulateOffline") private var simulateOffline = false
    #endif

    public init(viewModel: AccountsViewModel,
                selection: Binding<Account.ID?>,
                makeDetailViewModel: @escaping @MainActor (Account.ID) -> AccountDetailViewModel,
                onRepeatTransfer: @escaping @MainActor (Core.Transaction) -> Void) {
        _viewModel = State(initialValue: viewModel)
        _selection = selection
        self.makeDetailViewModel = makeDetailViewModel
        self.onRepeatTransfer = onRepeatTransfer
    }

    public var body: some View {
        NavigationSplitView(columnVisibility: $columns) {
            sidebar
                .navigationTitle("Accounts")
                #if DEBUG
                .toolbar {
                    Toggle(isOn: $simulateOffline) { Label("Simulate offline", systemImage: "wifi.slash") }
                        .accessibilityHint("Debug only. Makes the fake server act offline.")
                        .accessibilityIdentifier("debug.offlineToggle")
                }
                #endif
        } detail: {
            if let selection {
                NavigationStack {
                    AccountDetailView(viewModel: makeDetailViewModel(selection), onRepeatTransfer: onRepeatTransfer)
                }
                .id(selection)
            } else {
                EmptyStateView(title: "Choose an account", message: "Pick an account to see its activity.",
                               systemImage: "sidebar.left")
            }
        }
        .navigationSplitViewStyle(.balanced) // iPad portrait too: list and detail side by side
        .task { await viewModel.load() }
    }

    @ViewBuilder private var sidebar: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading accounts")
        case .empty:
            EmptyStateView(title: "No accounts yet", message: "Accounts you open will show up here.",
                           systemImage: "creditcard")
        case .failed(let error):
            EmptyStateView(title: error.title, message: error.message, systemImage: "exclamationmark.triangle",
                           actionTitle: error.canRetry ? "Try again" : nil) {
                Task { await viewModel.load() }
            }
        case .loaded(let accounts):
            List(selection: $selection) {
                if let lastUpdated = viewModel.lastUpdated {
                    Label("Offline. Showing balances from \(lastUpdated.formatted(date: .omitted, time: .shortened)).",
                          systemImage: "wifi.slash")
                        .font(.footnote)
                        .foregroundStyle(Palette.textSecondary)
                        .listRowSeparator(.hidden)
                        .accessibilityIdentifier("accounts.offlineBanner")
                }
                ForEach(accounts) { account in
                    BalanceCard(title: account.name,
                                subtitle: "\(account.kind.rawValue.capitalized), ending in \(account.lastFour)",
                                balance: account.balance.formatted(),
                                spokenBalance: account.balance.spokenDescription())
                        .tag(account.id)
                        .listRowSeparator(.hidden)
                        .accessibilityAddTraits(.isButton)
                        .accessibilityIdentifier("accounts.row.\(account.id)")
                }
            }
            .listStyle(.plain)
            .refreshable { await viewModel.load() }
        }
    }
}
#endif
