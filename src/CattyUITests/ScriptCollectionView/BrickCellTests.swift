/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

class BrickCellTests: XCTestCase {

    var app: XCUIApplication!
    let testLookNames: [String] = ["look_test1", "look_test2", "look_test3"]

    override func setUp() {
        super.setUp()
        app = launchApp()
    }

    override func tearDown() {
        super.tearDown()
    }

    private func clearScript() {
        app.buttons[kLocalizedDelete].tap()
        app.buttons[kLocalizedSelectAllItems].firstMatch.tap()
        app.buttons[kLocalizedDelete].tap()
        app.buttons[kLocalizedYes].tap()
    }

    private func addBackgroundBrickWithValuesToProject(brick: String, category: String) {
        clearScript()
        addBrick(label: brick, section: category, in: app)

        for lookName in testLookNames {
            tapOnBackgroundPicker(for: brick, in: app)

            app.pickerWheels.firstMatch.swipeDown()
            app.buttons[kLocalizedDone].firstMatch.tap()

            let alert1 = waitForElementToAppear(app.sheets[kLocalizedAddLook])
            alert1.buttons[kLocalizedDrawNewImage].tap()

            waitForElementToAppear(app.buttons["tools"]).tap()
            waitForElementToAppear(app.tables.firstMatch).swipeUp()
            app.tables.staticTexts[kLocalizedPaintFill].tap()

            let drawView = waitForElementToAppear(app.images["PaintCanvas"])
            let coordinate: XCUICoordinate = drawView.coordinate(withNormalizedOffset: CGVector(dx: 0.0, dy: 0.0))
            coordinate.tap()

            waitForElementToAppear(app.navigationBars[kLocalizedPaintPocketPaint]).buttons[kLocalizedBack].tap()

            let alert2 = waitForElementToAppear(app.sheets.firstMatch)
            alert2.buttons[kLocalizedSaveChanges].tap()

            let alert3 = waitForElementToAppear(app.alerts[kLocalizedAddImage])
            alert3.textFields.buttons["Clear text"].tap()
            alert3.textFields.element.typeText(lookName)
            alert3.buttons[kLocalizedOK].tap()
        }
    }

    func testVariableBrickParameterSpace() {
        let brickWidth: CGFloat
        let initialParameterTextViewWidth: CGFloat
        let firstParameterTextView: XCUIElement
        let secondParameterTextView: XCUIElement
        let firstParameterTextViewWidth: CGFloat
        let secondParameterTextViewWidth: CGFloat

        createProject(name: "My Project", in: app)
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()
        addBrick(label: kLocalizedPlaceAt, section: kLocalizedCategoryMotion, in: app)

        brickWidth = app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedPlaceAt).firstMatch.frame.size.width
        initialParameterTextViewWidth = app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedPlaceAt)
                                        .children(matching: .button).firstMatch.frame.size.width

        firstParameterTextView = app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedPlaceAt)
                                 .children(matching: .button).element(boundBy: 0)
        firstParameterTextView.tap()

        for i in 1...8 {
            app.buttons["\(String(i))"].staticTexts["\(String(i))"].doubleTap()
        }
        app.buttons[kLocalizedDone].firstMatch.tap()

        firstParameterTextViewWidth = firstParameterTextView.frame.size.width

        secondParameterTextView = app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedPlaceAt)
                                  .children(matching: .button).element(boundBy: 1)
        secondParameterTextView.tap()

        for i in 1...8 {
            app.buttons["\(String(i))"].staticTexts["\(String(i))"].doubleTap()
        }
        app.buttons[kLocalizedDone].firstMatch.tap()
        secondParameterTextViewWidth = secondParameterTextView.frame.size.width

        XCTAssertTrue(firstParameterTextViewWidth > initialParameterTextViewWidth)
        XCTAssertEqual(firstParameterTextViewWidth, secondParameterTextViewWidth, accuracy: 0.0001)

        let remainingSpaceRight = brickWidth - (secondParameterTextView.frame.origin.x + secondParameterTextView.frame.size.width)
        XCTAssertTrue(remainingSpaceRight < firstParameterTextViewWidth)
    }

    func testSetBackgroundBrick() {
        let brick: String = kLocalizedSetBackground

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        addBackgroundBrickWithValuesToProject(brick: brick, category: kLocalizedCategoryLook)

        tapOnBackgroundPicker(for: brick, in: app)

        XCTAssertEqual(app.pickerWheels.element.children(matching: .any).count, 5)

        for lookName in testLookNames {
            tapOnBackgroundPicker(for: brick, in: app)

            app.pickerWheels.element.adjust(toPickerWheelValue: lookName)
            app.buttons[kLocalizedDone].firstMatch.tap()
        }
    }
}
