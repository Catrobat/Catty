/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

    override func setUp() {
        setupSnapshot(app)
        app.launch()
        dismissPrivacyPolicyScreenIfShown()
    }

    private func dismissPrivacyPolicyScreenIfShown() {
        if app.buttons[kLocalizedPrivacyPolicyAgree].exists {
            app.buttons[kLocalizedPrivacyPolicyAgree].tap()
        }
    }

    func testMyFirstProjectScreenshots() {
        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedEdit].tap()
        app.scrollViews.otherElements.buttons[kLocalizedDeleteProjects].tap()
        let toolbar = app.toolbars["Toolbar"]
        toolbar.buttons[kLocalizedSelectAllItems].tap()
        toolbar.buttons[kLocalizedDelete].tap()
        app.navigationBars[kLocalizedProjects].buttons[kLocalizedPocketCode].tap()
        snapshot("01-Main")

        app.tables.staticTexts[kLocalizedProjectsOnDevice].tap()
        let tablesQuery = XCUIApplication().tables
        tablesQuery.staticTexts[kLocalizedMyFirstProject].tap()
        snapshot("03-Project")

        tablesQuery.staticTexts[kLocalizedMole + " 1"].tap()
        tablesQuery.staticTexts[kLocalizedScripts].tap()
        snapshot("04-Scripts")

        app.navigationBars[kLocalizedScripts].buttons[kLocalizedMole + " 1"].tap()
        tablesQuery.staticTexts[kLocalizedLooks].tap()
        tablesQuery.staticTexts["Mole"].tap()
        snapshot("05-Paint")

        app.navigationBars[kLocalizedPaintPocketPaint].buttons[kLocalizedBack].tap()
        app.toolbars["Toolbar"].buttons["Play"].tap()
        let stageLoadExpectation = XCTestExpectation(description: "Wait till the stage loads")
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            stageLoadExpectation.fulfill()
        }
        wait(for: [stageLoadExpectation], timeout: 5.1)
        let leftEdge = app.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5))
        let center = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))
        leftEdge.press(forDuration: 0.5, thenDragTo: center)
        app.staticTexts[kLocalizedMaximize].tap()
        snapshot("06-Stage")
    }

    func testCatrobatCommunityScreenshot() {
        app.tables.staticTexts[kLocalizedCatrobatCommunity].tap()
        let communityLoadExpectation = XCTestExpectation(description: "Wait till the featured projects load")
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { _ in
            communityLoadExpectation.fulfill()
        }
        wait(for: [communityLoadExpectation], timeout: 5.1)
        snapshot("02-Community")
    }
}
