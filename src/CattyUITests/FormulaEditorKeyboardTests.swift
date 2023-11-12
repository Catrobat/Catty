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

class FormulaEditorKeyboardTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    func testBackspaceAndNumbers() {
        let numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        waitForElementToAppear(app.buttons["backspaceButton"]).tap()
        XCTAssertEqual(waitForElementToAppear(app.textViews.firstMatch).value as! String, "")

        var expectedFormula = ""
        for number in numbers {
            expectedFormula += number

            waitForElementToAppear(app.buttons.staticTexts[number]).tap()
            XCTAssertEqual(waitForElementToAppear(app.textViews.firstMatch).value as! String, expectedFormula)
        }
    }

    func testOperatorButtons() {
        let operators = ["(": "(",
                         ")": ")",
                         "=": "=",
                         ".": "0.",
                         "+": "+",
                         "-": "-",
                         "x": "×",
                         "/": "÷"]

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        waitForElementToAppear(app.buttons["backspaceButton"]).tap()
        XCTAssertEqual(waitForElementToAppear(app.textViews.firstMatch).value as! String, "")

        var expectedFormula = ""
        for (operatorButton, formulaDisplayString) in operators {
            if !expectedFormula.isEmpty {
                expectedFormula += " "
            }
            expectedFormula += formulaDisplayString

            waitForElementToAppear(app.buttons.staticTexts[operatorButton]).tap()
            XCTAssertEqual(waitForElementToAppear(app.textViews.firstMatch).value as! String, expectedFormula)
        }
    }

    func testSectionButtons() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        waitForElementToAppear(app.buttons[kLocalizedEditFormula]).tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFEFunctions]).tap()
        XCTAssertTrue(app.navigationBars.staticTexts[kUIFEFunctions].exists)
        app.navigationBars.buttons[kLocalizedBack].tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFEProperties]).tap()
        XCTAssertTrue(app.navigationBars.staticTexts[kUIFEProperties].exists)
        app.navigationBars.buttons[kLocalizedBack].tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFESensor]).tap()
        XCTAssertTrue(app.navigationBars.staticTexts[kUIFESensor].exists)
        app.navigationBars.buttons[kLocalizedBack].tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFELogic]).tap()
        XCTAssertTrue(app.navigationBars.staticTexts[kUIFELogic].exists)
        app.navigationBars.buttons[kLocalizedBack].tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFEData]).tap()
        XCTAssertTrue(app.navigationBars.staticTexts[kUIFEData].exists)
        app.navigationBars.buttons[kLocalizedBack].tap()
    }

    func testArrowButton() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        waitForElementToAppear(app.buttons[kLocalizedEditFormula]).tap()

        XCTAssertTrue(waitForElementToAppear(app.otherElements["keyboardAccessoryView"]).exists)

        waitForElementToAppear(app.buttons["arrowButton"]).tap()
        XCTAssertFalse(app.otherElements["keyboardAccessoryView"].exists)

        waitForElementToAppear(app.buttons["arrowButton"]).tap()
        XCTAssertTrue(app.otherElements["keyboardAccessoryView"].exists)

        waitForElementToAppear(app.buttons["arrowButton"]).tap()
        XCTAssertFalse(app.otherElements["keyboardAccessoryView"].exists)
    }

    func testTextButton() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        waitForElementToAppear(app.buttons[kLocalizedEditFormula]).tap()
        waitForElementToAppear(app.buttons["backspaceButton"]).tap()

        waitForElementToAppear(app.buttons.staticTexts["Abc"]).tap()

        app.alerts[kUIFENewText].textFields.firstMatch.typeText("test text")
        app.alerts[kUIFENewText].buttons[kLocalizedOK].tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "'test text'")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }
    }
}
