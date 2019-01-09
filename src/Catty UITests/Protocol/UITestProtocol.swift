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

protocol UITestProtocol {
    func restoreDefaultProgram()
    func dismissWelcomeScreenIfShown()
}

extension UITestProtocol {

    func restoreDefaultProgram() {
        // Restore default program
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        waitForElementToAppear(app.navigationBars["Programs"]).buttons["Edit"].tap()
        waitForElementToAppear(app.buttons["Delete Programs"]).tap()
        let toolbarsQuery = app.toolbars
        waitForElementToAppear(toolbarsQuery.buttons["Select All"]).tap()
        waitForElementToAppear(toolbarsQuery.buttons["Delete"]).tap()
        XCTAssert(app.tables.cells.count == 1)
        // finally go back to main menu, because this method is used by other tests
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
    }

    func dismissWelcomeScreenIfShown() {

        let app = XCUIApplication()

        if app.buttons["Dismiss"].exists {
            app.buttons["Dismiss"].tap()
        }
    }

    func waitForElementToAppear(_ element: XCUIElement) -> XCUIElement {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == true"), object: element)

        let result = XCTWaiter().wait(for: [expectation], timeout: 5)



        XCTAssert(result == .completed)

        return element
    }
}
