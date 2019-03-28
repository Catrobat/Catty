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

        app.tap()
        app.navigationBars.buttons[kLocalizedLooks].tap()

        waitForElementToAppear(app.alerts[kLocalizedSaveToPocketCode]).buttons[kLocalizedYes].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars.buttons[kLocalizedPocketCode]))
    }

    func addBrick(label: String, section: String, in app: XCUIApplication) {
        addBrick(labels: [label], section: section, in: app)
    }

    func addBrick(labels: [String], section: String, in app: XCUIApplication) {
        let maxPageLengthTries = 3

        XCTAssertNotNil(app.staticTexts[kLocalizedScripts])

        waitForElementToAppear(app.toolbars.buttons[kLocalizedUserListAdd]).tap()
        findSection(section, in: app)

        XCTAssertTrue(app.navigationBars[section].exists)

        for _ in 0..<maxPageLengthTries {
            if findCell(with: labels, in: app.collectionViews.firstMatch) {
                break
            }
            app.swipeUp()
        }
    }

    private func findSection(_ name: String, in app: XCUIApplication) {
        let maxTries = 8

        for _ in 0..<maxTries {
            if app.navigationBars[name].exists {
                return
            }
            app.swipeLeft()
        }
    }

    private func findCell(with labels: [String], in collectionView: XCUIElement) -> Bool {
        for cellIndex in 0...collectionView.cells.count {
            let cell = collectionView.cells.element(boundBy: cellIndex)

            if cell.staticTexts.count >= labels.count {
                var allLabelsPresent = true

                for label in labels {
                    if !cell.staticTextEquals(label, ignoreLeadingWhiteSpace: true).exists {
                        allLabelsPresent = false
                    }
                }
                if allLabelsPresent {
                    cell.tap()
                    return true
                }
            }
        }
        return false
    }
}
