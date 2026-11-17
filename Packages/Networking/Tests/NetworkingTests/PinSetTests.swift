import Foundation
import Testing
@testable import Networking

struct PinSetTests {
    private let goodKey = Data("server-public-key".utf8)

    @Test func trustsPinnedKey() {
        let pins = PinSet(hashes: [PinSet.hash(ofPublicKey: goodKey)])
        #expect(pins.trusts(publicKey: goodKey))
    }

    @Test func rejectsUnknownKey() {
        let pins = PinSet(hashes: [PinSet.hash(ofPublicKey: goodKey)])
        #expect(!pins.trusts(publicKey: Data("attacker-key".utf8)))
    }

    @Test func emptyPinSetRejectsEverything() {
        #expect(!PinSet(hashes: []).trusts(publicKey: goodKey))
    }
}
