/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

class BrickCellPickerViewerTests: XCTestCase {

    var app: XCUIApplication!
    var variableBrickHasValues: Bool!
    var ACCESSABILITY_LABEL_VARIABLE = "VariableView_"
    var ACCESSABILITY_LABEL_MESSAGE = "MessageView_"
    var PROJECT_NAME = "Test Project"
    var testValues = ["testVariable1", "testVariable2", "testVariable3"]

    override func setUp() {
        super.setUp()
        app = launchAppWithDefaultProject()
        app.staticTexts[kLocalizedContinueProject].tap()
        variableBrickHasValues = false
    }

    private func clearScript() {
        app.buttons[kLocalizedDelete].tap()
        app.buttons[kLocalizedSelectAllItems].firstMatch.tap()
        app.buttons[kLocalizedDelete].tap()
        app.buttons[kLocalizedYes].tap()
    }

    private func addValuesForVariableBrick(brick: String, category: String) {
        for variable in testValues {
            app.collectionViews.cells.otherElements.containing(.staticText, identifier: brick).children(matching: .other).element.tap()
            app.pickerWheels.firstMatch.swipeDown()
            app.buttons[kLocalizedDone].tap()

            XCTAssert(app.sheets[kUIFEActionVar].exists)
            app.buttons[kUIFEActionVarObj].tap()

            let alert = app.alerts[kUIFENewVar]
            alert.textFields[kLocalizedEnterYourVariableNameHere].typeText(variable)
            alert.buttons[kLocalizedOK].tap()
            XCTAssert(waitForElementToAppear(app.otherElements[ACCESSABILITY_LABEL_VARIABLE + variable]).exists)
        }
    }

    private func addControlBrickWithValuesToProject(brick: String, category: String) {
        clearScript()
        addBrick(label: brick, section: category, in: app)

        for variable in testValues {
            app.collectionViews.cells.otherElements.containing(.staticText, identifier: brick).children(matching: .other).element.tap()
            app.pickerWheels.firstMatch.swipeDown()
            app.buttons[kLocalizedDone].tap()

            let alert = app.alerts[kLocalizedNewMessage]
            alert.textFields[kLocalizedEnterYourMessageHere].typeText(variable)
            alert.buttons[kLocalizedOK].tap()
        }
    }

    func testChangeVariableDone() {
        let bricks: [String] = [
            kLocalizedSetVariable,
            kLocalizedChangeVariable,
            kLocalizedShowVariable
        ]

        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        for brick in bricks {
            clearScript()
            addBrick(label: brick, section: kLocalizedCategoryVariable, in: app)

            if variableBrickHasValues == false {
                addValuesForVariableBrick(brick: brick, category: kLocalizedCategoryVariable)
                variableBrickHasValues = true
            }

            app.collectionViews.cells.otherElements.containing(.staticText, identifier: brick).children(matching: .other).element.tap()

            app.pickerWheels.element.adjust(toPickerWheelValue: testValues[0])
            app.buttons[kLocalizedDone].tap()
            XCTAssert(waitForElementToAppear(app.otherElements[ACCESSABILITY_LABEL_VARIABLE + testValues[0]]).exists, "Error while changing variable for Brick: " + brick)
        }
    }

    func testChangeVariableCancel() {
        let bricks: [String] = [
            kLocalizedSetVariable,
            kLocalizedChangeVariable,
            kLocalizedShowVariable
        ]

        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        for brick in bricks {
            clearScript()
            addBrick(label: brick, section: kLocalizedCategoryVariable, in: app)
            if variableBrickHasValues == false {
                addValuesForVariableBrick(brick: brick, category: kLocalizedCategoryVariable)
                variableBrickHasValues = true
            }

            app.collectionViews.cells.otherElements.containing(.staticText, identifier: brick).children(matching: .other).element.tap()

            app.pickerWheels.element.adjust(toPickerWheelValue: testValues[2])
            app.buttons[kLocalizedDone].tap()

            app.collectionViews.cells.otherElements.containing(.staticText, identifier: brick).children(matching: .other).element.tap()

            app.pickerWheels.element.adjust(toPickerWheelValue: testValues[0])
            app.buttons[kLocalizedCancel].tap()
            XCTAssert(waitForElementToAppear(app.otherElements[ACCESSABILITY_LABEL_VARIABLE + testValues[2]]).exists, "Error while changing variable for Brick and cancel: " + brick)
        }
    }

    func testChangeControlDone() {
        let bricks: [String] = [
            kLocalizedBroadcast,
            kLocalizedBroadcastAndWait,
            kLocalizedWhenYouReceive
        ]

        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        for brick in bricks {
            addControlBrickWithValuesToProject(brick: brick, category: kLocalizedCategoryControl)
            app.collectionViews.cells.otherElements.containing(.staticText, identifier: brick).children(matching: .other).element.tap()

            app.pickerWheels.element.adjust(toPickerWheelValue: testValues[2])
            app.buttons[kLocalizedDone].tap()
            XCTAssert(waitForElementToAppear(app.otherElements[ACCESSABILITY_LABEL_MESSAGE + testValues[2]]).exists, "Error while changing variable for Brick: " + brick)
        }
    }

    func testChangeControlCancel() {
        let bricks: [String] = [
            kLocalizedBroadcast,
            kLocalizedBroadcastAndWait,
            kLocalizedWhenYouReceive
        ]

        app.tables.staticTexts[kLocalizedBackground].tap()
        app.tables.staticTexts[kLocalizedScripts].tap()

        for brick in bricks {
            addControlBrickWithValuesToProject(brick: brick, category: kLocalizedCategoryControl)
            app.collectionViews.cells.otherElements.containing(.staticText, identifier: brick).children(matching: .other).element.tap()

            app.pickerWheels.element.adjust(toPickerWheelValue: testValues[2])
            app.buttons[kLocalizedDone].tap()

            app.collectionViews.cells.otherElements.containing(.staticText, identifier: brick).children(matching: .other).element.tap()

            app.pickerWheels.firstMatch.swipeDown()
            app.buttons[kLocalizedCancel].tap()
            XCTAssert(waitForElementToAppear(app.otherElements[ACCESSABILITY_LABEL_MESSAGE + testValues[2]]).exists, "Error while changing variable for Brick and cancel: " + brick)
        }
    }
}
