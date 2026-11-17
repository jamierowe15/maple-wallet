import XCTest

/// Runs Xcode's accessibility audit (the same checks as Accessibility Inspector) on every
/// main screen and writes a report. Set TEST_RUNNER_STRICT_A11Y=1 to fail on any issue.
final class AccessibilityAuditTests: XCTestCase {
    private var rows: [String] = []

    func testAuditMainScreens() throws {
        let app = XCUIApplication()
        app.launchArguments = ["-uiTesting"]
        app.launch()

        XCTAssertTrue(app.buttons["signIn.button"].waitForExistence(timeout: 10))
        audit(app, screen: "Sign in")
        app.buttons["signIn.button"].tap()

        let chequing = element(app, "accounts.row.chq-001")
        XCTAssertTrue(chequing.waitForExistence(timeout: 10))
        audit(app, screen: "Accounts")
        chequing.tap()
        XCTAssertTrue(element(app, "account.detail.balance").waitForExistence(timeout: 10))
        audit(app, screen: "Account detail")

        openTab(app, "Transfer")
        XCTAssertTrue(app.textFields["transfer.amount"].waitForExistence(timeout: 10))
        audit(app, screen: "Transfer")

        openTab(app, "More")
        sleep(1)
        audit(app, screen: "More")

        writeReport()
        if ProcessInfo.processInfo.environment["STRICT_A11Y"] == "1" {
            XCTAssertFalse(rows.contains { !$0.contains("| Pass |") }, "The accessibility audit found issues")
        }
    }

    private func audit(_ app: XCUIApplication, screen: String) {
        var issues: [String] = []
        do {
            try app.performAccessibilityAudit { issue in
                issues.append(issue.compactDescription)
                return true // record it instead of failing the test
            }
        } catch {
            issues.append("The audit couldn't run: \(error.localizedDescription)")
        }
        if issues.isEmpty {
            rows.append("| \(screen) | Pass | - |")
        } else {
            let detail = issues.map { $0.replacingOccurrences(of: "|", with: "/") }.joined(separator: "<br>")
            rows.append("| \(screen) | \(issues.count) issue(s) | \(detail) |")
        }
    }

    private func writeReport() {
        let report = (["| Screen | Result | Details |", "|---|---|---|"] + rows).joined(separator: "\n") + "\n"
        let attachment = XCTAttachment(string: report)
        attachment.name = "a11y-audit.md"
        attachment.lifetime = .keepAlways
        add(attachment)
        if let folder = evidenceFolder() {
            try? report.write(to: folder.appendingPathComponent("a11y-audit.md"), atomically: true, encoding: .utf8)
        }
    }
}
