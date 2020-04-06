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

class BrickCellTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchAppWithDefaultProject()
    }

    override func tearDown() {
        super.tearDown()
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
        app.buttons[kLocalizedDone].tap()

        firstParameterTextViewWidth = firstParameterTextView.frame.size.width

        secondParameterTextView = app.collectionViews.cells.otherElements.containing(.staticText, identifier: kLocalizedPlaceAt)
                                  .children(matching: .button).element(boundBy: 1)
        secondParameterTextView.tap()

        for i in 1...8 {
            app.buttons["\(String(i))"].staticTexts["\(String(i))"].doubleTap()
        }
        app.buttons[kLocalizedDone].tap()
        secondParameterTextViewWidth = secondParameterTextView.frame.size.width

        XCTAssertTrue(firstParameterTextViewWidth > initialParameterTextViewWidth)
        XCTAssertEqual(firstParameterTextViewWidth, secondParameterTextViewWidth, accuracy: 0.0001)
        XCTAssertTrue(brickWidth - (firstParameterTextViewWidth + secondParameterTextViewWidth) < firstParameterTextViewWidth)
    }
}
