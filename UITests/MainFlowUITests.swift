import XCTest

/// Sign in -> open an account -> send a transfer. Finds elements by accessibility
/// identifier, never by on-screen text, so copy changes don't break the test.
final class MainFlowUITests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testSignInOpenAccountAndSendTransfer() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        let signIn = app.buttons["signIn.button"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 10))
        demoPause()
        signIn.tap()

        let chequing = element(app, "accounts.row.chq-001")
        XCTAssertTrue(chequing.waitForExistence(timeout: 10))
        demoPause()
        chequing.tap()
        XCTAssertTrue(element(app, "account.detail.balance").waitForExistence(timeout: 10))
        demoPause(2)

        openTab(app, "Transfer")
        let amount = app.textFields["transfer.amount"]
        XCTAssertTrue(amount.waitForExistence(timeout: 10))
        amount.tap()
        amount.typeText("25")
        demoPause()

        app.buttons["transfer.review"].tap()
        let confirm = app.buttons["transfer.confirm"]
        XCTAssertTrue(confirm.waitForExistence(timeout: 5))
        demoPause()
        confirm.tap()

        XCTAssertTrue(element(app, "transfer.done").waitForExistence(timeout: 10))
        demoPause(2)
    }

    func testSignOutReturnsToSignIn() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        app.buttons["signIn.button"].tap()
        XCTAssertTrue(element(app, "accounts.row.chq-001").waitForExistence(timeout: 10))
        openTab(app, "More")
        XCTAssertTrue(app.navigationBars["More"].waitForExistence(timeout: 10))
        let signOut = app.buttons["more.signOut"]
        XCTAssertTrue(scrollTo(app, signOut), "Sign out button not found on the More screen")
        signOut.tap()
        XCTAssertTrue(app.buttons["signIn.button"].waitForExistence(timeout: 10))
    }
}
