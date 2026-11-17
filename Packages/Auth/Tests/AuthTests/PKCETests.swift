import Testing
@testable import Auth

struct PKCETests {
    @Test func matchesRFC7636Example() {
        // Appendix B of RFC 7636.
        let pkce = PKCE(verifier: "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk")
        #expect(pkce.challenge == "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM")
        #expect(pkce.method == "S256")
    }

    @Test func verifierIsURLSafeAndLongEnough() {
        let verifier = PKCE.generate().verifier
        #expect((43...128).contains(verifier.count))
        #expect(verifier.allSatisfy { $0.isASCII && ($0.isLetter || $0.isNumber || "-._~".contains($0)) })
    }

    @Test func everyVerifierIsDifferent() {
        #expect(PKCE.generate().verifier != PKCE.generate().verifier)
    }
}
