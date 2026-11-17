#if canImport(UIKit)
import Core
import DesignSystem
import SwiftUI

public struct AccountsView: View {
    @State private var viewModel: AccountsViewModel

    public init(viewModel: AccountsViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Accounts")
        }
        .task { await viewModel.load() }
    }

    @ViewBuilder private var content: some View {
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
            List(accounts) { account in
                BalanceCard(title: account.name,
                            subtitle: "\(account.kind.rawValue.capitalized), ending in \(account.lastFour)",
                            balance: account.balance.formatted())
                    .listRowSeparator(.hidden)
                    .accessibilityIdentifier("accounts.row.\(account.id)")
            }
            .listStyle(.plain)
        }
    }
}

#if DEBUG
#Preview { AccountsView(viewModel: AccountsViewModel(service: MockAccountsService())) }
#endif
#endif
