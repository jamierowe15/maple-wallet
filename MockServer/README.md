# Mock server

The fake API lives in `Packages/Accounts/Sources/Accounts/Fixtures/` and is served by
`LocalFixtureTransport`, so the Simulator, tests and Windows builds never touch the internet.
`Packages/Networking/Sources/Networking/StubURLProtocol.swift` does the same at the URLSession level.

| Method | Path | Fixture |
|--------|------|---------|
| GET | /accounts | accounts.json |
| GET | /accounts/{id} | accounts.json (filtered) |
| GET | /accounts/{id}/transactions | transactions.json (filtered, newest first) |
| POST | /transfers | generated `{ "confirmation": "MW-123456" }` |

Debug builds have a "Simulate offline" toggle on the Accounts screen.
