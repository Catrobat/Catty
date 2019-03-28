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
    func restoreDefaultProject()
    func dismissWelcomeScreenIfShown()
}

extension UITestProtocol {

    func restoreDefaultProject() {
        let app = XCUIApplication()
        app.tables.staticTexts[kLocalizedProjects].tap()
        waitForElementToAppear(app.navigationBars[kLocalizedProjects]).buttons[kLocalizedEdit].tap()
        waitForElementToAppear(app.buttons[kLocalizedDeleteProjects]).tap()
        let toolbarsQuery = app.toolbars
        waitForElementToAppear(toolbarsQuery.buttons[kLocalizedSelectAllItems]).tap()
        waitForElementToAppear(toolbarsQuery.buttons[kLocalizedDelete]).tap()
        XCTAssert(app.tables.cells.count == 1)
        // finally go back to main menu, because this method is used by other tests
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()
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

    func skipFrequentlyUsedBricks(_ app: XCUIApplication) {
        if app.navigationBars[kLocalizedFrequentlyUsed].exists {
            app.swipeLeft()
        }
    }

    func createProject(name: String, in app: XCUIApplication) {
        app.tables.staticTexts[kLocalizedNew].tap()
        app.alerts[kLocalizedNewProject].textFields[kLocalizedEnterYourProjectNameHere].typeText(name)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[name]))
    }

    func addObjectAndDrawNewImage(name: String, in app: XCUIApplication) {
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        app.alerts[kLocalizedAddObject].textFields[kLocalizedEnterYourObjectNameHere].typeText(name)
        app.alerts[kLocalizedAddObject].buttons[kLocalizedOK].tap()

        waitForElementToAppear(app.buttons[kLocalizedDrawNewImage]).tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]))

        // Draw image
        app.tap()
        app.navigationBars.buttons[kLocalizedLooks].tap()

        waitForElementToAppear(app.alerts[kLocalizedSaveToPocketCode]).buttons[kLocalizedYes].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars.buttons[kLocalizedPocketCode]))
    }
}
