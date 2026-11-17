import Foundation

public enum Route: Equatable, Hashable, Sendable {
    case accounts
    case account(id: String)
    case transaction(accountID: String, id: String)
    case transfer
}

/// Turns maplewallet:// links, universal links and notification payloads into one Route type.
public struct DeepLinkRouter: Sendable {
    public let customScheme: String
    public let universalLinkHosts: Set<String>

    public init(customScheme: String = "maplewallet", universalLinkHosts: Set<String> = ["maplewallet.example"]) {
        self.customScheme = customScheme
        self.universalLinkHosts = universalLinkHosts
    }

    public func route(for url: URL) -> Route? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = components.scheme?.lowercased() else { return nil }
        let pathParts = components.path.split(separator: "/").map(String.init)

        let parts: [String]
        if scheme == customScheme {
            // maplewallet://accounts/chq-001 -> host "accounts", path "/chq-001"
            parts = [components.host].compactMap { $0 } + pathParts
        } else if scheme == "https", let host = components.host?.lowercased(), universalLinkHosts.contains(host) {
            parts = pathParts
        } else {
            return nil
        }

        switch parts.count {
        case 1 where parts[0] == "accounts": return .accounts
        case 1 where parts[0] == "transfer": return .transfer
        case 2 where parts[0] == "accounts": return .account(id: parts[1])
        case 4 where parts[0] == "accounts" && parts[2] == "transactions":
            return .transaction(accountID: parts[1], id: parts[3])
        default: return nil
        }
    }
}
