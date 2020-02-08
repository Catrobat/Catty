/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class ProjectTVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchAppWithDefaultProject()
    }

    func testCreateObjectWithMaxLength() {
        let projectName = "projectName"
        let objectName = String(repeating: "a", count: 250)

        createProject(name: projectName, in: app)
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))
        XCTAssertEqual(1, app.tables.cells.count)

        addObjectAndDrawNewImage(name: objectName, in: app)
        XCTAssertEqual(2, app.tables.cells.count)
    }

    func testCreateObjectWithMaxLengthPlusOne() {
        let projectName = "projectName"
        let objectName = String(repeating: "a", count: 250 + 1)

        //Create new Project
        app.tables.staticTexts[kLocalizedNewProject].tap()
        let alertQuery = app.alerts[kLocalizedNewProject]
        alertQuery.textFields[kLocalizedEnterYourProjectNameHere].typeText(projectName)
        app.alerts[kLocalizedNewProject].buttons[kLocalizedOK].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        //Add new Object
        app.toolbars.buttons[kLocalizedUserListAdd].tap()
        app.alerts[kLocalizedAddObject].textFields[kLocalizedEnterYourObjectNameHere].typeText(objectName)
        app.alerts[kLocalizedAddObject].buttons[kLocalizedOK].tap()

        XCTAssert(waitForElementToAppear(app.alerts[kLocalizedPocketCode]).exists)
    }
}
