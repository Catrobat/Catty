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

import Nimble
import XCTest

@testable import Pocket_Code

final class StagePresenterViewControllerTest: XCTestCase {

    var vc: StagePresenterViewController!
    var skView: SKView!
    var project: Project!

    override func setUp() {
        super.setUp()
        vc = StagePresenterViewController()
        skView = SKView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1000, height: 2500)))

        project = Project.defaultProject(withName: "testProject", projectID: "")
    }

    func testAutomaticScreenshot() {
        let expectedPath = project.projectPath() + kScreenshotAutoFilename
        let exp = expectation(description: "screenshot saved")

        XCTAssertFalse(FileManager.default.fileExists(atPath: expectedPath))
        vc.takeAutomaticScreenshot(for: skView, and: project)

        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedPath))

        let image = UIImage(contentsOfFile: expectedPath)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageWidth), image?.size.width)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageHeight), image?.size.height)
    }

    func testManualScreenshot() {
        let expectedPath = project.projectPath() + kScreenshotManualFilename
        let exp = expectation(description: "screenshot saved")
        vc.takeManualScreenshot(for: skView, and: project)

        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedPath))

        let image = UIImage(contentsOfFile: expectedPath)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageWidth), image?.size.width)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageHeight), image?.size.height)
    }

    func testNotification() {
        let expectedNotification = Notification(name: .stagePresenterViewControllerDidAppear, object: vc)

        expect(self.vc.viewDidAppear(true)).to(postNotifications(contain(expectedNotification)))
    }
}
