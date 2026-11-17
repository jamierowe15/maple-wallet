#if canImport(UIKit)
import Core
import DesignSystem
import SwiftUI

struct AccountRoute: Hashable {
    let id: Account.ID
}

public struct AccountsView: View {
    @State private var viewModel: AccountsViewModel
    private let makeDetailViewModel: @MainActor (Account.ID) -> AccountDetailViewModel
    #if DEBUG
    @AppStorage("simulateOffline") private var simulateOffline = false
    #endif

    public init(viewModel: AccountsViewModel,
                makeDetailViewModel: @escaping @MainActor (Account.ID) -> AccountDetailViewModel) {
        _viewModel = State(initialValue: viewModel)
        self.makeDetailViewModel = makeDetailViewModel
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Accounts")
                .navigationDestination(for: AccountRoute.self) { route in
                    AccountDetailView(viewModel: makeDetailViewModel(route.id))
                }
                #if DEBUG
                .toolbar {
                    Toggle(isOn: $simulateOffline) { Label("Simulate offline", systemImage: "wifi.slash") }
                        .accessibilityHint("Debug only. Makes the fake server act offline.")
                }
                #endif
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
            List {
                if let lastUpdated = viewModel.lastUpdated {
                    Label("Offline. Showing balances from \(lastUpdated.formatted(date: .omitted, time: .shortened)).",
                          systemImage: "wifi.slash")
                        .font(.footnote)
                        .foregroundStyle(Palette.textSecondary)
                        .listRowSeparator(.hidden)
                }
                ForEach(accounts) { account in
                    NavigationLink(value: AccountRoute(id: account.id)) {
                        BalanceCard(title: account.name,
                                    subtitle: "\(account.kind.rawValue.capitalized), ending in \(account.lastFour)",
                                    balance: account.balance.formatted())
                    }
                    .listRowSeparator(.hidden)
                    .accessibilityIdentifier("accounts.row.\(account.id)")
                }
            }
            .listStyle(.plain)
            .refreshable { await viewModel.load() }
        }
    }
}
#endif
