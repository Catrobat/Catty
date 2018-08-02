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

class ObjectTVCTests: XCTestCase, UITestProtocol {
    
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
    
    func testScriptsCanEnterScriptsOfAllMoles() {
    
        let app = XCUIApplication()
        let appTables = app.tables
        let programObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]
        
        appTables.staticTexts["Continue"].tap()
        
        //check every mole for script
        for object in programObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts["Scripts"].tap()
            XCTAssert(app.navigationBars["Scripts"].buttons[object].exists)
            app.navigationBars["Scripts"].buttons[object].tap()
            app.navigationBars[object].buttons["My first program"].tap()
            XCTAssert(app.navigationBars["My first program"].exists)
        }
    }
    
    func testScriptsCanDeleteBrickSetSizeTo() {
        
        let app = XCUIApplication()
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        
        //delete the SetSizeTo brick
        app.collectionViews.cells.element(boundBy: 1).tap()
        app.buttons["Delete Brick"].tap()
        
        //Check if Forever brick is now where SetSizeTo was before
        app.navigationBars["Scripts"].buttons["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 1).staticTexts["Forever"].exists)
    }
    
    func testScriptsCanDeleteBrickLoop() {
        let app = XCUIApplication()
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        
        //delete the EndOfLoop
        app.collectionViews.cells.element(boundBy: 2).tap()
        app.buttons["Delete Loop"].tap()
        
        //Check if deleted successful
        app.navigationBars["Scripts"].buttons["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 4).staticTexts["Show"].exists)
    }
    
    func testScriptsCanCopyForeverBrick() {
        let app = XCUIApplication()
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        
        //copy the Forever brick
        app.collectionViews.cells.element(boundBy: 2).tap()
        app.buttons["Copy Brick"].tap()
        
        //Check if copied successfull
        app.navigationBars["Scripts"].buttons["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 3).staticTexts["End of Loop"].exists)
    }
    
    func testScriptsCanDeleteWhenProgramStartedBrick() {
        let app = XCUIApplication()
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        
        //delete the WhenProgramStartedBrick
        app.collectionViews.cells.element(boundBy: 0).tap()
        app.buttons["Delete Script"].tap()
        let yesButton = app.alerts["Delete this Script?"].buttons["Yes"]
        yesButton.tap()
        
        //Check if deltetd successful
        app.navigationBars["Scripts"].buttons["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts["When tapped"].exists)
    }
    
    func testLooksCanEnterSingleLook(){
        
        let app = XCUIApplication()
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Looks"].tap()
        
        XCTAssert(app.navigationBars["Looks"].exists)
    }
    
    func testLooksCanAddLookViaMediaLibrary(){
        
        let app = XCUIApplication()
        testLooksCanEnterSingleLook()
        
        app.toolbars.buttons["Add"].tap()
        app.buttons["Media Library"].tap()
        
        app.collectionViews.cells.element(boundBy: 0).tap()
        XCTAssert(app.tables.staticTexts["alien"].exists)
    }
    
    func testLooksCanEnterLooksOfAllMoles() {
        
        let app = XCUIApplication()
        let appTables = app.tables
        
        let testElement = "Looks"
        
        let programObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]
        
        appTables.staticTexts["Continue"].tap()
        
        for object in programObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts[testElement].tap()
            XCTAssert(app.navigationBars[testElement].buttons[object].exists)
            app.navigationBars[testElement].buttons[object].tap()
            app.navigationBars[object].buttons["My first program"].tap()
            XCTAssert(app.navigationBars["My first program"].buttons["Pocket Code"].exists)
        }
    }
    
    func testSoundsCanEnterSoundsOfAllMoles() {
               
        let app = XCUIApplication()
        let appTables = app.tables
        
        let testElement = "Sounds"
        
        let programObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]
        
        appTables.staticTexts["Continue"].tap()
        for object in programObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts[testElement].tap()
            XCTAssert(app.navigationBars[testElement].buttons[object].exists)
            app.navigationBars[testElement].buttons[object].tap()
            app.navigationBars[object].buttons["My first program"].tap()
            XCTAssert(app.navigationBars["My first program"].buttons["Pocket Code"].exists)
        }
    }
}
