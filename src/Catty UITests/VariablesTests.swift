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

class VariablesTest: XCTestCase, UITestProtocol {
    
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
    
    func testDontShowVariablePickerWhenNoVariablesDefinedForObject() {
        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()
        app.alerts["New Program"].textFields["Enter your program name here..."].typeText("Test Program")
        XCUIApplication().alerts["New Program"].buttons["OK"].tap()
        XCUIApplication().tables/*@START_MENU_TOKEN@*/.staticTexts["Background"]/*[[".cells.staticTexts[\"Background\"]",".staticTexts[\"Background\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Scripts"]/*[[".cells.staticTexts[\"Scripts\"]",".staticTexts[\"Scripts\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.toolbars["Toolbar"].buttons["Add"].tap()
        let collectionViewsQuery = app.collectionViews
        let cell = collectionViewsQuery.children(matching: .cell).element(boundBy: 4)
        cell.swipeLeft()
        cell.swipeLeft()
        cell.swipeLeft()
        cell.swipeLeft()
        cell.swipeLeft()
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier:"Set variable").children(matching: .other).element.tap()
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier:"Set variable").children(matching: .other).element.tap()
        XCTAssert(app.sheets["Variable type"].exists)
    }

    func testDontShowVListPickerWhenNoListsDefinedForObject() {
        let app = XCUIApplication()
        app.tables.staticTexts["New"].tap()
        app.alerts["New Program"].textFields["Enter your program name here..."].typeText("Test Program")
        XCUIApplication().alerts["New Program"].buttons["OK"].tap()
        XCUIApplication().tables/*@START_MENU_TOKEN@*/.staticTexts["Background"]/*[[".cells.staticTexts[\"Background\"]",".staticTexts[\"Background\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.tables/*@START_MENU_TOKEN@*/.staticTexts["Scripts"]/*[[".cells.staticTexts[\"Scripts\"]",".staticTexts[\"Scripts\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        app.toolbars["Toolbar"].buttons["Add"].tap()
        let collectionViewsQuery = app.collectionViews
        let cell = collectionViewsQuery.children(matching: .cell).element(boundBy: 4)
        cell.swipeLeft()
        cell.swipeLeft()
        cell.swipeLeft()
        cell.swipeLeft()
        cell.swipeLeft()
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier:"Add ").children(matching: .other).element.tap()
        collectionViewsQuery.cells.otherElements.containing(.staticText, identifier:"Add ").children(matching: .other).element.tap()
        XCTAssert(app.sheets["List type"].exists)
    }
}
