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

final class StagePresenterViewControllerScreenshotTest: XCTestCase {

    var vc: StagePresenterViewController!
    var skView: SKView!
    var project: Project!

    override func setUp() {
        super.setUp()
        vc = StagePresenterViewController()
        skView = SKView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 1000, height: 2500)))
        project = ProjectManager.shared.createProject(name: "testProject", projectId: "")
    }

    func testAutomaticScreenshot() {
        let expectedRootPath = project.projectPath() + kScreenshotAutoFilename
        let expectedScenePath = project.scene.path()! + kScreenshotAutoFilename

        XCTAssertFalse(FileManager.default.fileExists(atPath: expectedScenePath))

        let exp = expectation(description: "screenshot saved")

        vc.takeAutomaticScreenshot(for: skView, and: project.scene)

        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedRootPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedScenePath))

        let rootImage = UIImage(contentsOfFile: expectedRootPath)
        let sceneImage = UIImage(contentsOfFile: expectedScenePath)
        XCTAssertFalse(rootImage === sceneImage)
        XCTAssertEqual(sceneImage?.size.width, rootImage?.size.width)
        XCTAssertEqual(sceneImage?.size.height, rootImage?.size.height)

        XCTAssertEqual(CGFloat(type(of: vc).previewImageWidth), rootImage?.size.width)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageHeight), rootImage?.size.height)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageWidth), sceneImage?.size.width)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageHeight), sceneImage?.size.height)
    }

    func testManualScreenshot() {
        let expectedRootPath = project.projectPath() + kScreenshotManualFilename
        let expectedScenePath = project.scene.path()! + kScreenshotManualFilename

        XCTAssertFalse(FileManager.default.fileExists(atPath: expectedScenePath))
        XCTAssertFalse(FileManager.default.fileExists(atPath: expectedRootPath))

        let exp = expectation(description: "screenshot saved")
        vc.takeManualScreenshot(for: skView, and: project.scene)

        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedRootPath))
        XCTAssertTrue(FileManager.default.fileExists(atPath: expectedScenePath))

        let rootImage = UIImage(contentsOfFile: expectedRootPath)
        let sceneImage = UIImage(contentsOfFile: expectedScenePath)
        XCTAssertFalse(rootImage === sceneImage)
        XCTAssertEqual(sceneImage?.size.width, rootImage?.size.width)
        XCTAssertEqual(sceneImage?.size.height, rootImage?.size.height)

        XCTAssertEqual(CGFloat(type(of: vc).previewImageWidth), rootImage?.size.width)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageHeight), rootImage?.size.height)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageWidth), sceneImage?.size.width)
        XCTAssertEqual(CGFloat(type(of: vc).previewImageHeight), sceneImage?.size.height)
    }

    func testManualScreenshotAndClearCache() {
        let imageCache = RuntimeImageCache.shared()!
        let existingPath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)
        let cacheExpectation = expectation(description: "image cached")

        imageCache.loadImageFromDisk(withPath: existingPath, onCompletion: { _, _ in
            cacheExpectation.fulfill()
        })

        wait(for: [cacheExpectation], timeout: 1.0)
        XCTAssertNotNil(imageCache.cachedImage(forPath: existingPath)!)

        let exp = expectation(description: "screenshot saved")
        vc.takeManualScreenshot(for: skView, and: project.scene)

        DispatchQueue.main.async { exp.fulfill() }
        waitForExpectations(timeout: 5, handler: nil)

        XCTAssertNil(imageCache.cachedImage(forPath: existingPath))
    }
}
