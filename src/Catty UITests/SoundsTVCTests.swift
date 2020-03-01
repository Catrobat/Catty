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

class SoundsTVCTests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        app = launchAppWithDefaultProject()
    }

    func testLengthOfSounds() {
        let soundName = String(repeating: "a", count: 250)

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        waitForElementToAppear(app.tables.staticTexts["Mole 1"]).tap()
        app.tables.staticTexts[kLocalizedSounds].tap()

        app.tables.staticTexts.firstMatch.swipeLeft()
        app.buttons[kLocalizedMore].tap()
        app.buttons[kLocalizedRename].tap()

        let alert = waitForElementToAppear(app.alerts[kLocalizedRenameSound])
        alert.buttons["Clear text"].tap()

        let textField = alert.textFields[kLocalizedEnterYourSoundNameHere]
        textField.typeText(soundName)
        alert.buttons[kLocalizedOK].tap()

        XCTAssertTrue(app.toolbars.buttons[kLocalizedUserListAdd].exists)

        app.tables.staticTexts.firstMatch.swipeLeft()
        app.buttons[kLocalizedMore].tap()
        app.buttons[kLocalizedRename].tap()

        alert.buttons["Clear text"].tap()
        textField.typeText(soundName + "b")
        alert.buttons[kLocalizedOK].tap()
    }

    func testSoundsCanEnterSoundsOfAllMoles() {
        let testElement = kLocalizedSounds
        let projectObjects = ["Mole 1", "Mole 2", "Mole 3", "Mole 4"]

        app.tables.staticTexts[kLocalizedContinueProject].tap()
        for object in projectObjects {
            waitForElementToAppear(app.tables.staticTexts[object]).tap()
            app.tables.staticTexts[testElement].tap()
            XCTAssert(app.navigationBars[testElement].buttons[object].exists)
            app.navigationBars[testElement].buttons[object].tap()
            app.navigationBars[object].buttons[kLocalizedMyFirstProject].tap()

            let projectVC = waitForElementToAppear(app.navigationBars[kLocalizedMyFirstProject])
            XCTAssert(waitForElementToAppear(projectVC.buttons[kLocalizedPocketCode]).exists)
        }
    }
}
