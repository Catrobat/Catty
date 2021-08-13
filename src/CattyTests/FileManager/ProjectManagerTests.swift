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

    var imageCacheMock: RuntimeImageCacheMock!
    var fileManagerMock: CBFileManagerMock!
    var project: Project!
    var projectManager: ProjectManager!

    override func setUp() {
        imageCacheMock = RuntimeImageCacheMock(imagesOnDisk: [:], cachedImages: [])
        fileManagerMock = CBFileManagerMock()
        projectManager = ProjectManager(fileManager: fileManagerMock, imageCache: imageCacheMock)
    }

    func testCreateProject() {
        let projectName = "newProjectName"
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

        XCTAssertFalse(fileManagerMock.directoryExists(expectedProjectPath))
        XCTAssertFalse(fileManagerMock.directoryExists(expectedImageDir))
        XCTAssertFalse(fileManagerMock.directoryExists(expectedSoundsDir))
        XCTAssertFalse(fileManagerMock.fileExists(automaticScreenshotPath))
        XCTAssertFalse(imageCacheMock.cleared)

        self.project = projectManager.createProject(name: projectName, projectId: projectId)

        XCTAssertTrue(fileManagerMock.directoryExists(expectedProjectPath))
        XCTAssertTrue(fileManagerMock.directoryExists(expectedImageDir))
        XCTAssertTrue(fileManagerMock.directoryExists(expectedSoundsDir))
        XCTAssertTrue(fileManagerMock.fileExists(automaticScreenshotPath))
        XCTAssertTrue(imageCacheMock.cleared)

        let automaticScreenshot = fileManagerMock.dataWritten[automaticScreenshotPath]
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
            _ = projectManager.createProject(name: projectName, projectId: projectId)

            let automaticScreenshot = fileManagerMock.dataWritten[automaticScreenshotPath]
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

        imageCacheMock.cachedImages = [CachedImage(path: screenshotPath, image: screenshot, size: UIDefines.previewImageSize)]

        let expectation = XCTestExpectation(description: "Load image from cache - Screenshot")

        projectManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
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

        imageCacheMock.cachedImages = [CachedImage(path: manualScreenshotPath, image: manualScreenshot, size: UIDefines.previewImageSize)]

        let expectation = XCTestExpectation(description: "Load image from cache - Manual Screenshot")

        projectManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
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

        imageCacheMock.cachedImages = [CachedImage(path: automaticScreenshotPath, image: automaticScreenshot, size: UIDefines.previewImageSize)]

        let expectation = XCTestExpectation(description: "Load image from cache - Automatic Screenshot")

        projectManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
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

        imageCacheMock.imagesOnDisk = [automaticScreenshotPath: automaticScreenshot]
        imageCacheMock.cachedImages = []
        fileManagerMock.existingFiles = [automaticScreenshotPath]

        let expectation = XCTestExpectation(description: "Load image from disk - Automatic Screenshot")

        projectManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
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

        imageCacheMock.imagesOnDisk = [manualScreenshotPath: manualScreenshot]
        imageCacheMock.cachedImages = []
        fileManagerMock.existingFiles = [manualScreenshotPath]

        let expectation = XCTestExpectation(description: "Load image from disk - Manual Screenshot")

        projectManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
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

        imageCacheMock.imagesOnDisk = [screenshotPath: screenshot]
        imageCacheMock.cachedImages = []
        fileManagerMock.existingFiles = [screenshotPath]

        let expectation = XCTestExpectation(description: "Load image from disk - Screenshot")

        projectManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
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

        imageCacheMock.imagesOnDisk = [:]
        imageCacheMock.cachedImages = []

        let expectedImage = UIImage(named: "catrobat")
        let expectation = XCTestExpectation(description: "Load image from disk - Screenshot")

        projectManager.loadPreviewImageAndCache(projectLoadingInfo: info) { image, path in
            XCTAssertEqual(expectedImage, image)
            XCTAssertNil(path)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    func testProjectNamesForID() {
        // TODO: Remove this once Project.allProjectLoadingInfos() has been moved to ProjectManager and can use CBFileManagerMock
        let fileManager = CBFileManager.shared()!
        projectManager = ProjectManager(fileManager: fileManager)

        for loadingInfo in Project.allProjectLoadingInfos() as! [ProjectLoadingInfo] {
            fileManager.deleteDirectory(loadingInfo.basePath!)
        }

        var projectNames = projectManager.projectNames(for: "")
        XCTAssertNil(projectNames)

        projectNames = projectManager.projectNames(for: "invalid")
        XCTAssertNil(projectNames)

        let project = projectManager.createProject(name: "projectName", projectId: "1234")

        projectNames = projectManager.projectNames(for: project.header.programID)
        XCTAssertNotNil(projectNames)
        XCTAssertEqual(1, projectNames?.count)
        XCTAssertEqual(projectNames?.first!, project.header.programName)

        let anotherProject = projectManager.createProject(name: project.header.programName + " (1)", projectId: project.header.programID)

        projectNames = projectManager.projectNames(for: project.header.programID)
        XCTAssertNotNil(projectNames)
        XCTAssertEqual(2, projectNames?.count)

        project.rename(toProjectName: project.header.programName, andProjectId: project.header.programID + "5", andShowSaveNotification: true)

        projectNames = projectManager.projectNames(for: anotherProject.header.programID)
        XCTAssertNotNil(projectNames)
        XCTAssertEqual(1, projectNames?.count)
        XCTAssertEqual(projectNames?.first!, anotherProject.header.programName)
    }

    func testAddProjectFromFileWithValidUrl() {
        let bundle = Bundle.init(for: self.classForCoder)
        guard let xmlPath = bundle.path(forResource: "817", ofType: "catrobat") else {
            XCTAssertFalse(false)
            return
        }

        let sumProjectNamesBefore = Project.allProjectNames().count

        let project = projectManager.addProjectFromFile(url: URL(fileURLWithPath: xmlPath))
        XCTAssertNotNil(project)

        let sumProjectNamesAfter = Project.allProjectNames().count

        XCTAssertEqual(sumProjectNamesBefore + 1, sumProjectNamesAfter)

        XCTAssertTrue((Project.allProjectNames() as! [String]).contains("Tic-Tac-Toe Master"))
    }

    func testAddProjectFromFileWithInvalidUrl() {
        let sumProjectNamesBefor = Project.allProjectNames().count

        let project = projectManager.addProjectFromFile(url: URL(fileURLWithPath: "test"))
        XCTAssertNil(project)

        let sumProjectNamesAfter = Project.allProjectNames().count

        XCTAssertEqual(sumProjectNamesBefor, sumProjectNamesAfter)
    }

    func testRemoveObjects() {
        let project = projectManager.createProject(name: "newProjectName", projectId: "1234")
        let scene = Scene(name: "testScene")

        let object1 = SpriteObject()
        object1.name = "testObject1"
        scene.add(object: object1)

        let object2 = SpriteObject()
        object2.name = "testObject2"
        scene.add(object: object2)

        let object3 = SpriteObject()
        object3.name = "testObject3"
        scene.add(object: object3)
        project.scene = scene

        XCTAssertEqual(3, scene.objects().count)

        projectManager.removeObjects(project, objects: [object1, object2])

        XCTAssertEqual(1, project.scene.objects().count)
        XCTAssertEqual(object3, scene.objects()[0])
    }
}
