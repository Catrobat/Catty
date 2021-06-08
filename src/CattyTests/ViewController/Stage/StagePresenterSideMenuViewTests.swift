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

import Nimble
import XCTest

@testable import Pocket_Code

final class StagePresenterSideMenuViewTests: XCTestCase {

    var view: StagePresenterSideMenuView!
    var project: Project!
    var delegateMock: StagePresenterSideMenuDelegate!

    override func setUp() {
        super.setUp()

        project = Project()
        project.header = Header()
        project.header.screenWidth = 123
        project.header.screenHeight = 456

        delegateMock = StagePresenterSideMenuDelegateMock(project: project)
    }

    func testPortrait() {
        project.header.landscapeMode = false

        view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)
        XCTAssertFalse(view.landscape)
    }

    func testLandscape() {
        project.header.landscapeMode = true

        view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)
        XCTAssertTrue(view.landscape)
    }

    func testAspectRatioMinimize() {
        project.header.screenMode = kCatrobatHeaderScreenModeMaximize

        let view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)

        XCTAssertNotNil(view.aspectRatioButton)
        XCTAssertNotNil(view.aspectRatioLabel)
        XCTAssertFalse(view.aspectRatioButton!.isHidden)
        XCTAssertFalse(view.aspectRatioLabel!.isHidden)
        XCTAssertEqual(kLocalizedMinimize, view.aspectRatioLabel?.currentTitle)
    }

    func testAspectRatioMaximize() {
        project.header.screenMode = kCatrobatHeaderScreenModeStretch

        let view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)

        XCTAssertNotNil(view.aspectRatioButton)
        XCTAssertNotNil(view.aspectRatioLabel)
        XCTAssertFalse(view.aspectRatioButton!.isHidden)
        XCTAssertFalse(view.aspectRatioLabel!.isHidden)
        XCTAssertEqual(kLocalizedMaximize, view.aspectRatioLabel?.currentTitle)
    }

    func testAspectRatioHidden() {
        project.header.screenMode = kCatrobatHeaderScreenModeStretch
        project.header.screenWidth = NSNumber(value: Util.screenWidth(true).doubleValue)
        project.header.screenHeight = NSNumber(value: Util.screenHeight(true).doubleValue)

        let view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)

        XCTAssertTrue(view.aspectRatioButton!.isHidden)
        XCTAssertTrue(view.aspectRatioLabel!.isHidden)
    }

    func testAspectRatioLandscape() {
        project.header.screenWidth = NSNumber(value: Util.screenWidth(true).doubleValue)
        project.header.screenHeight = NSNumber(value: Util.screenHeight(true).doubleValue)
        project.header.landscapeMode = true

        let view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)

        XCTAssertFalse(view.aspectRatioButton!.isHidden)
        XCTAssertFalse(view.aspectRatioLabel!.isHidden)
    }

    func testAspectRatioLandscapeHidden() {
        project.header.screenWidth = NSNumber(value: Util.screenHeight(true).doubleValue)
        project.header.screenHeight = NSNumber(value: Util.screenWidth(true).doubleValue)
        project.header.landscapeMode = true

        let view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)

        XCTAssertTrue(view.aspectRatioButton!.isHidden)
        XCTAssertTrue(view.aspectRatioLabel!.isHidden)
    }

    func testRestart() {
        let view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)
        XCTAssertFalse(view.landscape)

        project.header.landscapeMode = true
        view.restart(with: project)

        XCTAssertTrue(view.landscape)
    }

    func testRestartAspectRatio() {
        project.header.screenWidth = NSNumber(value: Util.screenWidth(true).doubleValue)
        project.header.screenHeight = 10

        let view = StagePresenterSideMenuView(frame: .zero, delegate: delegateMock)
        XCTAssertFalse(view.aspectRatioButton!.isHidden)
        XCTAssertFalse(view.aspectRatioLabel!.isHidden)

        project.header.screenHeight = NSNumber(value: Util.screenHeight(true).doubleValue)

        view.restart(with: project)

        XCTAssertTrue(view.aspectRatioButton!.isHidden)
        XCTAssertTrue(view.aspectRatioLabel!.isHidden)
    }
}

class StagePresenterSideMenuDelegateMock: StagePresenterSideMenuDelegate {
    var project: Project
    var stopActionCalled = false
    var continueActionCalled = false
    var restartActionCalled = false
    var takeScreenshotActionCalled = false
    var showHideAxisActionCalled = false
    var aspectRatioActionCalled = false
    var shareDSTActionCalled = false

    init(project: Project) {
        self.project = project
    }

    func stopAction() {
        stopActionCalled = true
    }

    func continueAction() {
        continueActionCalled = true
    }

    func restartAction() {
        restartActionCalled = true
    }

    func takeScreenshotAction() {
        takeScreenshotActionCalled = true
    }

    func showHideAxisAction() {
        showHideAxisActionCalled = true
    }

    func aspectRatioAction() {
        aspectRatioActionCalled = true
    }

    func shareDSTAction() {
        shareDSTActionCalled = true
    }
}
