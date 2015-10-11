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

@testable import Pocket_Code

class CatrobatTVCTests: XCTestCase, UITestProtocol {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
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
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let programName = "testProgram"
        
        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()
        
        let collectionViewsQuery = app.alerts["New Program"].collectionViews
        collectionViewsQuery.textFields["Enter your program name here..."].typeText(programName)
        collectionViewsQuery.buttons["OK"].tap()
        
        // check if worked to create new Program
        XCTAssert(app.navigationBars[programName].staticTexts[programName].exists)
        
        // go back and try to add program with same name
        app.navigationBars[programName].buttons["Pocket Code"].tap()
        app.tables.staticTexts["New"].tap()
        
        collectionViewsQuery.textFields["Enter your program name here..."].typeText(programName)
        collectionViewsQuery.buttons["OK"].tap()
        // check if error message is displayed
        XCTAssert(app.alerts["Pocket Code"].staticTexts["A program with the same name already exists, try again."].exists)
        app.alerts["Pocket Code"].collectionViews.buttons["OK"].tap()
        collectionViewsQuery.buttons["Cancel"].tap()
        
        // check if gone back to initial screen after pressing cancel button
        XCTAssert(app.tables.staticTexts["New"].exists)
    }
    
    func testPrograms() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        restoreDefaultProgram()
        
        let programNames = ["testProgram1", "testProgram2", "testProgram3"]
        
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        
        XCTAssert(app.navigationBars["Programs"].staticTexts["Programs"].exists)

        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        
        let tablesQuery = app.tables
        let newStaticText = tablesQuery.staticTexts["New"]
        let collectionViewsQuery = app.alerts["New Program"].collectionViews
        let enterYourProgramNameHereTextField = collectionViewsQuery.textFields["Enter your program name here..."]
        let okButton = collectionViewsQuery.buttons["OK"]
        
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
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.tables.staticTexts["Help"].tap()
        
        XCTAssert(app.navigationBars["Help"].exists)
    }
    
    func testExplore() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.tables.staticTexts["Explore"].tap()
        
        XCTAssert(app.navigationBars["Explore"].exists)
    }
    
    func testUpload() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        let app = XCUIApplication()
        app.tables.staticTexts["Upload"].tap()
        
        XCTAssert(app.navigationBars["Login"].exists)
    }
}
