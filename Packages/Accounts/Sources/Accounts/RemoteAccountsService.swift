import Core
import Networking

public struct RemoteAccountsService: AccountsService {
    private let client: APIClient

    public init(client: APIClient) {
        self.client = client
    }

    public func fetchAccounts() async throws -> [Account] {
        try await client.send(Endpoint<[Account]>(path: "/accounts"))
    }

    public func fetchAccount(id: Account.ID) async throws -> Account {
        try await client.send(Endpoint<Account>(path: "/accounts/\(id)"))
    }

    public func fetchTransactions(for id: Account.ID) async throws -> [Transaction] {
        try await client.send(Endpoint<[Transaction]>(path: "/accounts/\(id)/transactions"))
    }
}
