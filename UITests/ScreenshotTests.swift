import XCTest

/// Captures every main screen. scripts/ci/evidence.sh runs it in light, dark, AX5 text
/// and on iPad (TEST_RUNNER_SHOTS_TAG names each set). Skipped in normal CI.
final class ScreenshotTests: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func testCaptureMainScreens() {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        let signIn = app.buttons["signIn.button"]
        XCTAssertTrue(signIn.waitForExistence(timeout: 10))
        capture("01-sign-in")
        signIn.tap()

        let chequing = element(app, "accounts.row.chq-001")
        XCTAssertTrue(chequing.waitForExistence(timeout: 10))
        capture("02-accounts")
        chequing.tap()
        XCTAssertTrue(element(app, "account.detail.balance").waitForExistence(timeout: 10))
        sleep(1)
        capture("03-account-detail")

        openTab(app, "Transfer")
        XCTAssertTrue(app.textFields["transfer.amount"].waitForExistence(timeout: 10))
        capture("04-transfer")

        openTab(app, "More")
        sleep(1)
        capture("05-more")
    }

    private func capture(_ name: String) {
        let tag = ProcessInfo.processInfo.environment["SHOTS_TAG"] ?? "shot"
        let screenshot = XCUIScreen.main.screenshot()
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = "\(tag)-\(name)"
        attachment.lifetime = .keepAlways
        add(attachment)
        if let folder = evidenceFolder() {
            try? screenshot.pngRepresentation.write(to: folder.appendingPathComponent("\(tag)-\(name).png"))
        }
    }
}
