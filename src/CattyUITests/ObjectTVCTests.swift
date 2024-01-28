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

class ObjectTVCTests: XCTestCase {

    var app: XCUIApplication!

    func testScriptsCanEnterScriptsOfAllMoles() {
        app = launchApp()

        let projectObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()

        //check every mole for script
        for object in projectObjects {
            waitForElementToAppear(app.tables.staticTexts[object]).tap()
            app.tables.staticTexts[kLocalizedScripts].tap()
            XCTAssert(app.navigationBars[kLocalizedScripts].buttons[object].exists)
            app.navigationBars[kLocalizedScripts].buttons[object].tap()
            app.navigationBars[object].buttons["\(kLocalizedScene) 1"].tap()
            XCTAssert(waitForElementToAppear(app.navigationBars["\(kLocalizedScene) 1"]).exists)
        }
    }

    func testScriptsCanDeleteBrickSetSizeTo() {
        app = launchApp()

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        waitForElementToAppear(app.tables.staticTexts["Mole 1"]).tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        //delete the SetSizeTo brick
        app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedSetSizeTo).tap()
        app.buttons[kLocalizedDeleteBrick].tap()

        //Check if Forever brick is now where SetSizeTo was before
        app.navigationBars[kLocalizedScripts].buttons["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts[kLocalizedForever].exists)
    }

    func testScriptsCanDeleteBrickLoop() {
        app = launchApp()

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        waitForElementToAppear(app.tables.staticTexts["Mole 1"]).tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        //delete the EndOfLoop
        app.collectionViews.cells.element(boundBy: 2).tap()
        app.buttons[kLocalizedDeleteLoop].tap()

        //Check if deleted successful
        app.navigationBars[kLocalizedScripts].buttons["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts[kLocalizedShow].exists)
    }

    func testScriptsCanCopyForeverBrick() {
        app = launchApp(with: ["skipPrivacyPolicy", "restoreDefaultProject"])

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        waitForElementToAppear(app.tables.staticTexts["Mole 1"]).tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        //copy the Forever brick
        app.collectionViews.cells.element(boundBy: 2).tap()
        app.buttons[kLocalizedCopyBrick].tap()

        //Check if copied successfull
        app.navigationBars[kLocalizedScripts].buttons["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts[kLocalizedEndOfLoop].exists)
    }

    func testScriptsCanDeleteWhenProjectStartedBrick() {
        app = launchApp()

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        waitForElementToAppear(app.tables.staticTexts["Mole 1"]).tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        //delete the WhenProjectStartedBrick
        app.collectionViews.cells.element(boundBy: 0).tap()
        app.buttons[kLocalizedDeleteScript].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedDeleteThisScript])
        alert.buttons[kLocalizedYes].tap()

        //Check if deltetd successful
        app.navigationBars[kLocalizedScripts].buttons["Mole 1"].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts[kLocalizedWhenTapped].exists)
    }

    func testScriptsCanDeleteWaitBrick() {
        app = launchApp()

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        waitForElementToAppear(app.tables.staticTexts["Mole 1"]).tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        app.collectionViews.cells.element(boundBy: 4).staticTextBeginsWith(kLocalizedWait).tap()
        app.buttons[kLocalizedDeleteBrick].tap()
        app.swipeDown()
        XCTAssert(app.staticTexts[kLocalizedShow].exists)

    }

    func testLooksCanEnterSingleLook() {
        app = launchApp()

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        waitForElementToAppear(app.tables.staticTexts["Mole 1"]).tap()
        app.tables.staticTexts[kLocalizedLooks].tap()

        XCTAssert(app.navigationBars[kLocalizedLooks].exists)
    }

    func testCopyObjectWithIfBricks() {
        app = launchApp()

        let projectName = "testProject"
        let objectName = "testObject"
        let copiedObjectName = objectName + " (1)"

        app.tables.staticTexts[kLocalizedNewProject].tap()
        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(projectName)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))
        app.staticTexts["\(kLocalizedScene) 1"].tap()

        addObjectAndDrawNewImage(name: objectName, in: app, projectName: projectName)

        XCTAssertNotNil(waitForElementToAppear(app.navigationBars["\(kLocalizedScene) 1"]))
        waitForElementToAppear(app.tables.staticTexts[objectName]).tap()
        waitForElementToAppear(app.staticTexts[kLocalizedScripts]).tap()

        addBrick(labels: [kLocalizedIfBegin, kLocalizedIfBeginSecondPart], section: kLocalizedCategoryControl, in: app)

        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedIfBeginSecondPart, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedEndIf].exists)

        app.navigationBars.buttons[objectName].tap()
        app.navigationBars.buttons["\(kLocalizedScene) 1"].tap()

        // Copy object
        app.tables.staticTexts[objectName].swipeLeft()
        app.buttons[kLocalizedMore].tap()

        XCTAssertTrue(app.staticTexts[kLocalizedEditObject].exists)
        XCTAssertTrue(app.buttons[kLocalizedCopy].exists)
        app.buttons[kLocalizedCopy].tap()

        XCTAssertTrue(waitForElementToAppear(app.tables.staticTexts[copiedObjectName]).exists)

        app.navigationBars.buttons[projectName].tap()
        app.navigationBars.buttons[kLocalizedPocketCode].tap()
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()

        app.staticTexts[projectName].tap()
        app.staticTexts["\(kLocalizedScene) 1"].tap()
        waitForElementToAppear(app.tables.staticTexts[copiedObjectName]).tap()

        app.staticTexts[kLocalizedScripts].tap()
        XCTAssertEqual(3, app.collectionViews.cells.count)
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTextBeginsWith(kLocalizedIfBeginSecondPart, ignoreLeadingWhiteSpace: true).exists)
        XCTAssert(app.collectionViews.cells.element(boundBy: 2).staticTexts[kLocalizedEndIf].exists)
    }
}
