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

class BrickMovementTests: XCTestCase {

    var app: XCUIApplication!
    let projectName = "testProject"

    override func setUp() {
        super.setUp()
        app = launchApp()

        createProject(name: projectName, in: app)
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        addBrick(label: kLocalizedHide, section: kLocalizedCategoryLook, in: app)
        addBrick(label: kLocalizedSetX, section: kLocalizedCategoryMotion, in: app)
        app.staticTexts[kLocalizedSetX].tap()
        addBrick(label: kLocalizedSetY, section: kLocalizedCategoryMotion, in: app)
        app.staticTexts[kLocalizedSetY].tap()
        addBrick(label: kLocalizedWhenTapped, section: kLocalizedCategoryEvent, in: app)
        app.staticTexts[kLocalizedWhenTapped].tap()

        XCTAssertEqual(app.collectionViews.cells.count, 5)

        let firstBrick = app.collectionViews.cells.element(boundBy: 1)
        let secondBrick = app.collectionViews.cells.element(boundBy: 2)
        let thirdBrick = app.collectionViews.cells.element(boundBy: 3)

        XCTAssertTrue(firstBrick.staticTextEquals(kLocalizedHide, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(secondBrick.staticTextEquals(kLocalizedSetX, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(thirdBrick.staticTextEquals(kLocalizedSetY, ignoreLeadingWhiteSpace: true).exists)
    }

    func testBrickMovementWithinScript() {
        let setYBrick = app.collectionViews.cells.element(boundBy: 3)
        setYBrick.tap()

        let moveBrickButton = app.scrollViews.otherElements.buttons[kLocalizedMoveBrick]
        moveBrickButton.tap()

        setYBrick.press(forDuration: 1, thenDragTo: app.collectionViews.cells.element(boundBy: 1))

        waitForElementToAppear(app.navigationBars[kLocalizedScripts].buttons[kLocalizedBackground]).tap()
        app.navigationBars[kLocalizedBackground].buttons[projectName].tap()
        app.navigationBars[projectName].buttons[kLocalizedPocketCode].tap()

        waitForElementToAppear(app.staticTexts[projectName]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedWhenProjectStarted]).exists)

        let firstBrick = app.collectionViews.cells.element(boundBy: 1)
        let secondBrick = app.collectionViews.cells.element(boundBy: 2)
        let lastBrick = app.collectionViews.cells.element(boundBy: 3)

        XCTAssertTrue(firstBrick.staticTextEquals(kLocalizedSetY, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(secondBrick.staticTextEquals(kLocalizedHide, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(lastBrick.staticTextEquals(kLocalizedSetX, ignoreLeadingWhiteSpace: true).exists)
    }

    func testBrickMovementToOtherScript() {
        let hideBrick = app.collectionViews.cells.element(boundBy: 1)
        hideBrick.tap()

        let moveBrickButton = app.scrollViews.otherElements.buttons[kLocalizedMoveBrick]
        moveBrickButton.tap()

        hideBrick.press(forDuration: 1, thenDragTo: app.collectionViews.cells.element(boundBy: 4))

        waitForElementToAppear(app.navigationBars[kLocalizedScripts].buttons[kLocalizedBackground]).tap()
        app.navigationBars[kLocalizedBackground].buttons[projectName].tap()
        app.navigationBars[projectName].buttons[kLocalizedPocketCode].tap()

        waitForElementToAppear(app.staticTexts[projectName]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedBackground]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        XCTAssert(waitForElementToAppear(app.staticTexts[kLocalizedWhenProjectStarted]).exists)

        let firstBrick = app.collectionViews.cells.element(boundBy: 1)
        let secondBrick = app.collectionViews.cells.element(boundBy: 2)
        let scriptBrick = app.collectionViews.cells.element(boundBy: 3)
        let lastBrick = app.collectionViews.cells.element(boundBy: 4)

        XCTAssertTrue(firstBrick.staticTextEquals(kLocalizedSetX, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(secondBrick.staticTextEquals(kLocalizedSetY, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(scriptBrick.staticTextEquals(kLocalizedWhenTapped, ignoreLeadingWhiteSpace: true).exists)
        XCTAssertTrue(lastBrick.staticTextEquals(kLocalizedHide, ignoreLeadingWhiteSpace: true).exists)
    }
}
