#if canImport(Darwin)
import Foundation

/// Intercepts URLSession traffic so the Simulator and integration tests never touch the internet.
/// Register with: `config.protocolClasses = [StubURLProtocol.self]`.
public final class StubURLProtocol: URLProtocol {
    /// path -> (status, body). Set before the request runs; read on URLSession's queue.
    nonisolated(unsafe) public static var routes: [String: (Int, Data)] = [:]

    override public class func canInit(with request: URLRequest) -> Bool { true }
    override public class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override public func startLoading() {
        let path = request.url?.path ?? ""
        let (status, body) = Self.routes[path] ?? (404, Data())
        let response = HTTPURLResponse(url: request.url!, statusCode: status, httpVersion: "HTTP/1.1",
                                       headerFields: ["Content-Type": "application/json"])!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: body)
        client?.urlProtocolDidFinishLoading(self)
    }

    override public func stopLoading() {}
}
#endif
