import XCTest
final class NavigationTests: XCTestCase {
    func testFoundationNavigation() {
        let app = XCUIApplication(); app.launchArguments = ["--uitesting"]; app.launch()
        XCTAssertTrue(app.buttons["level-1"].waitForExistence(timeout: 10))
        capture("01-livelli")
        app.buttons["level-1"].tap()
        XCTAssertTrue(app.staticTexts["Copertura del programma"].waitForExistence(timeout: 5))
        capture("02-hsk1")
        tapVisible(app, app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "Il percorso")).firstMatch)
        XCTAssertTrue(app.staticTexts["15 modi di usare il cinese"].waitForExistence(timeout: 5))
        capture("03-percorso")
    }
    func testObjectiveReviewAndGrammar() {
        let app = XCUIApplication(); app.launchArguments = ["--uitesting"]; app.launch()
        app.tabBars.buttons["Ripasso"].tap()
        app.buttons["start-review"].tap()
        XCTAssertTrue(app.buttons["answer-1"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.staticTexts["card-back"].exists)
        capture("04-ripasso-fronte")
        app.buttons["answer-1"].tap()
        XCTAssertTrue(app.staticTexts["card-back"].waitForExistence(timeout: 5))
        capture("05-ripasso-retro")
        app.buttons["continue-review"].tap()
        let wrong = app.buttons.matching(NSPredicate(format: "identifier BEGINSWITH 'answer-' AND identifier != 'answer-1'")).firstMatch
        XCTAssertTrue(wrong.waitForExistence(timeout: 5))
        wrong.tap()
        XCTAssertTrue(app.staticTexts["Da rivedere"].waitForExistence(timeout: 5))
        capture("19-ripasso-errore")
        app.buttons["continue-review"].tap()
        XCTAssertTrue(app.textFields["pinyin-input"].waitForExistence(timeout: 5))
        capture("06-pinyin")
        app.textFields["pinyin-input"].tap(); app.textFields["pinyin-input"].typeText("ai")
        app.swipeUp()
        app.buttons["Verifica"].tap()
        XCTAssertTrue(app.staticTexts["Da rivedere"].waitForExistence(timeout: 5))
        capture("20-pinyin-correzione")
        // Durante il ripasso la barra delle schede è nascosta: si torna indietro prima di cambiare scheda.
        app.navigationBars.buttons.firstMatch.tap()
        app.tabBars.buttons["Livelli"].tap()
        app.buttons["level-1"].tap()
        tapVisible(app, app.buttons.matching(NSPredicate(format: "label CONTAINS %@", "70 righe")).firstMatch)
        XCTAssertTrue(app.navigationBars["Grammatica"].waitForExistence(timeout: 5))
        capture("07-grammatica")
        app.cells.element(boundBy:1).tap()
        tapVisible(app, app.buttons["grammar-quiz"])
        XCTAssertTrue(app.staticTexts["Quale significato esprime questa frase?"].waitForExistence(timeout:5))
        XCTAssertFalse(app.buttons["answer-1"].exists, "La grammatica non deve mostrare una parola con lo stesso ID numerico")
    }
    func testExamModes() {
        let app=XCUIApplication();app.launchArguments=["--uitesting"];app.launch()
        app.buttons["level-1"].tap()
        tapVisible(app,app.buttons["exam-landing"])
        XCTAssertTrue(app.buttons["start-exam"].waitForExistence(timeout:5))
        capture("08-esame-modalita")
        app.segmentedControls.buttons["Allenamento"].tap()
        app.buttons["start-exam"].tap()
        XCTAssertTrue(app.buttons["replay-audio"].waitForExistence(timeout:5))
        capture("09-allenamento")
        app.buttons["exam-option-A"].tap()
        app.swipeUp()
        XCTAssertTrue(app.otherElements["exam-feedback"].exists || app.staticTexts["Risposta corretta"].exists || app.staticTexts["Risposta: B"].exists || app.staticTexts["Risposta: C"].exists)
        capture("10-correzione")
        app.buttons["Esci"].tap();app.alerts.buttons["Interrompi"].tap()
        app.segmentedControls.buttons["Simulazione"].tap()
        app.buttons["start-exam"].tap()
        XCTAssertTrue(app.staticTexts["exam-countdown"].waitForExistence(timeout:5))
        XCTAssertFalse(app.buttons["replay-audio"].exists)
        XCTAssertFalse(app.otherElements["exam-feedback"].exists)
        capture("11-simulazione")
    }
    func testPracticeModulesAndNoFooter() {
        let app=XCUIApplication();app.launchArguments=["--uitesting"];app.launch()
        XCTAssertFalse(app.staticTexts.matching(NSPredicate(format:"label CONTAINS %@","Non affiliata")).firstMatch.exists)
        capture("12-home-senza-footer")
        app.buttons["level-1"].tap()
        capture("13-livello-senza-footer")
        openModule(app,"tone-practice")
        XCTAssertTrue(app.navigationBars["Pronuncia e toni"].waitForExistence(timeout:5))
        capture("14-pronuncia")
        app.navigationBars.buttons.firstMatch.tap()
        openModule(app,"writing-practice")
        XCTAssertTrue(app.navigationBars["Scrittura · 100 caratteri"].waitForExistence(timeout:5))
        app.cells.element(boundBy:1).tap()
        XCTAssertTrue(app.buttons["Anima"].waitForExistence(timeout:5))
        app.buttons["Anima"].tap()
        capture("15-scrittura")
        app.navigationBars.buttons.firstMatch.tap();app.navigationBars.buttons.firstMatch.tap()
        openModule(app,"reading-practice")
        XCTAssertTrue(app.navigationBars["Lettura graduata"].waitForExistence(timeout:5))
        app.cells.element(boundBy:1).tap()
        XCTAssertTrue(app.navigationBars["Unità 1"].waitForExistence(timeout:5))
        capture("16-lettura")
        app.navigationBars.buttons.firstMatch.tap();app.navigationBars.buttons.firstMatch.tap()
        openModule(app,"oral-practice")
        XCTAssertTrue(app.navigationBars["Pratica orale"].waitForExistence(timeout:5))
        capture("17-orale")
        app.tabBars.buttons["Il mio piano"].tap()
        app.swipeUp()
        capture("18-fonti-nel-piano")
    }
    func testPinyinIPA() {
        let app=XCUIApplication();app.launchArguments=["--uitesting"];app.launch()
        app.buttons["level-1"].tap()
        openModule(app,"pinyin-ipa")
        XCTAssertTrue(app.navigationBars["Pinyin e IPA"].waitForExistence(timeout:5))
        let field=app.textFields["ipa-input"];field.tap();field.typeText("xie4xie5\n")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label == %@","[ɕje˥˩.ɕje˩]")).firstMatch.waitForExistence(timeout:5))
        capture("21-pinyin-ipa")
        app.buttons.matching(NSPredicate(format:"label CONTAINS %@","谢谢")).firstMatch.tap()
        XCTAssertTrue(app.staticTexts["word-ipa"].waitForExistence(timeout:5))
        for _ in 0..<4 {if app.staticTexts["word-ipa"].isHittable{break};app.swipeUp()}
        capture("22-parola-ipa")
        app.navigationBars.buttons.firstMatch.tap()
        openModule(app,"sound-x")
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format:"label CONTAINS %@","[ɕ]")).firstMatch.waitForExistence(timeout:5))
        capture("23-suono-ipa")
    }
    func openModule(_ app:XCUIApplication,_ id:String) { tapVisible(app,app.buttons[id]) }
    /// Scorre nelle due direzioni finché l'elemento sta tra la barra di navigazione e quella delle schede, poi lo tocca.
    func tapVisible(_ app:XCUIApplication,_ element:XCUIElement) {
        // Le griglie pigre creano le celle solo quando entrano nello schermo.
        if !element.waitForExistence(timeout:2) { for _ in 0..<10 where !element.exists { app.swipeUp(velocity:.slow) } }
        for _ in 0..<8 {
            let top=app.navigationBars.firstMatch.exists ? app.navigationBars.firstMatch.frame.maxY : 0
            let bottom=app.tabBars.firstMatch.exists ? app.tabBars.firstMatch.frame.minY : app.frame.maxY
            if element.isHittable && element.frame.minY>=top && element.frame.maxY<=bottom {break}
            if element.frame.minY<top {app.swipeDown(velocity:.slow)} else {app.swipeUp(velocity:.slow)}
        }
        element.tap()
    }
    func capture(_ name: String) {
        Thread.sleep(forTimeInterval:0.6) // Completa la transizione prima di esportare l'immagine.
        let a = XCTAttachment(screenshot: XCUIScreen.main.screenshot()); a.name = name; a.lifetime = .keepAlways; add(a)
    }
}
