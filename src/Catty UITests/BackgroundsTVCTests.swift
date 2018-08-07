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
        
        testScriptsCanEnterScripts()
        
        app.navigationBars.buttons["Delete"].tap()
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Delete"].tap()
        
        let yesButton = app.alerts["Delete these Bricks?"].buttons["Yes"]
        yesButton.tap()
        
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).exists == false)
    }
    
    func testScriptsCanDeleteWhenProgramStartsViaTap(){
        
        let app = XCUIApplication()
        
        testScriptsCanEnterScripts()
        
        app.collectionViews.cells.element(boundBy: 0).tap()
        app.buttons["Delete Script"].tap()
        
        let yesButton = app.alerts["Delete this Script?"].buttons["Yes"]
        yesButton.tap()
        
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).exists == false)
    }
    
    //TODO: Tests for Bricks with Textfields in the middle

    /*func testScriptCanAddScriptWhenProgramStarted(){
        
        let app = XCUIApplication()
        
        testScriptsCanEnterScripts()
        
        app.toolbars.buttons["Add"].tap()
        app.collectionViews.cells.element(boundBy: 0).tap()
        
        app.collectionViews.cells.element(boundBy: 0).tap()
        
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts["When program started"].exists)
    }*/
    
    func testBackgroundsCanEnterBackgrounds(){
        
        let app = XCUIApplication()
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Backgrounds"].tap()
        
        XCTAssert(app.navigationBars["Backgrounds"].exists)
        
    }
    
    func testBackgroundCanAddBackgroundViaMediaLibrary(){
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        
        testBackgroundsCanEnterBackgrounds()
        
        toolbarsQuery.buttons["Add"].tap()
        app.buttons["Media Library"].tap()
        
        XCTAssert(app.navigationBars["Media Library"].exists)
        
        app.collectionViews.cells.element(boundBy: 0).tap()
        
        XCTAssert(app.tables.staticTexts["Cornfield"].exists)
    }
    
    func testBackgroundsCanCopyAndDeleteSingelBackgroundViaEditMode(){
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        
        testBackgroundsCanEnterBackgrounds()
        
        //copy background
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        app.tables.staticTexts["Background"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssert(app.tables.staticTexts["Background"].exists)
        XCTAssert(app.tables.staticTexts["Background (1)"].exists)
        
        //delete background
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Delete Backgrounds"].tap()
        app.tables.staticTexts["Background"].tap()
        
        toolbarsQuery.buttons["Delete"].tap()
        
        XCTAssert(app.tables.staticTexts["Background (1)"].exists)
    }
    
    func testBackgroundsCanDeleteAllBackgroundsViaEditMode() {
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        
        testBackgroundsCanEnterBackgrounds()
        
        //copy background
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        app.tables.staticTexts["Background"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssert(app.tables.staticTexts["Background"].exists)
        XCTAssert(app.tables.staticTexts["Background (1)"].exists)
        
        //copy all backgrounds
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssert(app.tables.staticTexts["Background"].exists)
        XCTAssert(app.tables.staticTexts["Background (1)"].exists)
        XCTAssert(app.tables.staticTexts["Background (2)"].exists)
        XCTAssert(app.tables.staticTexts["Background (3)"].exists)
        
        //delete all backgrounds
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Delete Backgrounds"].tap()
        
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Delete"].tap()
        
        XCTAssertEqual(app.tables.staticTexts.count, 0)
    }
    func testBackgroundsCanAbortDeleteAllBackgroundsViaEditMode() {
        
        let app = XCUIApplication()
        let toolbarsQuery = app.toolbars
        
        testBackgroundsCanEnterBackgrounds()
        
        //copy background
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        app.tables.staticTexts["Background"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssert(app.tables.staticTexts["Background"].exists)
        XCTAssert(app.tables.staticTexts["Background (1)"].exists)
        
        //copy all backgrounds
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Copy Looks"].tap()
        toolbarsQuery.buttons["Select All"].tap()
        toolbarsQuery.buttons["Copy"].tap()
        XCTAssert(app.tables.staticTexts["Background"].exists)
        XCTAssert(app.tables.staticTexts["Background (1)"].exists)
        XCTAssert(app.tables.staticTexts["Background (2)"].exists)
        XCTAssert(app.tables.staticTexts["Background (3)"].exists)
        
        //delete all backgrounds
        app.navigationBars["Backgrounds"].buttons["Edit"].tap()
        app.buttons["Delete Backgrounds"].tap()
        
        toolbarsQuery.buttons["Select All"].tap()
        app.navigationBars.buttons["Cancel"].tap()
        
        XCTAssert(app.tables.staticTexts["Background"].exists)
        XCTAssert(app.tables.staticTexts["Background (1)"].exists)
        XCTAssert(app.tables.staticTexts["Background (2)"].exists)
        XCTAssert(app.tables.staticTexts["Background (3)"].exists)
    }
    
    
    func testBackgroundsCanDeleteSingleBackgroundViaSwipe() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        testBackgroundsCanEnterBackgrounds()
        
        tablesQuery.staticTexts["Background"].swipeLeft()
        
        XCTAssert(app.buttons["Delete"].exists)
        
        app.buttons["Delete"].tap()
        let yesButton = app.alerts["Delete this background"].buttons["Yes"]
        yesButton.tap()
        XCTAssert(app.tables.staticTexts["Background"].exists == false)
    }
    
    func testBackgroundsCanAbortDeleteSingleBackgroundViaSwipe() {
        
        let app = XCUIApplication()
        let tablesQuery = app.tables
        
        testBackgroundsCanEnterBackgrounds()
        
        tablesQuery.staticTexts["Background"].swipeLeft()
        
        XCTAssert(app.buttons["Delete"].exists)
        
        app.buttons["Delete"].tap()
        let yesButton = app.alerts["Delete this background"].buttons["Cancel"]
        yesButton.tap()
        XCTAssert(app.tables.staticTexts["Background"].exists)
    }
    
    func testBackgroundsCanShowAndHideDetailsForBackgroundViaEditMode(){
        
        let app = XCUIApplication()
        testBackgroundsCanEnterBackgrounds()
        
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
    
    func testSoundsCanEnterSounds(){
        
        let app = XCUIApplication()
        
        app.tables.staticTexts["Programs"].tap()
        app.tables.staticTexts["My first program"].tap()
        app.tables.staticTexts["Background"].tap()
        app.tables.staticTexts["Sounds"].tap()
        
        XCTAssert(app.navigationBars["Sounds"].exists)
    }
    
    /*func testSoundsCanAddSoundViaMediaLibrary(){
        
        let app = XCUIApplication()
        testSoundsCanEnterSounds()
        
        app.toolbars.buttons["Add"].tap()
        app.buttons["Media Library"].tap()
        
        XCTAssert(app.tables.staticTexts["Bird"].exists)
    }*/
}
