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

class CattyUISnapshots: XCTestCase {

    let app = XCUIApplication()
    let mediaLibraryImageName = "Penguin"

    override func setUp() {
        setupSnapshot(app)
        app.launch()
        dismissPrivacyPolicyScreenIfShown()
    }

    func testUIScreenshots() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedEdit].tap()

        app.sheets[kLocalizedEditProjects].scrollViews.otherElements.buttons[kLocalizedDeleteProjects].tap()

        let toolbar = app.toolbars["Toolbar"]
        toolbar.buttons[kLocalizedSelectAllItems].tap()
        toolbar.buttons[kLocalizedDelete].tap()
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()
        snapshot("01-Landing page")

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()

        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts[kLocalizedMyFirstProject].tap()
        tablesQuery.staticTexts[kLocalizedMole + " 1"].tap()
        tablesQuery.staticTexts[kLocalizedScripts].tap()
        snapshot("02-Mole 1 script")

        app.navigationBars[kLocalizedScripts].buttons[kLocalizedMole + " 1"].tap()

        tablesQuery.staticTexts[kLocalizedLooks].tap()
        app.toolbars["Toolbar"].buttons[kLocalizedAdd].tap()

        app.sheets[kLocalizedAddLook].scrollViews.otherElements.buttons[kLocalizedMediaLibrary].tap()

        let loadMediaLibraryExpectation = XCTestExpectation(description: "Wait till the page loads")
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            loadMediaLibraryExpectation.fulfill()
        }
        wait(for: [loadMediaLibraryExpectation], timeout: 5.1)
        snapshot("04-Media library")

        let imageCell = app.collectionViews.children(matching: .cell)[mediaLibraryImageName].children(matching: .other).element
        let exists = NSPredicate(format: "exists == 1")
        let imageCellExpectation = expectation(for: exists, evaluatedWith: imageCell, handler: nil)
        wait(for: [imageCellExpectation], timeout: 5.0)
        imageCell.tap()

        tablesQuery.staticTexts[mediaLibraryImageName].tap()
        snapshot("05-Paint with Penguin")
    }

    func testMyFirstProjectScreenshot() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.tables.staticTexts[kLocalizedMyFirstProject].tap()

        app.toolbars["Toolbar"].buttons["Play"].tap()

        let projectLoadExpectation = XCTestExpectation(description: "Arbitrarily wait till the project loads")

        Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { _ in
            projectLoadExpectation.fulfill()
        }

        wait(for: [projectLoadExpectation], timeout: 3.1)
        snapshot("06-My first project stage")
    }

    func testCatrobatCommunityScreenshot() {
        app.tables.staticTexts[kLocalizedCatrobatCommunity].tap()
        app.tabBars.buttons["Charts"].tap()

        let loadCompleteExpectation = XCTestExpectation(description: "Wait till the page loads")

        Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { _ in
            loadCompleteExpectation.fulfill()
        }

        wait(for: [loadCompleteExpectation], timeout: 2.1)
        snapshot("03-Catrobat community charts")
    }

    private func dismissPrivacyPolicyScreenIfShown() {
        if app.buttons[kLocalizedPrivacyPolicyAgree].exists {
            app.buttons[kLocalizedPrivacyPolicyAgree].tap()
        }
    }
}
