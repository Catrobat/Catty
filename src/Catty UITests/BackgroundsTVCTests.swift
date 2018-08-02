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

class BackgroundsTVCTests: XCTestCase, UITestProtocol {
    
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
    
    
    func testBackgroundsCanCopyAndDeleteSingelBackgroundViaEditMode(){
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Backgrounds"].tap()
        
        //copy background
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        app.tables.staticTexts["Background"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssertEqual(app.tables.staticTexts.count, 2)
        
        //delete background
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Delete Backgrounds"].tap()
        app.tables.staticTexts["Background"].tap()
        
        toolbarsQuery.buttons["Delete"].tap()
        
        XCTAssertEqual(app.tables.staticTexts.count, 1)
    }
    
    func testBackgroundsCanDeleteAllBackgroundsViaEditMode() {
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Backgrounds"].tap()
        
        //copy background
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        app.tables.staticTexts["Background"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssertEqual(app.tables.staticTexts.count, 2)
        
        //copy all backgrounds
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssertEqual(app.tables.staticTexts.count, 4)
        
        //delete all backgrounds
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Delete Backgrounds"].tap()
        
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Delete"].tap()
        
        XCTAssertEqual(app.tables.staticTexts.count, 0)
    }
    func testBackgroundsCanAbortDeleteAllBackgroundsViaEditMode() {
        
        restoreDefaultProgram()
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Backgrounds"].tap()
        
        //copy background
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        app.tables.staticTexts["Background"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssertEqual(app.tables.staticTexts.count, 2)
        
        //copy all backgrounds
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssertEqual(app.tables.staticTexts.count, 4)
        
        //delete all backgrounds
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Delete Backgrounds"].tap()
        
        toolbarsQuery.buttons["Select All"].tap()
        app.navigationBars.buttons["Cancel"].tap()
        
        XCTAssertEqual(app.tables.staticTexts.count, 4)
    }
    
    
    func testBackgroundsCanDeleteSingleBackgroundViaSwipe() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Backgrounds"].tap()
        tablesQuery.staticTexts["Background"].swipeLeft()
        
        XCTAssert(app.buttons["Delete"].exists)
        
        app.buttons["Delete"].tap()
        let yesButton = app.alerts["Delete this background"].buttons["Yes"]
        yesButton.tap()
        XCTAssert(app.tables.staticTexts["Background"].exists == false)
    }
    
    func testBackgroundsCanAbortDeleteSingleBackgroundBySwiping() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Backgrounds"].tap()
        tablesQuery.staticTexts["Background"].swipeLeft()
        
        XCTAssert(app.buttons["Delete"].exists)
        
        app.buttons["Delete"].tap()
        let yesButton = app.alerts["Delete this background"].buttons["Cancel"]
        yesButton.tap()
        XCTAssert(app.tables.staticTexts["Background"].exists)
    }
    
    func testBackgroundsCanShowAndHideDetailsForBackgroundViaEditMode(){
        
        restoreDefaultProgram()
        
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        app.tables.staticTexts["My first program"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Backgrounds"].tap()
        
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        
        XCTAssert(app.buttons["Show Details"].exists)
        app.buttons["Show Details"].tap()
        
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        XCTAssert(app.buttons["Hide Details"].exists)
        app.buttons["Hide Details"].tap()
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        
        XCTAssert(app.buttons["Show Details"].exists)
        app.buttons["Cancel"].tap()
        
        XCTAssert(app.navigationBars["Backgrounds"].exists)
    }
    
    func testScriptsCanEnterScripts(){
        
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        app.tables.staticTexts["My first program"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Scripts"].tap()
        
        XCTAssert(app.navigationBars["Scripts"].exists)
    }
    
    func testScriptsCanDeleteAllScriptsViaDelete(){
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        
        testScriptCanEnterScripts()
        
        app.navigationBars.buttons["Delete"].tap()
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Delete"].tap()
        
        let yesButton = app.alerts["Delete these Bricks?"].buttons["Yes"]
        yesButton.tap()
        
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).exists == false)
    }
    
    /*func testScriptCanDeleteSingleScriptViaDelete(){
        
    }*/
}
