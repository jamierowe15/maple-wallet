import Auth
import DesignSystem
import SwiftUI
import UserNotifications

struct MoreView: View {
    let session: SessionModel
    let tokenProvider: TokenProvider
    @Bindable var appLock: AppLock
    @State private var showHelp = false
    @State private var notificationsStatus = "Not asked yet"
    #if DEBUG
    @State private var currentToken = ""
    #endif

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button("Help centre") { showHelp = true }
                } header: { SectionHeader("Help") }
                Section {
                    NavigationLink("Statements") { StatementsScreen(tokenProvider: tokenProvider) }
                    NavigationLink("Top up with Apple Pay") { TopUpView() }
                    NavigationLink("Deposit a cheque") { DepositChequeView() }
                } header: { SectionHeader("Banking") }
                Section {
                    Toggle("Require Face ID to open", isOn: $appLock.isEnabled)
                        .accessibilityIdentifier("more.faceIDToggle")
                } header: { SectionHeader("Security") }
                Section {
                    Button("Turn on transfer alerts") {
                        Task {
                            let granted = (try? await UNUserNotificationCenter.current()
                                .requestAuthorization(options: [.alert, .sound, .badge])) ?? false
                            notificationsStatus = granted ? "On" : "Off. You can change this in Settings."
                        }
                    }
                    LabeledContent("Status") {
                        Text(notificationsStatus).foregroundStyle(Palette.textSecondary)
                    }
                } header: { SectionHeader("Notifications") }
                #if DEBUG
                Section {
                    LabeledContent("Access token") {
                        Text(currentToken).foregroundStyle(Palette.textSecondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityIdentifier("debug.tokenLabel")
                    Button("Check token") { Task { await refreshTokenLabel() } }
                        .accessibilityIdentifier("debug.checkToken")
                } header: { SectionHeader("Debug") }
                #endif
                Section {
                    Button("Sign out", role: .destructive) { Task { await session.signOut() } }
                        .accessibilityIdentifier("more.signOut")
                }
            }
            .navigationTitle("More")
            #if DEBUG
            .task { await refreshTokenLabel() }
            #endif
            .sheet(isPresented: $showHelp) {
                SafariView(url: URL(string: "https://support.apple.com/accessibility")!)
                    .ignoresSafeArea()
            }
        }
    }

    #if DEBUG
    /// Shows which token the app is using, so a silent refresh is visible in demos.
    private func refreshTokenLabel() async {
        currentToken = (try? await tokenProvider.validToken()) ?? "signed out"
    }
    #endif
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
