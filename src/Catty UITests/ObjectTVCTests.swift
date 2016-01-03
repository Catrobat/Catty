/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
    
    func testScriptsViaBackground() {
    
        let app = XCUIApplication()
        let testElement = "Scripts"
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        
        app.tables.staticTexts[testElement].tap()
        XCTAssert(app.navigationBars[testElement].staticTexts[testElement].exists)
    }
    
    func testScriptsViaObjectsOfMyFirstProgram() {
    
        let app = XCUIApplication()
        let appTables = app.tables
        
        let testElement = "Scripts"
        
        let programObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]
        
        appTables.staticTexts["Continue"].tap()
        for object in programObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts[testElement].tap()
            XCTAssert(app.navigationBars[testElement].staticTexts[testElement].exists)
            app.navigationBars[testElement].buttons[object].tap()
            app.navigationBars[object].buttons["My first program"].tap()
            XCTAssert(app.navigationBars["My first program"].staticTexts["My first program"].exists)
        }
    }
    
    func testBackgroundsViaBackground() {
        
        let app = XCUIApplication()
        let testElement = "Backgrounds"
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        
        app.tables.staticTexts[testElement].tap()
        XCTAssert(app.navigationBars["Looks"].staticTexts["Looks"].exists) // Should be Backgrounds as we came here via "Backgrounds"
    }
    
    func testLooksViaObjectsOfMyFirstProgram() {
        
        let app = XCUIApplication()
        let appTables = app.tables
        
        let testElement = "Looks"
        
        let programObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]
        
        appTables.staticTexts["Continue"].tap()
        for object in programObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts[testElement].tap()
            XCTAssert(app.navigationBars[testElement].staticTexts[testElement].exists)
            app.navigationBars[testElement].buttons[object].tap()
            app.navigationBars[object].buttons["My first program"].tap()
            XCTAssert(app.navigationBars["My first program"].staticTexts["My first program"].exists)
        }
    }
    
    func testSoundsViaBackground() {
        
        let app = XCUIApplication()
        let testElement = "Sounds"
        
        app.tables.staticTexts["Continue"].tap()
        app.tables.staticTexts["Background"].tap()
        
        app.tables.staticTexts[testElement].tap()
        XCTAssert(app.navigationBars[testElement].staticTexts[testElement].exists)
    }
    
    func testSoundsViaObjectsOfMyFirstProgram() {
               
        let app = XCUIApplication()
        let appTables = app.tables
        
        let testElement = "Sounds"
        
        let programObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]
        
        appTables.staticTexts["Continue"].tap()
        for object in programObjects {
            appTables.staticTexts[object].tap()
            appTables.staticTexts[testElement].tap()
            XCTAssert(app.navigationBars[testElement].staticTexts[testElement].exists)
            app.navigationBars[testElement].buttons[object].tap()
            app.navigationBars[object].buttons["My first program"].tap()
            XCTAssert(app.navigationBars["My first program"].staticTexts["My first program"].exists)
        }
    }
}
