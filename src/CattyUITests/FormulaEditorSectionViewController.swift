/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

class FormulaEditorSectionViewControllerTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    func testFunctionSection() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFEFunctions]).tap()
        waitForElementToAppear(app.tables.staticTexts["\(kUIFEFunctionAbs)(1)"]).tap()

        if let textViewText = app.textViews.element.value as? String {
            XCTAssertEqual(textViewText, "\(kUIFEFunctionAbs)( 1 )")
        } else {
            XCTFail("Could not find the textview.")
        }
    }

    func testLogicSection() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFELogic]).tap()
        waitForElementToAppear(app.tables.staticTexts["and"]).tap()

        if let textViewText = app.textViews.element.value as? String {
            XCTAssertEqual(textViewText, "and")
        } else {
            XCTFail("Could not find the textview.")
        }
    }

    func testSensorsSection() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFESensor]).tap()
        waitForElementToAppear(app.tables.staticTexts["inclination x"]).tap()

        if let textViewText = app.textViews.element.value as? String {
            XCTAssertEqual(textViewText, "inclination x")
        } else {
            XCTFail("Could not find the textview.")
        }
    }

}
