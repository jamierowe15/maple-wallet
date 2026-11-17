import Auth
import DesignSystem
import SwiftUI

struct MoreView: View {
    let session: SessionModel
    let tokenProvider: TokenProvider
    @State private var showHelp = false

    var body: some View {
        NavigationStack {
            List {
                Section("Help") {
                    Button("Help centre") { showHelp = true }
                }
                Section("Banking") {
                    NavigationLink("Statements") { StatementsScreen(tokenProvider: tokenProvider) }
                    NavigationLink("Top up with Apple Pay") { TopUpView() }
                    NavigationLink("Deposit a cheque") { DepositChequeView() }
                }
                Section {
                    Button("Sign out", role: .destructive) { Task { await session.signOut() } }
                        .accessibilityIdentifier("more.signOut")
                }
            }
            .navigationTitle("More")
            .sheet(isPresented: $showHelp) {
                SafariView(url: URL(string: "https://support.apple.com/accessibility")!)
                    .ignoresSafeArea()
            }
        }
    }
}

struct StatementsScreen: View {
    let tokenProvider: TokenProvider
    @State private var token: String?

    var body: some View {
        Group {
            if let token {
                // example.com is allowlisted; its "More information" link (iana.org) is blocked.
                StatementsWebView(url: URL(string: "https://example.com/")!, bearerToken: token,
                                  allowlist: NavigationAllowlist(hosts: ["example.com"]))
            } else {
                ProgressView("Loading statements")
            }
        }
        .navigationTitle("Statements")
        .navigationBarTitleDisplayMode(.inline)
        .task { token = try? await tokenProvider.validToken() }
    }
}
