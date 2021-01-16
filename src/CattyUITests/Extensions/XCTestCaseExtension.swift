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

extension XCTestCase {

    static let defaultLaunchArguments = ["UITests", "skipPrivacyPolicy", "restoreDefaultProject"]

    private func defaultApp(with launchArguments: [String]) -> XCUIApplication {
        continueAfterFailure = false

        let app = XCUIApplication()
        app.launchArguments = launchArguments
        return app
    }

    func launchApp(with launchArguments: [String] = defaultLaunchArguments) -> XCUIApplication {
        let app = defaultApp(with: launchArguments)
        app.launch()
        return app
    }

    func launchAppWithoutAnimations() -> XCUIApplication {
        launchApp(with: type(of: self).defaultLaunchArguments + ["disableAnimations"])
    }

    func waitForElementToAppear(_ element: XCUIElement, timeout: TimeInterval = 5) -> XCUIElement {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "waitForElementToAppear failed for \(element.label) ")
        return element
    }

    func waitForElementToDisappear(_ element: XCUIElement, timeout: TimeInterval = 5) -> XCUIElement {
        let expectation = XCTNSPredicateExpectation(predicate: NSPredicate(format: "exists == false"), object: element)

        let result = XCTWaiter().wait(for: [expectation], timeout: timeout)

        XCTAssert(result == .completed, "waitForElementToDisappear failed for \(element.label) ")

        return element
    }

    func createProject(name: String, in app: XCUIApplication) {
        app.tables.staticTexts[kLocalizedNewProject].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedNewProject])
        alert.textFields[kLocalizedEnterYourProjectNameHere].typeText(name)
        alert.buttons[kLocalizedOK].tap()

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[name]))
    }

    func addObjectAndDrawNewImage(name: String, in app: XCUIApplication) {
        app.toolbars.buttons[kLocalizedUserListAdd].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedAddObject])
        alert.textFields[kLocalizedEnterYourObjectNameHere].typeText(name)
        alert.buttons[kLocalizedOK].tap()

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

        findBrickSection(section, in: app)

        XCTAssertTrue(app.navigationBars[section].exists)
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[section]))

        for _ in 0..<maxPageLengthTries {
            if let cell = findCell(with: labels, in: app) {
                cell.tap()

                XCTAssert(waitForElementToAppear(app.navigationBars[kLocalizedScripts]).exists)
                break
            }
            app.swipeUp()
        }
    }

    func findBrickSection(_ name: String, in app: XCUIApplication) {
        if (app.navigationBars[name]).exists {
            return
        } else if (app.navigationBars[kLocalizedCategories]).exists {
            if let cell = findCell(with: [name], in: app) {
                cell.tap()
            }
            return
        } else if (app.navigationBars.buttons[kLocalizedCategories]).exists {
            app.navigationBars.buttons[kLocalizedCategories].tap()
            if let cell = findCell(with: [name], in: app) {
                cell.tap()
            }
            return
        } else {
            XCTFail("no valid View open")
        }
    }

    private func findCell(with labels: [String], in collectionView: XCUIElement) -> XCUIElement? {
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
                    return cell
                }
            }
        }
        return nil
    }
}
