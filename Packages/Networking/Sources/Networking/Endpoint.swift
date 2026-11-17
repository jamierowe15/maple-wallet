import Foundation

/// A typed description of one API call. `Response` is what the body decodes to.
public struct Endpoint<Response: Decodable & Sendable>: Sendable {
    public var method: String
    public var path: String
    public var body: Data?

    public init(method: String = "GET", path: String, body: Data? = nil) {
        self.method = method
        self.path = path
        self.body = body
    }
}
