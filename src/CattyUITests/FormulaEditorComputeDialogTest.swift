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

class FormulaEditorComputeDialogTest: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    func testUpdateTimeInterval() {

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()
        app.tables.staticTexts[kLocalizedMole + " 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.allElementsBoundByIndex[1].tap()
        waitForElementToAppear(app.buttons[kLocalizedEditFormula]).tap()

        waitForElementToAppear(app.buttons.staticTexts[kUIFESensor]).tap()
        waitForElementToAppear(app.tables.staticTexts[kUIFESensorTimeSecond]).tap()
        waitForElementToAppear(app.buttons.staticTexts[kUIFECompute]).tap()

        for _ in 1...2 {
            let initial = Int(app.alerts.element.label)
            sleep(2)
            let final = Int(app.alerts.element.label)
            XCTAssertNotEqual(initial!, final!)
        }

    }

}
