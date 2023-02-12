/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

class VisualPlacementTest: XCTestCase {
    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
        openScript()
    }

    func testVisualPlacementOnPlaceAtBrick() {
        for number in 0..<2 {
            tapOnBrickCell(number: number, of: kLocalizedPlaceAt, in: app)

            XCTAssert(waitForElementToAppear(app.buttons[kLocalizedPlaceVisually]).exists)
            XCTAssert(waitForElementToAppear(app.buttons[kLocalizedEditFormula]).exists)

            app.buttons[kLocalizedPlaceVisually].tap()
            waitForElementToAppear(app.buttons[kLocalizedDone]).tap()
            XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedScripts], timeout: 10).exists)
        }

        tapOnBrick(atPosition: 3, in: app)
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedPlaceVisually]).exists)
    }

    func testVisualPlacementOnGlideToBrick() {
        tapOnBrickCell(number: 0, of: kLocalizedGlide, in: app)

        XCTAssert(waitForElementToAppear(app.buttons[kUIFEFunctions]).exists)
        app.buttons[kLocalizedDone].tap()

        for number in 1..<3 {
            tapOnBrickCell(number: number, of: kLocalizedGlide, in: app)

            XCTAssert(waitForElementToAppear(app.buttons[kLocalizedPlaceVisually]).exists)
            XCTAssert(waitForElementToAppear(app.buttons[kLocalizedEditFormula]).exists)

            app.buttons[kLocalizedPlaceVisually].tap()
            waitForElementToAppear(app.buttons[kLocalizedDone]).tap()
            XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedScripts], timeout: 10).exists)
        }

        tapOnBrick(atPosition: 7, in: app)
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedPlaceVisually]).exists)
    }

    func testNoVisualPlacementOnDifferentBrick() {
        tapOnBrickCell(number: 0, of: kLocalizedSetSizeTo, in: app)
        XCTAssert(waitForElementToAppear(app.buttons[kUIFEFunctions]).exists)

        app.buttons[kLocalizedCancel].tap()
        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedScripts]).exists)

        tapOnBrick(atPosition: 1, in: app)
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedEditFormula]).exists)
        XCTAssert(!app.buttons[kLocalizedPlaceVisually].exists)

    }

    func testVisualPlacementFromFormulaEditor() {
        tapOnBrickCell(number: 0, of: kLocalizedPlaceAt, in: app)

        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedPlaceVisually]).exists)
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedEditFormula]).exists)

        app.buttons[kLocalizedEditFormula].tap()

        XCTAssert(waitForElementToAppear(app.buttons.staticTexts[kUIFEFunctions]).exists)

        tapOnBrickCell(number: 1, of: kLocalizedPlaceAt, in: app, fromFormualEditor: true)

        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedPlaceVisually]).exists)
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedEditFormula]).exists)

    }

    func testNoVisualPlacementIfNotSingleValue() {
        tapOnBrickCell(number: 0, of: kLocalizedPlaceAt, in: app)

        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedPlaceVisually]).exists)
        XCTAssert(waitForElementToAppear(app.buttons[kLocalizedEditFormula]).exists)

        app.buttons[kLocalizedEditFormula].tap()
        waitForElementToAppear(app.buttons.staticTexts[kUIFEFunctions]).tap()
        let functionsPredicate = NSPredicate(format: "label CONTAINS[c] %@", kUIFEFunctionSine)
        waitForElementToAppear(app.tables.staticTexts.element(matching: functionsPredicate)).firstMatch.tap()

        XCTAssert(waitForElementToAppear(app.buttons.staticTexts[kUIFEFunctions]).exists)

        tapOnBrickCell(number: 1, of: kLocalizedPlaceAt, in: app, fromFormualEditor: true)

        XCTAssert(waitForElementToAppear(app.buttons[kUIFEFunctions]).exists)
        XCTAssert(!app.buttons[kLocalizedPlaceVisually].exists)
    }

    func openScript() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
    }

}
