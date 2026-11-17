import Foundation

/// Hosts a web view may visit. Everything else is blocked.
public struct NavigationAllowlist: Sendable, Equatable {
    public let hosts: Set<String>

    public init(hosts: Set<String>) {
        self.hosts = Set(hosts.map { $0.lowercased() })
    }

    public func allows(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == "https",
              let host = components.host?.lowercased() else { return false }
        return hosts.contains(host)
    }
}

#if canImport(WebKit) && canImport(UIKit)
import SafariServices
import SwiftUI
import WebKit

/// Read-only external content (help pages). Safari's own UI shows the real URL to the user.
public struct SafariView: UIViewControllerRepresentable {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    public func updateUIViewController(_ controller: SFSafariViewController, context: Context) {}
}

/// In-app statements page: sends the bearer token as a header (never in the URL),
/// stays on allowlisted hosts and has JavaScript off.
public struct StatementsWebView: UIViewRepresentable {
    private let url: URL
    private let bearerToken: String
    private let allowlist: NavigationAllowlist

    public init(url: URL, bearerToken: String, allowlist: NavigationAllowlist) {
        self.url = url
        self.bearerToken = bearerToken
        self.allowlist = allowlist
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(allowlist: allowlist)
    }

    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = .nonPersistent()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        var request = URLRequest(url: url)
        request.setValue("Bearer \(bearerToken)", forHTTPHeaderField: "Authorization")
        webView.load(request)
        return webView
    }

    public func updateUIView(_ webView: WKWebView, context: Context) {}

    public final class Coordinator: NSObject, WKNavigationDelegate {
        private let allowlist: NavigationAllowlist

        init(allowlist: NavigationAllowlist) {
            self.allowlist = allowlist
        }

        public func webView(_ webView: WKWebView,
                            decidePolicyFor navigationAction: WKNavigationAction) async -> WKNavigationActionPolicy {
            guard let url = navigationAction.request.url, allowlist.allows(url) else { return .cancel }
            return .allow
        }
    }
}

public enum WebDataCleaner {
    /// Called on sign-out: wipes cookies, local storage and caches from every web view.
    @MainActor
    public static func clearAll() async {
        await WKWebsiteDataStore.default().removeData(
            ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(),
            modifiedSince: .distantPast
        )
    }
}
#endif
