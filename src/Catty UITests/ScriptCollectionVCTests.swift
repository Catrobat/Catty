/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

class ScriptCollectionVCTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    func testCopyIfLogicBeginBrick() {
        let app = XCUIApplication()
        let projectName = "testProject"

        app.tables.staticTexts["New"].tap()
        let alertQuery = app.alerts["New Project"]
        alertQuery.textFields["Enter your project name here..."].typeText(projectName)
        app.alerts["New Project"].buttons["OK"].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        waitForElementToAppear(app.staticTexts["Background"]).tap()
        waitForElementToAppear(app.staticTexts["Scripts"]).tap()

        waitForElementToAppear(app.toolbars.buttons["Add"]).tap()
        skipFrequentlyUsedBricks(app)

        XCTAssertTrue(app.navigationBars["Control"].exists)

        let startCoord = app.collectionViews.element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        let endCoord = startCoord.withOffset(CGVector(dx: 0.0, dy: -500)); // scroll to bottom
        startCoord.press(forDuration: 0.01, thenDragTo: endCoord)

        for cellIndex in 0...app.collectionViews.cells.count {
            let cell = app.collectionViews.cells.element(boundBy: cellIndex)
            if cell.staticTexts.count == 2 && cell.staticTexts["If "].exists && cell.staticTexts[" is true then"].exists {
                cell.tap()
            }
        }

        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[" is true then"].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts["End If"].exists)

        app.collectionViews.cells.element(boundBy: 1).tap()
        XCTAssertTrue(app.sheets["Edit Brick"].exists)

        let copyButton = app.sheets["Edit Brick"].buttons.element(boundBy: 1)
        XCTAssertEqual("Copy Brick", copyButton.label)
        copyButton.tap()

        XCTAssertEqual(5, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[" is true then"].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts["End If"].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts[" is true then"].exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts["End If"].exists)
    }

    func testLengthOfBroadcastMessage() {
        let app = XCUIApplication()
        let projectName = "testProject"
        let message = String(repeating: "a", count: 250)

        app.tables.staticTexts["New"].tap()
        app.alerts["New Project"].textFields["Enter your project name here..."].typeText(projectName)
        XCUIApplication().alerts["New Project"].buttons["OK"].tap()
        XCUIApplication().tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()

        app.toolbars.buttons["Add"].tap()
        skipFrequentlyUsedBricks(app)

        app.collectionViews.staticTexts["Broadcast"].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Broadcast").children(matching: .other).element.tap()

        app.pickerWheels.firstMatch.swipeDown()
        app.buttons["Done"].tap()

        let alert = app.alerts["New Message"]
        alert.textFields["Enter your message here..."].typeText(message)
        alert.buttons["OK"].tap()

        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Broadcast").children(matching: .other).element.tap()

        app.pickerWheels.firstMatch.swipeDown()
        app.buttons["Done"].tap()

        alert.textFields["Enter your message here..."].typeText(message + "b")
        alert.buttons["OK"].tap()
        XCTAssert(app.alerts["Pocket Code"].exists)
    }

    func testWaitBrick() {
        let app = XCUIApplication()
        let projectName = "testProject"

        app.tables.staticTexts["New"].tap()
        app.alerts["New Project"].textFields["Enter your project name here..."].typeText(projectName)
        XCUIApplication().alerts["New Project"].buttons["OK"].tap()
        XCUIApplication().tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()

        app.toolbars.buttons["Add"].tap()
        skipFrequentlyUsedBricks(app)

        app.collectionViews.staticTexts["Wait "].tap()
        app.collectionViews.cells.otherElements.containing(.staticText, identifier: "Wait ").children(matching: .button).element.tap()

        XCTAssertTrue(waitForElementToAppear(app.buttons["Cancel"]).exists)

        app.buttons["Sensors"].tap()
        app.buttons["loudness"].tap()
        app.buttons["Done"].tap()

        XCTAssertTrue(waitForElementToAppear(app.navigationBars["Scripts"]).exists)
    }
}
