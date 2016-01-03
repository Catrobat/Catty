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

class MyProgramsVCTests: XCTestCase, UITestProtocol  {

    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        dismissWelcomeScreenIfShown()
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    // MARK: edit menu tests
    func testCanCancelEditActionSheetMenu() {
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        app.navigationBars["Programs"].buttons["Edit"].tap()
        XCTAssert(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()
        XCTAssert(!app.buttons["Cancel"].exists)
    }

    // deletes all programs i.e. only one single program is preserved
    // 'My first program' will be (re)created
    func testCanCreateMyFirstProgramAfterAllProgramsHaveBeenDeleted() {
        restoreDefaultProgram()
    }

    // MARK: slide menu tests
    func testCanCancelMoreActionSheetMenu() {
        restoreDefaultProgram()
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()
        
        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Cancel"].exists)
        app.buttons["Cancel"].tap()
        XCTAssert(!app.buttons["Cancel"].exists)
    }

    func testCanCopyMyFirstProgram() {
        restoreDefaultProgram()
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Copy"].exists)
        app.buttons["Copy"].tap()

        XCTAssert(app.alerts["Copy program"].exists)
        let collectionViewsQuery = app.alerts["Copy program"].collectionViews
        XCTAssert(collectionViewsQuery.buttons["Clear text"].exists)
        collectionViewsQuery.buttons["Clear text"].tap()
        collectionViewsQuery.textFields["Enter your program name here..."].typeText("My second program")
        XCTAssert(collectionViewsQuery.buttons["OK"].exists)
        collectionViewsQuery.buttons["OK"].tap()

        XCTAssert(app.tables.staticTexts.count == 2)
        XCTAssert(app.tables.staticTexts["My second program"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()

        XCTAssert(app.tables.staticTexts.count == 2)
        XCTAssert(app.tables.staticTexts["My second program"].exists)
    }

    func testCanCancelCopyMyFirstProgram() {
        restoreDefaultProgram()
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Copy"].exists)
        app.buttons["Copy"].tap()

        XCTAssert(app.alerts["Copy program"].exists)
        let collectionViewsQuery = app.alerts["Copy program"].collectionViews
        XCTAssert(collectionViewsQuery.buttons["Clear text"].exists)
        collectionViewsQuery.buttons["Clear text"].tap()
        collectionViewsQuery.textFields["Enter your program name here..."].typeText("My second program")
        XCTAssert(collectionViewsQuery.buttons["Cancel"].exists)
        collectionViewsQuery.buttons["Cancel"].tap()

        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My first program"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()

        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My first program"].exists)
    }

    func testCanRenameMyFirstProgram() {
        restoreDefaultProgram()
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Rename"].exists)
        app.buttons["Rename"].tap()

        XCTAssert(app.alerts["Rename Program"].exists)
        let collectionViewsQuery = app.alerts["Rename Program"].collectionViews
        XCTAssert(collectionViewsQuery.buttons["Clear text"].exists)
        collectionViewsQuery.buttons["Clear text"].tap()
        collectionViewsQuery.textFields["Enter your program name here..."].typeText("My renamed program")
        XCTAssert(collectionViewsQuery.buttons["OK"].exists)
        collectionViewsQuery.buttons["OK"].tap()

        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My renamed program"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()

        // check again
        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My renamed program"].exists)
    }

    func testCanCancelRenameMyFirstProgram() {
        restoreDefaultProgram()
        let app = XCUIApplication()
        app.tables.staticTexts["Programs"].tap()

        let tablesQuery = app.tables
        tablesQuery.staticTexts["My first program"].swipeLeft()
        XCTAssert(app.buttons["More"].exists)

        app.buttons["More"].tap()
        XCTAssert(app.buttons["Rename"].exists)
        app.buttons["Rename"].tap()

        XCTAssert(app.alerts["Rename Program"].exists)
        let collectionViewsQuery = app.alerts["Rename Program"].collectionViews
        XCTAssert(collectionViewsQuery.buttons["Clear text"].exists)
        collectionViewsQuery.buttons["Clear text"].tap()
        collectionViewsQuery.textFields["Enter your program name here..."].typeText("My renamed program")
        XCTAssert(collectionViewsQuery.buttons["Cancel"].exists)
        collectionViewsQuery.buttons["Cancel"].tap()

        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My first program"].exists)

        // go back and forth to force reload table view!!
        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
        app.tables.staticTexts["Programs"].tap()

        // check again
        XCTAssert(app.tables.staticTexts.count == 1)
        XCTAssert(app.tables.staticTexts["My first program"].exists)
    }

    // TODO: support for accesibility API
//    func testCanSetDescriptionOfMyFirstProgram() {
//        testCanCreateMyFirstProgramAfterAllProgramsHaveBeenDeleted()
//        let app = XCUIApplication()
//        app.tables.staticTexts["Programs"].tap()
//
//        let tablesQuery = app.tables
//        tablesQuery.staticTexts["My first program"].swipeLeft()
//        XCTAssert(app.buttons["More"].exists)
//
//        app.buttons["More"].tap()
//        XCTAssert(app.buttons["Description"].exists)
//        app.buttons["Description"].tap()
//
//        let descriptionText = "Yet another whack a mole program"
//        XCTAssert(app.alerts["Set description"].exists)
//        let collectionViewsQuery = app.alerts["Set description"].collectionViews
//        XCTAssert(!collectionViewsQuery.buttons["Clear text"].exists) // empty description is expected by default!
//        collectionViewsQuery.textFields["Enter your program description here..."].typeText(descriptionText)
//        XCTAssert(collectionViewsQuery.buttons["OK"].exists)
//        collectionViewsQuery.buttons["OK"].tap()
//
//        // go back and forth to force reload table view!!
//        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
//        app.tables.staticTexts["Programs"].tap()
//
//        tablesQuery.staticTexts["My first program"].swipeLeft()
//        XCTAssert(app.buttons["More"].exists)
//
//        app.buttons["More"].tap()
//        XCTAssert(app.buttons["Description"].exists)
//        app.buttons["Description"].tap()
//        XCTAssert(collectionViewsQuery.textFields[descriptionText].exists)
//    }
//
//    func testCanCancelSettingDescriptionOfMyFirstProgram() {
//        testCanCreateMyFirstProgramAfterAllProgramsHaveBeenDeleted()
//        let app = XCUIApplication()
//        app.tables.staticTexts["Programs"].tap()
//
//        let tablesQuery = app.tables
//        tablesQuery.staticTexts["My first program"].swipeLeft()
//        XCTAssert(app.buttons["More"].exists)
//
//        app.buttons["More"].tap()
//        XCTAssert(app.buttons["Description"].exists)
//        app.buttons["Description"].tap()
//
//        let descriptionText = "Yet another whack a mole program"
//        XCTAssert(app.alerts["Set description"].exists)
//        let collectionViewsQuery = app.alerts["Set description"].collectionViews
//        XCTAssert(!collectionViewsQuery.buttons["Clear text"].exists) // empty description is expected by default!
//        collectionViewsQuery.textFields["Enter your program description here..."].typeText(descriptionText)
//        XCTAssert(collectionViewsQuery.buttons["Cancel"].exists)
//        collectionViewsQuery.buttons["Cancel"].tap()
//
//        // go back and forth to force reload table view!!
//        app.navigationBars["Programs"].buttons["Pocket Code"].tap()
//        app.tables.staticTexts["Programs"].tap()
//
//        tablesQuery.staticTexts["My first program"].swipeLeft()
//        XCTAssert(app.buttons["More"].exists)
//
//        app.buttons["More"].tap()
//        XCTAssert(app.buttons["Description"].exists)
//        app.buttons["Description"].tap()
//        XCTAssert(!collectionViewsQuery.textFields[descriptionText].exists)
//    }

    /**
    TODO:
    * test create new program
    * test minimum + maximum number of characters for "create new program", "copy program", "rename program", "description"
    * test invalid characters for "create new program", "copy program", "rename program", "description"
    * test automatic slide back mechanism after user canceled action... (optional)
    * test "show/hide details" (maybe not so crucial/important... => optional)
    */

}
