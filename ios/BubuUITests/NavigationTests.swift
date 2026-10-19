import XCTest
final class NavigationTests: XCTestCase {
    func testFoundationNavigation() {
        let app = XCUIApplication(); app.launchArguments = ["--uitesting"]; app.launch()
        XCTAssertTrue(app.buttons["level-1"].waitForExistence(timeout: 10))
        capture("01-livelli")
        app.buttons["level-1"].tap()
        XCTAssertTrue(app.staticTexts["Copertura del programma"].waitForExistence(timeout: 5))
        capture("02-hsk1")
        app.swipeUp()
        app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Il percorso")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["15 modi di usare il cinese"].waitForExistence(timeout: 5))
        capture("03-percorso")
    }
    func capture(_ name: String) {
        let a = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); a.name = name; a.lifetime = .keepAlways; add(a)
    }
}
