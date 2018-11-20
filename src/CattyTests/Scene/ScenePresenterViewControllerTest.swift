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

@testable import Pocket_Code

final class ScenePresenterViewControllerTest: XCTestCase {

    var vc: ScenePresenterViewController!
    var skView: SKView!
    var program: Program!

    override func setUp() {
        super.setUp()
        vc = ScenePresenterViewController()
        skView = SKView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1000, height: 2500)))

        program = Program.defaultProgram(withName: "testProgram", programID: "")
    }

    func testScreenshot() {
        let screenshot = vc.screenshot(for: skView)

        XCTAssertEqual(CGFloat(ProgramConstants.previewImageWidth), screenshot?.size.width)
        XCTAssertEqual(CGFloat(ProgramConstants.previewImageHeight), screenshot?.size.height)
    }

    func testAutomaticScreenshot() {
        let expectedPath = program.projectPath() + kScreenshotAutoFilename
        let exp = expectation(description: "screenshot saved")

        XCTAssertFalse(FileManager.default.fileExists(atPath: expectedPath))
        vc.takeAutomaticScreenshot(for: skView, and: program)
        DispatchQueue.main.async {
            XCTAssertTrue(FileManager.default.fileExists(atPath: expectedPath))
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }

    func testManualScreenshot() {
        let expectedPath = program.projectPath() + kScreenshotManualFilename
        let exp = expectation(description: "screenshot saved")
        vc.takeManualScreenshot(for: skView, and: program)
        DispatchQueue.main.async {
            XCTAssertTrue(FileManager.default.fileExists(atPath: expectedPath))
            exp.fulfill()
        }
        waitForExpectations(timeout: 5, handler: nil)
    }
}
