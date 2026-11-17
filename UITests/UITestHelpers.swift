import XCTest

/// Any element with this accessibility identifier, whatever its type.
func element(_ app: XCUIApplication, _ identifier: String) -> XCUIElement {
    app.descendants(matching: .any)[identifier]
}

/// Taps a tab whether iOS draws a bottom tab bar (iPhone) or a top tab strip (iPad).
func openTab(_ app: XCUIApplication, _ name: String) {
    let tab = app.tabBars.buttons[name]
    if tab.exists {
        tab.tap()
    } else {
        app.buttons[name].firstMatch.tap()
    }
}

/// Drags down from an element, like a finger pulling to refresh.
func pullToRefresh(from element: XCUIElement) {
    let start = element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.1))
    start.press(forDuration: 0.1, thenDragTo: start.withOffset(CGVector(dx: 0, dy: 360)))
}

/// Slows tests down only while a demo is being recorded (TEST_RUNNER_DEMO_PACE=1).
func demoPause(_ seconds: UInt32 = 1) {
    if ProcessInfo.processInfo.environment["DEMO_PACE"] != nil { sleep(seconds) }
}

/// Where tests drop screenshots and reports on the Mac running the Simulator.
func evidenceFolder() -> URL? {
    guard let home = ProcessInfo.processInfo.environment["SIMULATOR_HOST_HOME"] else { return nil }
    let folder = URL(fileURLWithPath: home).appendingPathComponent("maple-shots")
    try? FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
    return folder
}
