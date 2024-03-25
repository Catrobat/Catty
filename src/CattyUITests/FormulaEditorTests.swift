/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class FormulaEditorTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    func testFormulaEditorSave() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        waitForElementToAppear(app.buttons.staticTexts["7"]).tap()
        waitForElementToAppear(app.buttons.staticTexts["5"]).tap()
        app.buttons[kLocalizedDone].firstMatch.tap()

        var predicate = NSPredicate(format: "label CONTAINS[c] %@", "75")
        if app.collectionViews.cells.staticTexts.containing(predicate).allElementsBoundByIndex.isEmpty {
            XCTFail("Script Collection View is not updated with the changed formula")
        }

        app.collectionViews.cells.staticTexts.containing(predicate).firstMatch.tap()
        waitForElementToAppear(app.buttons.staticTexts["3"]).tap()
        waitForElementToAppear(app.buttons.staticTexts["0"]).tap()
        app.buttons[kLocalizedDone].firstMatch.tap()

        predicate = NSPredicate(format: "label CONTAINS[c] %@", "30")
        if app.collectionViews.cells.staticTexts.containing(predicate).allElementsBoundByIndex.isEmpty {
            XCTFail("Script Collection View is not updated with the changed formula")
        }

        XCTWaiter().wait(for: [XCTNSNotificationExpectation(name: NSNotification.Name(rawValue: "Wait for project to be saved"))], timeout: 10)

        app.navigationBars.buttons[kLocalizedMole + " 1"].tap()
        app.navigationBars.buttons["\(kLocalizedScene) 1"].tap()
        app.navigationBars.buttons[kLocalizedMyFirstProject].tap()
        app.navigationBars.buttons[kLocalizedProjects].tap()
        app.navigationBars.buttons[kLocalizedPocketCode].tap()

        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        if app.collectionViews.cells.staticTexts.containing(predicate).allElementsBoundByIndex.isEmpty {
            XCTFail("Script Collection View is not updated with the changed formula")
        }
    }

    func testFormulaEditorCancel() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        waitForElementToAppear(app.buttons.staticTexts["7"]).tap()
        waitForElementToAppear(app.buttons.staticTexts["5"]).tap()
        app.buttons[kLocalizedCancel].firstMatch.tap()

        var predicate = NSPredicate(format: "label CONTAINS[c] %@", "30")
        if app.collectionViews.cells.staticTexts.containing(predicate).allElementsBoundByIndex.isEmpty {
            XCTFail("Script Collection View updated despite tapped cancel")
        }

        app.navigationBars.buttons[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        predicate = NSPredicate(format: "label CONTAINS[c] %@", "30")
        if app.collectionViews.cells.staticTexts.containing(predicate).allElementsBoundByIndex.isEmpty {
            XCTFail("Script Collection View updated despite tapped cancel")
        }

        app.navigationBars.buttons[kLocalizedMole + " 1"].tap()
        app.navigationBars.buttons["\(kLocalizedScene) 1"].tap()
        app.navigationBars.buttons[kLocalizedMyFirstProject].tap()
        app.navigationBars.buttons[kLocalizedProjects].tap()
        app.navigationBars.buttons[kLocalizedPocketCode].tap()

        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        if app.collectionViews.cells.staticTexts.containing(predicate).allElementsBoundByIndex.isEmpty {
            XCTFail("Script Collection View updated despite tapped cancel")
        }

    }

}
