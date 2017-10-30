/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

class LooksTVCTests: XCTestCase, UITestProtocol {
    
    struct constants {
        static let numLooks : UInt = 5
    }
    
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
        dismissWelcomeScreenIfShown()
        
        restoreDefaultProgram()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testDeleteAllLooksFromBackground() {

        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars

        addLooksToCurrentProgramsBackgroundFromCatrobatTVAndStayAtLooksTV(constants.numLooks)
        XCTAssertEqual(app.tables.staticTexts.count, constants.numLooks)

        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Delete Looks"].tap()

        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Delete"].tap()

        XCTAssertEqual(app.tables.staticTexts.count, 0)
    }

    func testDeleteAllLooksFromBackgroundSequentiallyBySwiping() {

        let app = XCUIApplication()
        let tablesQuery = app.tables

        addLooksToCurrentProgramsBackgroundFromCatrobatTVAndStayAtLooksTV(constants.numLooks)
        XCTAssertEqual(app.tables.staticTexts.count, constants.numLooks)

        for i : UInt in 1...constants.numLooks {
            let name = "Image" + String(i)
            tablesQuery.staticTexts[name].swipeLeft()
            tablesQuery.buttons["Delete"].tap()
            app.alerts["Delete this look"].buttons["Yes"].tap()
            XCTAssertEqual(app.tables.staticTexts.count, (constants.numLooks-i))
        }
    }

    func testRenameAllLooksFromBackground() {

        let app = XCUIApplication()
        let tablesQuery = app.tables
        let alertQuery = app.alerts["Rename image"]
        let clearTextButton = alertQuery.buttons["Clear text"]

        addLooksToCurrentProgramsBackgroundFromCatrobatTVAndStayAtLooksTV(constants.numLooks)
        XCTAssertEqual(app.tables.staticTexts.count, constants.numLooks)

        for i : UInt in 1...constants.numLooks {
            let old_name = "Image" + String(i)
            let new_name = "Renamed" + String(i)
            
            XCTAssertTrue(tablesQuery.staticTexts[old_name].exists)
            XCTAssertFalse(tablesQuery.staticTexts[new_name].exists)
            
            tablesQuery.staticTexts[old_name].swipeLeft()
            tablesQuery.buttons["More"].tap()
            app.buttons["Rename"].tap()
            clearTextButton.tap()
            alertQuery.textFields["Enter your image name here..."].typeText(new_name)
            alertQuery.buttons["OK"].tap()
            
            XCTAssertFalse(tablesQuery.staticTexts[old_name].exists)
            XCTAssertTrue(tablesQuery.staticTexts[new_name].exists)
        }
    }
    
    func testToggleBetweenShowAndHideDetails() {
        
        let app = XCUIApplication()
        addLooksToCurrentProgramsBackgroundFromCatrobatTVAndStayAtLooksTV(constants.numLooks)
        
        let soundsNavigationBar = app.navigationBars["Backgrounds"]
        let editButton = soundsNavigationBar.buttons["Edit"]
        let showDetailsButton = app.buttons["Show Details"]
        let hideDetailsButton = app.buttons["Hide Details"]
        
        editButton.tap()
        
        if(!showDetailsButton.exists) {
            hideDetailsButton.tap()
            editButton.tap()
        }
        
        XCTAssertTrue(showDetailsButton.exists)
        XCTAssertFalse(hideDetailsButton.exists)
        showDetailsButton.tap()
        
        let tablesQuery = app.tables
        
        for i : UInt in 1...constants.numLooks {
            let name = "Image" + String(i)
            let cell = tablesQuery.containingType(.StaticText, identifier: name)
            XCTAssertTrue(cell.staticTexts["Measure:"].exists)
            XCTAssertTrue(cell.staticTexts["Size:"].exists)
        }
        
        editButton.tap()
        XCTAssertTrue(hideDetailsButton.exists)
        XCTAssertFalse(showDetailsButton.exists)
        hideDetailsButton.tap()
        
        
        for i : UInt in 1...constants.numLooks {
            let name = "Image" + String(i)
            let cell = tablesQuery.containingType(.StaticText, identifier: name)
            XCTAssertFalse(cell.staticTexts["Measure:"].exists)
            XCTAssertFalse(cell.staticTexts["Size:"].exists)
        }
    }
}
