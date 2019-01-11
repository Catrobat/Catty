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

class ProjectTVCTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    func testCreateObjectWithMaxLength() {
        let app = XCUIApplication()
        let projectName = "projectName"
        let objectName = String(repeating: "a", count: 250)

        //Create new Project
        app.tables.staticTexts["New"].tap()
        let alertQuery = app.alerts["New Project"]
        alertQuery.textFields["Enter your project name here..."].typeText(projectName)
        app.alerts["New Project"].buttons["OK"].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        //Add new Object
        app.toolbars.buttons["Add"].tap()
        app.alerts["Add object"].textFields["Enter your object name here..."].typeText(objectName)
        app.alerts["Add object"].buttons["OK"].tap()

        XCTAssertNotNil(waitForElementToAppear(app.buttons["Draw new image"]).tap())
    }

    func testCreateObjectWithMaxLengthPlusOne() {
        let app = XCUIApplication()
        let projectName = "projectName"
        let objectName = String(repeating: "a", count: 250 + 1)

        //Create new Project
        app.tables.staticTexts["New"].tap()
        let alertQuery = app.alerts["New Project"]
        alertQuery.textFields["Enter your project name here..."].typeText(projectName)
        app.alerts["New Project"].buttons["OK"].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        //Add new Object
        app.toolbars.buttons["Add"].tap()
        app.alerts["Add object"].textFields["Enter your object name here..."].typeText(objectName)
        app.alerts["Add object"].buttons["OK"].tap()

        XCTAssert(app.alerts["Pocket Code"].exists)
    }
}
