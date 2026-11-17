import XCTest

/// Scripted demos for the screen recordings in docs/. Run by scripts/ci/evidence.sh while
/// the Simulator records; skipped in normal CI.
final class DemoRecordingTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    /// Load -> go offline -> pull to refresh -> cached balances with a banner -> back online.
    func testOfflineCache() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()
        app.buttons["signIn.button"].tap()

        let chequing = element(app, "accounts.row.chq-001")
        XCTAssertTrue(chequing.waitForExistence(timeout: 10))
        demoPause(2)

        let offline = element(app, "debug.offlineToggle")
        XCTAssertTrue(offline.waitForExistence(timeout: 5))
        offline.tap()
        demoPause()
        pullToRefresh(from: chequing)
        XCTAssertTrue(element(app, "accounts.offlineBanner").waitForExistence(timeout: 20))
        demoPause(3)

        offline.tap()
        pullToRefresh(from: chequing)
        demoPause(3)
    }

    /// Sign in -> token 0 -> wait for it to expire -> silent refresh shows token 1 -> sign out.
    func testSignInRefreshAndSignOut() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting", "-tokenLifetime", "20"]
        app.launch()
        demoPause()
        app.buttons["signIn.button"].tap()
        XCTAssertTrue(element(app, "accounts.row.chq-001").waitForExistence(timeout: 10))

        openTab(app, "More")
        XCTAssertTrue(app.navigationBars["More"].waitForExistence(timeout: 10))
        let token = element(app, "debug.tokenLabel")
        XCTAssertTrue(scrollTo(app, token))
        demoPause(2)

        sleep(12) // the stub token is refreshed 10 s before its 20 s lifetime ends
        let checkToken = app.buttons["debug.checkToken"]
        scrollTo(app, checkToken)
        checkToken.tap()
        let refreshed = NSPredicate(format: "label CONTAINS 'stub-access-1' OR value CONTAINS 'stub-access-1'")
        expectation(for: refreshed, evaluatedWith: token)
        waitForExpectations(timeout: 10)
        demoPause(2)

        let signOut = app.buttons["more.signOut"]
        scrollTo(app, signOut)
        signOut.tap()
        XCTAssertTrue(app.buttons["signIn.button"].waitForExistence(timeout: 10))
        demoPause(2)
    }
}
