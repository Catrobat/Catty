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

final class CBFileManagerTests: XCTestCase {

    var fileManager: CBFileManager!
    var projectId: String!
    var projectName: String!

    override func setUp() {
        super.setUp()

        fileManager = CBFileManager.shared()
        projectId = "1234"
        projectName = "testProject"
    }

    func testUnzipAndStore() {

        Project.removeProjectFromDisk(withProjectName: projectName, projectID: projectId)
        XCTAssertFalse(Project.projectExists(withProjectID: projectId))

        let projectData = NSData(contentsOf: Bundle.main.url(forResource: "My first project", withExtension: "catrobat")!)! as Data
        let result = fileManager.unzipAndStore(projectData, withProjectID: projectId, withName: projectName)

        XCTAssertTrue(result)
        XCTAssertTrue(Project.projectExists(withProjectID: projectId))
        XCTAssertTrue(Project.projectExists(withProjectName: projectName, projectID: projectId))
    }

    func testUnzipAndStoreWithSameName() {

        Project.removeProjectFromDisk(withProjectName: projectName, projectID: projectId)
        XCTAssertFalse(Project.projectExists(withProjectID: projectId))

        let projectData = NSData(contentsOf: Bundle.main.url(forResource: "My first project", withExtension: "catrobat")!)! as Data

        let result = fileManager.unzipAndStore(projectData, withProjectID: projectId, withName: projectName)

        let newProjectName = "testProject (1)"
        XCTAssertTrue(result)
        XCTAssertTrue(Project.projectExists(withProjectID: projectId))
        XCTAssertTrue(Project.projectExists(withProjectName: newProjectName, projectID: projectId))

        let result_2 = fileManager.unzipAndStore(projectData, withProjectID: projectId, withName: projectName)

        let newProjectName_2 = "testProject (2)"
        XCTAssertTrue(result_2)
        XCTAssertTrue(Project.projectExists(withProjectID: projectId))
        XCTAssertTrue(Project.projectExists(withProjectName: newProjectName_2, projectID: projectId))
    }

    func testUnzipAndStoreWithSameNameDifferentId() {

        Project.removeProjectFromDisk(withProjectName: projectName, projectID: projectId)
        Project.removeProjectFromDisk(withProjectName: projectName + " (1)", projectID: projectId)
        Project.removeProjectFromDisk(withProjectName: projectName + " (2)", projectID: projectId)
        Project.removeProjectFromDisk(withProjectName: projectName, projectID: "4321")
        Project.removeProjectFromDisk(withProjectName: projectName + " (1)", projectID: "4321")
        Project.removeProjectFromDisk(withProjectName: projectName + " (2)", projectID: "4321")
        XCTAssertFalse(Project.projectExists(withProjectID: projectId))
        XCTAssertFalse(Project.projectExists(withProjectID: "4321"))

        let projectData = NSData(contentsOf: Bundle.main.url(forResource: "My first project", withExtension: "catrobat")!)! as Data

        let result = fileManager.unzipAndStore(projectData, withProjectID: projectId, withName: projectName)
        XCTAssertTrue(result)
        XCTAssertTrue(Project.projectExists(withProjectID: projectId))
        XCTAssertTrue(Project.projectExists(withProjectName: projectName, projectID: projectId))

        let projectId_2 = "4321"
        let result_2 = fileManager.unzipAndStore(projectData, withProjectID: projectId_2, withName: projectName)

        let newProjectName = "testProject (1)"
        XCTAssertTrue(result_2)
        XCTAssertTrue(Project.projectExists(withProjectID: projectId_2))
        XCTAssertTrue(Project.projectExists(withProjectName: newProjectName, projectID: projectId_2))

        let result_3 = fileManager.unzipAndStore(projectData, withProjectID: projectId_2, withName: projectName)

        let newProjectName_2 = "testProject (2)"
        XCTAssertTrue(result_3)
        XCTAssertTrue(Project.projectExists(withProjectID: projectId_2))
        XCTAssertTrue(Project.projectExists(withProjectName: newProjectName_2, projectID: projectId_2))
    }

    func testUnzipAndStoreWithInvalidData() {

        Project.removeProjectFromDisk(withProjectName: projectName, projectID: projectId)
        Project.removeProjectFromDisk(withProjectName: projectName, projectID: projectId)
        Project.removeProjectFromDisk(withProjectName: projectName + " (1)", projectID: "4321")
        Project.removeProjectFromDisk(withProjectName: projectName + " (2)", projectID: "4321")
        XCTAssertFalse(Project.projectExists(withProjectID: projectId))

        let programData = NSData(contentsOf: Bundle.main.url(forResource: "Document-Icon", withExtension: "png")!)! as Data
        let result = fileManager.unzipAndStore(programData, withProjectID: projectId, withName: projectName)

        XCTAssertFalse(result)
        XCTAssertFalse(Project.projectExists(withProjectID: projectId))
    }

    func testLoadPreviewImageAndCacheWhenScreenshotCached() {
        guard let info = ProjectLoadingInfo.init(forProjectWithName: kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder) else {
            XCTFail("ProjectLoadingInfo nil for the default project")
            return
        }

        let screenshotPath = info.basePath + kScreenshotFilename
        let screenshot = UIImage(color: UIColor.green)!

        let imageCache = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [CachedImage(path: screenshotPath, image: screenshot, size: UIDefines.previewImageSize)])
        let fileManager = CBFileManagerMock(imageCache: imageCache)

        let expectation = XCTestExpectation(description: "Load image from cache - Screenshot")

        fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(screenshotPath, path)
            XCTAssertEqual(screenshot, image)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadPreviewImageAndCacheWhenManualScreenshotCached() {
        guard let info = ProjectLoadingInfo.init(forProjectWithName: kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder) else {
            XCTFail("ProjectLoadingInfo nil for the default project")
            return
        }

        let manualScreenshotPath = info.basePath + kScreenshotManualFilename
        let manualScreenshot = UIImage(color: UIColor.green)!

        let imageCache = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [CachedImage(path: manualScreenshotPath, image: manualScreenshot, size: UIDefines.previewImageSize)])
        let fileManager = CBFileManagerMock(imageCache: imageCache)

        let expectation = XCTestExpectation(description: "Load image from cache - Manual Screenshot")

        fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(manualScreenshotPath, path)
            XCTAssertEqual(manualScreenshot, image)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadPreviewImageAndCacheWhenAutomaticScreenshotCached() {
        guard let info = ProjectLoadingInfo.init(forProjectWithName: kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder) else {
            XCTFail("ProjectLoadingInfo nil for the default project")
            return
        }

        let automaticScreenshotPath = info.basePath + kScreenshotAutoFilename
        let automaticScreenshot = UIImage(color: UIColor.blue)!

        let imageCache = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [CachedImage(path: automaticScreenshotPath, image: automaticScreenshot, size: UIDefines.previewImageSize)])
        let fileManager = CBFileManagerMock(imageCache: imageCache)

        let expectation = XCTestExpectation(description: "Load image from cache - Automatic Screenshot")

        fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(automaticScreenshotPath, path)
            XCTAssertEqual(automaticScreenshot, image)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadPreviewImageAndCacheWhenAutomaticScreenshotNotCached() {
        guard let info = ProjectLoadingInfo.init(forProjectWithName: kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder) else {
            XCTFail("ProjectLoadingInfo nil for the default project")
            return
        }

        let automaticScreenshotPath = info.basePath + kScreenshotAutoFilename
        let automaticScreenshot = UIImage(color: UIColor.red)!

        let imageCache = RuntimeImageCacheMock(imagesOnDisk: [automaticScreenshotPath: automaticScreenshot], cachedImages: [])
        let fileManager = CBFileManagerMock(imageCache: imageCache, filePath: [automaticScreenshotPath])

        let expectation = XCTestExpectation(description: "Load image from disk - Automatic Screenshot")

        fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(automaticScreenshotPath, path)
            XCTAssertEqual(automaticScreenshot, image)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadPreviewImageAndCacheWhenManualScreenshotNotCached() {
        guard let info = ProjectLoadingInfo.init(forProjectWithName: kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder) else {
            XCTFail("ProjectLoadingInfo nil for the default project")
            return
        }

        let manualScreenshotPath = info.basePath + kScreenshotManualFilename
        let manualScreenshot = UIImage(color: UIColor.green)!

        let imageCache = RuntimeImageCacheMock(imagesOnDisk: [manualScreenshotPath: manualScreenshot], cachedImages: [])
        let fileManager = CBFileManagerMock(imageCache: imageCache, filePath: [manualScreenshotPath])

        let expectation = XCTestExpectation(description: "Load image from disk - Manual Screenshot")

        fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(manualScreenshotPath, path)
            XCTAssertEqual(manualScreenshot, image)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadPreviewImageAndCacheWhenScreenshotNotCached() {
        guard let info = ProjectLoadingInfo.init(forProjectWithName: kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder) else {
            XCTFail("ProjectLoadingInfo nil for the default project")
            return
        }

        let screenshotPath = info.basePath + kScreenshotFilename
        let screenshot = UIImage(color: UIColor.orange)!

        let imageCache = RuntimeImageCacheMock(imagesOnDisk: [screenshotPath: screenshot], cachedImages: [])
        let fileManager = CBFileManagerMock(imageCache: imageCache, filePath: [screenshotPath])

        let expectation = XCTestExpectation(description: "Load image from disk - Screenshot")

        fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(screenshotPath, path)
            XCTAssertEqual(screenshot, image)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadPreviewImageAndCacheWhenNoScreenshotOnDisk() {
        guard let info = ProjectLoadingInfo.init(forProjectWithName: kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder) else {
            XCTFail("ProjectLoadingInfo nil for the default project")
            return
        }

        let imageCache = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [])
        let fileManager = CBFileManagerMock(imageCache: imageCache)

        let expectedImage = UIImage(named: "catrobat")

        fileManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(expectedImage, image)
            XCTAssertNil(path)
        }
        fileManager.addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist()
    }
}
