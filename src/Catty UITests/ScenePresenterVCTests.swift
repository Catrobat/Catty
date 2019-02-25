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

class ScenePresenterVCTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()

        continueAfterFailure = false
        XCUIApplication().launch()

        dismissWelcomeScreenIfShown()
        restoreDefaultProject()
    }

    override func tearDown() {
        XCUIDevice.shared.orientation = .portrait
        super.tearDown()
    }

    func testScenePresenterOrientation() {
        let app = XCUIApplication()
        let projectName = "testProject"

        //Create new Project
        app.tables.staticTexts["New"].tap()
        let alertQuery = app.alerts["New Project"]
        alertQuery.textFields["Enter your project name here..."].typeText(projectName)
        app.alerts["New Project"].buttons["OK"].tap()
        XCTAssertNotNil(waitForElementToAppear(app.navigationBars[projectName]))

        //Change orientation to landscape
        XCUIDevice.shared.orientation = .landscapeLeft

        //Start scence and check the orientation
        app.toolbars.buttons["Play"].tap()
        XCTAssertTrue(UIApplication.shared.statusBarOrientation == .portrait)
    }
}
