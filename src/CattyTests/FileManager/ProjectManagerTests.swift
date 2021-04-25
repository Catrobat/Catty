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

@testable import Pocket_Code

final class ProjectManagerTests: XCTestCase {

    var imageCache: RuntimeImageCacheMock!
    var fileManager: CBFileManagerMock!

    override func setUp() {
        imageCache = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [])
        fileManager = CBFileManagerMock()
    }

    func testCreateProject() {
        let projectName = "projectName"
        let projectId = "1234"

        let expectedProjectPath = Project.basePath() + projectName + kProjectIDSeparator + projectId + "/"
        let expectedImageDir = expectedProjectPath + Util.defaultSceneName(forSceneNumber: 1) + "/images"
        let expectedSoundsDir = expectedProjectPath + Util.defaultSceneName(forSceneNumber: 1) + "/sounds"
        let automaticScreenshotPath = expectedProjectPath + kScreenshotAutoFilename

        var projectIconImages = [Data]()
        for name in UIDefines.defaultScreenshots {
            if let image = UIImage(named: name) {
                projectIconImages.append(image.pngData()!)
            }
        }

        XCTAssertFalse(fileManager.directoryExists(expectedProjectPath))
        XCTAssertFalse(fileManager.directoryExists(expectedImageDir))
        XCTAssertFalse(fileManager.directoryExists(expectedSoundsDir))
        XCTAssertFalse(fileManager.fileExists(automaticScreenshotPath))
        XCTAssertFalse(imageCache.cleared)

        _ = ProjectManager.createProject(name: projectName, projectId: projectId, fileManager: fileManager, imageCache: imageCache)

        XCTAssertTrue(fileManager.directoryExists(expectedProjectPath))
        XCTAssertTrue(fileManager.directoryExists(expectedImageDir))
        XCTAssertTrue(fileManager.directoryExists(expectedSoundsDir))
        XCTAssertTrue(fileManager.fileExists(automaticScreenshotPath))
        XCTAssertTrue(imageCache.cleared)

        let automaticScreenshot = fileManager.dataWritten[automaticScreenshotPath]
        XCTAssertTrue(projectIconImages.contains(automaticScreenshot!))
    }

    func testRandomScreenshotSelectionOfNewProjects() {
        var differentScreenshots = false
        var previousSelectedScreenshot: Data?

        var projectIconImages = [Data]()
        for name in UIDefines.defaultScreenshots {
            if let image = UIImage(named: name) {
                projectIconImages.append(image.pngData()!)
            }
        }

        var count = 0
        while count < projectIconImages.count && !differentScreenshots {
            let projectName = "projectName_\(count)"
            let projectId = "1234\(count)"

            guard let info = ProjectLoadingInfo(forProjectWithName: projectName, projectID: projectId) else {
                XCTFail("Could not create projectLoadingInfo")
                return
            }

            let automaticScreenshotPath = info.basePath + kScreenshotAutoFilename
            _ = ProjectManager.createProject(name: projectName, projectId: projectId, fileManager: fileManager, imageCache: imageCache)

            let automaticScreenshot = fileManager.dataWritten[automaticScreenshotPath]
            XCTAssertTrue(projectIconImages.contains(automaticScreenshot!))

            if previousSelectedScreenshot == nil {
                previousSelectedScreenshot = automaticScreenshot
            } else if previousSelectedScreenshot != automaticScreenshot {
                differentScreenshots = true
            }

            count += 1
        }

        XCTAssertTrue(differentScreenshots)
    }

    func testLoadPreviewImageAndCacheWhenScreenshotCached() {
        guard let info = ProjectLoadingInfo.init(forProjectWithName: kDefaultProjectBundleName, projectID: kNoProjectIDYetPlaceholder) else {
            XCTFail("ProjectLoadingInfo nil for the default project")
            return
        }

        let screenshotPath = info.basePath + kScreenshotFilename
        let screenshot = UIImage(color: UIColor.green)!

        let imageCache = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [CachedImage(path: screenshotPath, image: screenshot, size: UIDefines.previewImageSize)])
        let fileManager = CBFileManagerMock()

        let expectation = XCTestExpectation(description: "Load image from cache - Screenshot")

        ProjectManager.loadPreviewImageAndCache(projectLoadingInfo: info, fileManager: fileManager, imageCache: imageCache) { image, path in
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
        let fileManager = CBFileManagerMock()

        let expectation = XCTestExpectation(description: "Load image from cache - Manual Screenshot")

        ProjectManager.loadPreviewImageAndCache(projectLoadingInfo: info, fileManager: fileManager, imageCache: imageCache) { image, path in
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
        let fileManager = CBFileManagerMock()

        let expectation = XCTestExpectation(description: "Load image from cache - Automatic Screenshot")

        ProjectManager.loadPreviewImageAndCache(projectLoadingInfo: info, fileManager: fileManager, imageCache: imageCache) { image, path in
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
        let fileManager = CBFileManagerMock(filePath: [automaticScreenshotPath], directoryPath: [])

        let expectation = XCTestExpectation(description: "Load image from disk - Automatic Screenshot")

        ProjectManager.loadPreviewImageAndCache(projectLoadingInfo: info, fileManager: fileManager, imageCache: imageCache) { image, path in
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
        let fileManager = CBFileManagerMock(filePath: [manualScreenshotPath], directoryPath: [])

        let expectation = XCTestExpectation(description: "Load image from disk - Manual Screenshot")

        ProjectManager.loadPreviewImageAndCache(projectLoadingInfo: info, fileManager: fileManager, imageCache: imageCache) { image, path in
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
        let fileManager = CBFileManagerMock(filePath: [screenshotPath], directoryPath: [])

        let expectation = XCTestExpectation(description: "Load image from disk - Screenshot")

        ProjectManager.loadPreviewImageAndCache(projectLoadingInfo: info, fileManager: fileManager, imageCache: imageCache) { image, path in
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
        let fileManager = CBFileManagerMock()

        let expectedImage = UIImage(named: "catrobat")

        ProjectManager.loadPreviewImageAndCache(projectLoadingInfo: info, fileManager: fileManager, imageCache: imageCache) { image, path in
            XCTAssertEqual(expectedImage, image)
            XCTAssertNil(path)
        }
        fileManager.addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist()
    }

    func testProjectNamesForID() {
        // TODO: Remove this once Project.allProjectLoadingInfos() has been moved to ProjectManager and can use CBFileManagerMock
        let fileManager = CBFileManager.shared()!
        for loadingInfo in Project.allProjectLoadingInfos() as! [ProjectLoadingInfo] {
            fileManager.deleteDirectory(loadingInfo.basePath!)
        }

        var projectNames = ProjectManager.projectNames(for: "")
        XCTAssertNil(projectNames)

        projectNames = ProjectManager.projectNames(for: "invalid")
        XCTAssertNil(projectNames)

        let project = ProjectManager.createProject(name: "projectName", projectId: "1234", fileManager: fileManager, imageCache: imageCache)

        projectNames = ProjectManager.projectNames(for: project.header.programID)
        XCTAssertNotNil(projectNames)
        XCTAssertEqual(1, projectNames?.count)
        XCTAssertEqual(projectNames?.first!, project.header.programName)

        let anotherProject = ProjectManager.createProject(name: project.header.programName + " (1)", projectId: project.header.programID, fileManager: fileManager, imageCache: imageCache)

        projectNames = ProjectManager.projectNames(for: project.header.programID)
        XCTAssertNotNil(projectNames)
        XCTAssertEqual(2, projectNames?.count)

        project.rename(toProjectName: project.header.programName, andProjectId: project.header.programID + "5", andShowSaveNotification: true)

        projectNames = ProjectManager.projectNames(for: anotherProject.header.programID)
        XCTAssertNotNil(projectNames)
        XCTAssertEqual(1, projectNames?.count)
        XCTAssertEqual(projectNames?.first!, anotherProject.header.programName)
    }
}
