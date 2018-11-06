/**
 *  Copyright (C) 2010-2018 The Catrobat Team
 *  (http://developer.catrobat.org/credits)
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Affero General Public License as
 *  published by the Free Software Foundation, either version 3 of the
 *  License, or (at your option) any later version.
 *
 *  An additional term exception under section 7 of the GNU Affero
 *  General Public License, version 3, is available at
 *  (http://developer.catrobat.org/license_additional_term)
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 *  GNU Affero General Public License for more details.
 *
 *  You should have received a copy of the GNU Affero General Public License
 *  along with this program.  If not, see http://www.gnu.org/licenses/.
 */

import XCTest

class VariablesTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProgram()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testDontShowVariablePickerWhenNoVariablesDefinedForObject() {
        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()
        app.alerts["New Program"].textFields["Enter your program name here..."].typeText("Test Program")
        XCUIApplication().alerts["New Program"].buttons["OK"].tap()
        XCUIApplication().tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()

        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
        }
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()

        app.collectionViews.staticTexts["Set variable"].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Set variable").children(matching: .other).element.tap()
        XCTAssert(app.sheets["Variable type"].exists)
    }

    func testDontShowVListPickerWhenNoListsDefinedForObject() {
        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()
        app.alerts["New Program"].textFields["Enter your program name here..."].typeText("Test Program")
        XCUIApplication().alerts["New Program"].buttons["OK"].tap()
        XCUIApplication().tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()

        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
        }
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeDown()

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Add ").children(matching: .other).element.tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Add ").children(matching: .other).element.tap()
        XCTAssert(app.sheets["List type"].exists)
    }

    func testCreateVariableWithMaxLenght() {

        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()
        app.alerts["New Program"].textFields["Enter your program name here..."].typeText("Test Program")
        XCUIApplication().alerts["New Program"].buttons["OK"].tap()
        XCUIApplication().tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()

        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
        }
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()

        app.collectionViews.staticTexts["Set variable"].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Set variable").children(matching: .other).element.tap()
        XCTAssert(app.sheets["Variable type"].exists)

        app.buttons["for all objects"].tap()
        app.alerts["New Variable"].textFields["Enter your variable name here..."].typeText("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
        app.alerts["New Variable"].buttons["OK"].tap()
        XCTAssert(app.staticTexts["When program started"].exists)
    }

    func testCreateVariableWithMaxLenghtPlusOne() {

        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()
        app.alerts["New Program"].textFields["Enter your program name here..."].typeText("Test Program")
        XCUIApplication().alerts["New Program"].buttons["OK"].tap()
        XCUIApplication().tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()

        if app.navigationBars["Frequently Used"].exists {
            app.swipeLeft()
        }
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()

        app.collectionViews.staticTexts["Set variable"].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Set variable").children(matching: .other).element.tap()
        XCTAssert(app.sheets["Variable type"].exists)

        app.buttons["for all objects"].tap()
        app.alerts["New Variable"].textFields["Enter your variable name here..."].typeText("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii")
        app.alerts["New Variable"].buttons["OK"].tap()
        XCTAssert(app.alerts["Pocket Code"].exists)
    }
}
