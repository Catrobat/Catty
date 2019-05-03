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

class CattyUISnapshots: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        continueAfterFailure = false
        setupSnapshot(app)
        app.launch()
    }

    func testExample() {
        if app.buttons["Dismiss"].exists {
            app.buttons["Dismiss"].tap()
        }
        snapshot("0Launch")
        app.cells.element(boundBy: 0).tap()
        app.cells.element(boundBy: 2).tap()
        app.cells.element(boundBy: 0).tap()
        snapshot("1Scripts")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.cells.element(boundBy: 1).tap()
        app.cells.element(boundBy: 0).tap()
        snapshot("4Paint")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.toolbars.buttons.element(boundBy: 0).tap()
        app.buttons.element(boundBy: 6).tap()
        sleep(5)
        snapshot("3MediaLibrary")
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.cells.element(boundBy: 4).tap()
        app.tabBars.buttons.element(boundBy: 1).tap()
        sleep(5)
        snapshot("2Explore")
    }
}
