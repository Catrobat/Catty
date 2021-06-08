/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        if let currentFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {

            XCTAssertNotEqual(currentFormula.count, 0)
            waitForElementToAppear(app.buttons["backspaceButton"]).tap()

            guard let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String else {
                XCTFail("Could not get the updated formula from the text view")
                return
            }

            XCTAssertEqual(updatedFormula.count, 0)

        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["1"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "1")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["2"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "12")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["3"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "123")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["4"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "1234")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["5"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "12345")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["6"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "123456")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["7"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "1234567")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["8"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "12345678")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["9"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "123456789")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["0"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "1234567890")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

    }

    func testOperatorButtons() {

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        app.buttons[kLocalizedEditFormula].tap()

        waitForElementToAppear(app.buttons["backspaceButton"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["("]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "(")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts[")"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "( )")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["="]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "( ) =")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["."]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "( ) = 0.")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["+"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "( ) = 0. +")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["-"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "( ) = 0. + -")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["x"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "( ) = 0. + - ×")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

        waitForElementToAppear(app.buttons.staticTexts["/"]).tap()

        if let updatedFormula = waitForElementToAppear(app.textViews.firstMatch).value as? String {
            XCTAssertEqual(updatedFormula, "( ) = 0. + - × ÷")
        } else {
            XCTFail("Could not get the current formula from the text view")
        }

    }

    func testSectionButtons() {

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
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
