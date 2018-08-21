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

class PocketCodeMainScreenTVCTests: XCTestCase, UITestProtocol {
    
    override func setUp() {
        XCUIApplication().terminate()
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
    
    func testContinue() {
        
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        restoreDefaultProgram()
        
        let app = XCUIApplication()
        app.tables.staticTexts["Continue"].tap()
        
        XCTAssert(app.navigationBars["My first program"].exists)
    }
    
    func testNew() {
        
        let app = XCUIApplication()
        
        app.tables.staticTexts["New"].tap()
        app.textFields["Enter your program name here..."].tap()
        app.textFields["Enter your program name here..."].typeText("testProgram")
        app.alerts["New Program"].buttons["OK"].tap()
        
        // check if worked to create new Program
        //XCTAssert(app.navigationBars["testProgram"].exists)
        
        // go back and try to add program with same name
        app.navigationBars["testProgram"].buttons["Pocket Code"].tap()
        
        app.tables.staticTexts["New"].tap()
        app.textFields["Enter your program name here..."].tap()
        app.textFields["Enter your program name here..."].typeText("testProgram")
        app.alerts["New Program"].buttons["OK"].tap()
        
        // check if error message is displayed
        XCTAssert(app.alerts["Pocket Code"].staticTexts["A program with the same name already exists, try again."].exists)
        app.alerts["Pocket Code"].buttons["OK"].tap()
        app.alerts["New Program"].buttons["Cancel"].tap()
        
        // check if gone back to initial screen after pressing cancel button
        XCTAssert(app.tables.staticTexts["New"].exists)
    }
    
    func testNewInvalidNames() {
        
        let progNamesErrorMsgMap = ["":"No input. Please enter at least 1 character.",
                                    "i am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooogi am tooooooo looooog": "The input is too long. Please enter maximal 250 character(s).",
                                    ".":"Only special characters are not allowed. Please enter at least 1 other character.",
                                    "/":"Only special characters are not allowed. Please enter at least 1 other character.",
                                    "./":"Only special characters are not allowed. Please enter at least 1 other character.",
                                    "~":"Only special characters are not allowed. Please enter at least 1 other character.",
                                    "\\":"Only special characters are not allowed. Please enter at least 1 other character.",
                                    "~/":"Only special characters are not allowed. Please enter at least 1 other character."]
        
        let app = XCUIApplication()
        
        for (programName, _) in progNamesErrorMsgMap {
            app.tables.staticTexts["New"].tap()
            let alertQuery = app.alerts["New Program"]
            alertQuery.textFields["Enter your program name here..."].tap()
            alertQuery.textFields["Enter your program name here..."].typeText(programName)
            alertQuery.buttons["OK"].tap()
            
            XCTAssert(app.alerts["Pocket Code"].exists)
            app.alerts["Pocket Code"].buttons["OK"].tap()
            alertQuery.buttons["Cancel"].tap()
        }
    }
    
    func testNewCanceled() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()
        
        let alertQuery = app.alerts["New Program"]
        alertQuery.textFields["Enter your program name here..."].typeText("testprogramToCancel")
        alertQuery.buttons["Cancel"].tap()
        
        XCTAssertTrue(app.navigationBars["Pocket Code"].exists)
    }
    
    func testPrograms() {
        
        let programNames = ["testProgram1", "testProgram2", "testProgram3"]
        
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        
        XCTAssert(app.navigationBars["Programs"].exists)
        
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        
        let tablesQuery = app.tables
        let newStaticText = tablesQuery.staticTexts["New"]
        let alertQuery = app.alerts["New Program"]
        let enterYourProgramNameHereTextField = alertQuery.textFields["Enter your program name here..."]
        let okButton = alertQuery.buttons["OK"]
        
        for i in 0...2 {
            newStaticText.tap()
            enterYourProgramNameHereTextField.typeText(programNames[i])
            okButton.tap()
            app.navigationBars[programNames[i]].buttons["Pocket Code"].tap()
        }
        
        tablesQuery.staticTexts["Programs"].tap()
        
        for programName in programNames {
            XCTAssert(app.tables.staticTexts[programName].exists)
        }
    }
    
    func testHelp() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["Help"].tap()
        
        XCTAssert(app.navigationBars["Help"].exists)
    }
    
    func testExplore() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["Explore"].tap()
        
        XCTAssert(app.navigationBars["Explore"].exists)
    }
    
    func testUpload() {
        
        let app = XCUIApplication()
        app.tables.staticTexts["Upload"].tap()
        
        XCTAssert(app.navigationBars["Login"].exists)
    }
    
    func testDebugMode(){
        
        let app = XCUIApplication()
        app.navigationBars.buttons["Debug mode"].tap()
        
        let alertQuery = app.alerts["Debug mode"]
        alertQuery.buttons["OK"].tap()
        
        XCTAssert(app.navigationBars["Pocket Code"].exists)
    }
    
    func testSettings(){
        
        let app = XCUIApplication()
        app.navigationBars.buttons["Item"].tap()
        
        app.switches["Download only with WiFi"].tap()
        app.switches["Download only with WiFi"].tap()
        
        app.switches["Use Arduino bricks"].tap()
        app.navigationBars.buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()
        app.tables.staticTexts["My first program"].tap()
        app.tables.staticTexts["Mole 1"].tap()
        app.tables.staticTexts["Scripts"].tap()
        app.toolbars.buttons["Add"].tap()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        app.swipeLeft()
        XCTAssert(app.collectionViews.cells.element(boundBy: 0).staticTexts["Set Arduino digital pin"].exists)
        app.navigationBars.buttons["Cancel"].tap()
        app.navigationBars.buttons["Mole 1"].tap()
        app.navigationBars.buttons["My first program"].tap()
        app.navigationBars.buttons["Programs"].tap()
        app.navigationBars.buttons["Pocket Code"].tap()
        app.navigationBars.buttons["Item"].tap()
        app.switches["Use Arduino bricks"].tap()
        XCTAssert(app.navigationBars["Settings"].exists)
        
        app.staticTexts["About Pocket Code"].tap()
        XCTAssert(app.navigationBars["About Pocket Code"].exists)
        app.navigationBars.buttons["Settings"].tap()
        
        app.staticTexts["Terms of Use and Services"].tap()
        XCTAssert(app.navigationBars["Terms of Use and Services"].exists)
        app.navigationBars.buttons["Settings"].tap()
        XCTAssert(app.navigationBars["Settings"].exists)
    }
}
