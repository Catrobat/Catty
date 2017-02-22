/**
 *  Copyright (C) 2010-2017 The Catrobat Team
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

class ProgramTVCTests: XCTestCase, UITestProtocol {

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        dismissWelcomeScreenIfShown()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testCanDeleteMultipleProgramsViaEditMode() {
        restoreDefaultProgram()
        
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        app.tables.staticTexts["My first program"].tap()
        app.navigationBars["My first program"].buttons["Edit"].tap()
        app.buttons["Delete Objects"].tap()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Mole 1"].tap()
        tablesQuery.staticTexts["Mole 2"].tap()
        app.toolbars.buttons["Delete"].tap()
        XCTAssert(app.tables.staticTexts.count == 3)
        XCTAssert(app.tables.staticTexts["Background"].exists)
        XCTAssert(app.tables.staticTexts["Mole 1"].exists == false)
        XCTAssert(app.tables.staticTexts["Mole 2"].exists == false)
        XCTAssert(app.tables.staticTexts["Mole 3"].exists)
        XCTAssert(app.tables.staticTexts["Mole 4"].exists)
    }

    func testCanAbortDeleteSingleProgramViaSwipe() {
        restoreDefaultProgram()
        
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        app.tables.staticTexts["My first program"].tap()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Mole 3"].swipeLeft()
        XCTAssert(app.buttons["Delete"].exists)

        app.buttons["Delete"].tap()
        let yesButton = app.alerts["Delete this object"].buttons["No"]
        yesButton.tap()
        XCTAssert(app.tables.staticTexts["Mole 3"].exists)
    }

    func testCanRenameSingleProgramViaSwipe() {
        restoreDefaultProgram()
        
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        app.tables.staticTexts["My first program"].tap()
        let tablesQuery = app.tables
        tablesQuery.staticTexts["Mole 3"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        app.buttons["Rename"].tap()
        let alertQuery = app.alerts["Rename object"]
        alertQuery.buttons["Clear text"].tap()
        alertQuery.textFields["Enter your object name here..."].typeText("Mole 5")
        alertQuery.buttons["OK"].tap()
        XCTAssert(app.tables.staticTexts["Mole 5"].exists)
        
        
    }

}
