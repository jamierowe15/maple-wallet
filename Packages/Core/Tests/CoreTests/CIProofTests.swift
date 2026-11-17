import Testing

/// Deliberately broken. This branch exists only to prove CI blocks a failing test; it is never merged.
@Test func ciMustRejectThisBrokenTest() {
    #expect(1 + 1 == 3)
}
