/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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
}

extension UITestProtocol {

    func restoreDefaultProgram() {
        // Restore default program
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        app.navigationBars["Programs"].buttons["Edit"].tap()
        app.buttons["Delete Programs"].tap()
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Delete"].tap()
        XCTAssert(app.tables.staticTexts.count == 1)
        // finally go back to main menu, because this method is used by other tests
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
    }

}
