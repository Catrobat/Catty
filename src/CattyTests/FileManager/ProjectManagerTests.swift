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

@testable import Pocket_Code

final class ProjectManagerTests: XCTestCase {

    let filePaths = [String]()
    let directoryPaths = [String]()

    func testCreateProject() {

        let projectName = "abcd"
        let projectId = "1234"

        guard let info = ProjectLoadingInfo(forProjectWithName: projectName, projectID: projectId) else {
            XCTFail("Coult not create projectLoadingInfo")
            return
        }

        let expectedProjectPath = Project.basePath() + projectName + kProjectIDSeparator + projectId + "/"
        let expectedImageDir = expectedProjectPath + Util.defaultSceneName(forSceneNumber: 1) + "/images"
        let expectedSoundsDir = expectedProjectPath + Util.defaultSceneName(forSceneNumber: 1) + "/sounds"
        let defaultAutoScreenshotPath = expectedProjectPath + kScreenshotAutoFilename

        let automaticScreenshotThumbnailPath = info.basePath + kScreenshotThumbnailPrefix + kScreenshotAutoFilename

        var projectIconImages = [UIImage]()
        for name in kDefaultScreenshots {
            if let image = UIImage(named: name) {
                projectIconImages.append(image)
            }
        }

        let imageCache = RuntimeImageCacheMock(thumbnails: [:], cachedImages: [:])
        let fileManager = CBFileManagerMock(imageCache: imageCache)

        XCTAssertFalse(fileManager.directoryExists(expectedProjectPath))
        XCTAssertFalse(fileManager.directoryExists(expectedImageDir))
        XCTAssertFalse(fileManager.directoryExists(expectedSoundsDir))
        XCTAssertFalse(fileManager.fileExists(defaultAutoScreenshotPath))
        XCTAssertNil(imageCache.thumbnails[automaticScreenshotThumbnailPath])

        let expectation1 = XCTestExpectation(description: "cannot find any screenshot for project abcd")
        fileManager.loadPreviewImageAndCache(projectLoadingInfo: ProjectLoadingInfo(forProjectWithName: projectName, projectID: projectId)) { image, path in
            XCTAssertEqual(image, UIImage(named: "catrobat"))
            XCTAssertNil(path)

            expectation1.fulfill()
        }
        wait(for: [expectation1], timeout: 1)

        _ = ProjectManager.createProject(name: projectName, projectId: projectId, fileManager: fileManager)

        XCTAssertTrue(fileManager.directoryExists(expectedProjectPath))
        XCTAssertTrue(fileManager.directoryExists(expectedImageDir))
        XCTAssertTrue(fileManager.directoryExists(expectedSoundsDir))
        XCTAssertTrue(fileManager.fileExists(defaultAutoScreenshotPath))
        XCTAssertNotNil(imageCache.thumbnails[automaticScreenshotThumbnailPath])

        let expectation2 = XCTestExpectation(description: "found default screenshot for project abcd")
        fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(path, automaticScreenshotThumbnailPath)

            if let iconImage = image {
                XCTAssertTrue(projectIconImages.contains(iconImage))
            } else {
                XCTFail("Image is nil")
            }

            expectation2.fulfill()
        }
        wait(for: [expectation2], timeout: 1.0)
    }

    func testRandomScreenshotSelectionOfNewProjects() {

        var differentScreenshots = false
        var previousSelectedScreenshot: UIImage?

        var projectIconImages = [UIImage]()
        for name in kDefaultScreenshots {
            if let image = UIImage(named: name) {
                projectIconImages.append(image)
            }
        }

        var count = 0
        while count < projectIconImages.count && !differentScreenshots {

            let projectName = "abcd_\(count)"
            let projectId = "1234\(count)"

            guard let info = ProjectLoadingInfo(forProjectWithName: projectName, projectID: projectId) else {
                XCTFail("Could not create projectLoadingInfo")
                return
            }

            let automaticScreenshotThumbnailPath = info.basePath + kScreenshotThumbnailPrefix + kScreenshotAutoFilename
            let imageCache = RuntimeImageCacheMock(thumbnails: [automaticScreenshotThumbnailPath: UIImage()], cachedImages: [:])
            let fileManager = CBFileManagerMock(imageCache: imageCache)

            _ = ProjectManager.createProject(name: projectName, projectId: projectId, fileManager: fileManager)

            let expectation = XCTestExpectation(description: "found default screenshot for testProject")
            fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
                XCTAssertEqual(path, automaticScreenshotThumbnailPath)

                if previousSelectedScreenshot == nil {
                    previousSelectedScreenshot = image

                    if let img = image {
                        XCTAssertTrue(projectIconImages.contains(img))
                    } else {
                        XCTFail("Received nil instead of an expected default screenshot")
                    }

                } else if previousSelectedScreenshot != image {

                    if let img = image {
                        XCTAssertTrue(projectIconImages.contains(img))
                    } else {
                        XCTFail("Received nil instead of an expected default screenshot")
                    }
                    differentScreenshots = true
                }

                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 1.0)
            count += 1
        }

        XCTAssertTrue(differentScreenshots)

    }

}
