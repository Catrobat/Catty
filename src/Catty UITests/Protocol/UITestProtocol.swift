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
    
    func addLooksToCurrentProgramsBackgroundFromCatrobatTVAndStayAtSoundTV(numLooks: UInt) {
        
        // delete all existing looks...
        let app = XCUIApplication()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Continue"].tap()
        tablesQuery.staticTexts["Background"].tap()
        tablesQuery.staticTexts["Backgrounds"].tap()
        
        let editButton = app.navigationBars["Looks"].buttons["Edit"]
        editButton.tap()
        app.buttons["Delete Looks"].tap()
        
        let toolbarsQuery = app.toolbars
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Delete"].tap()
        
        // add new ones
        let addButton = app.toolbars.buttons["Add"]
        let drawNewImageButton = app.buttons["Draw new image"]
        let image = app.scrollViews.childrenMatchingType(.Other).element.childrenMatchingType(.Image).elementBoundByIndex(1)
        let looksButton = app.navigationBars["Pocket Paint"].buttons["Looks"]
        let yesButton = app.alerts["Save to PocketCode"].collectionViews.buttons["Yes"]
        let collectionViewsQuery = app.alerts["Add image"].collectionViews
        let enterYourImageNameHereTextField = collectionViewsQuery.textFields["Enter your image name here..."]
        let okButton = collectionViewsQuery.buttons["OK"]
        let clearTextButton = collectionViewsQuery.buttons["Clear text"]
        
        for i : UInt in 1...numLooks {
            addButton.tap()
            drawNewImageButton.tap()
            image.swipeRight()
            looksButton.tap()
            yesButton.tap()
            clearTextButton.tap()
            enterYourImageNameHereTextField.typeText("Image" + String(i))
            okButton.tap()
        }
    }
}
