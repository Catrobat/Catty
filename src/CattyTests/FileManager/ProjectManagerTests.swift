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
        fileManager = CBFileManagerMock(imageCache: imageCache)
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

        _ = ProjectManager.shared.createProject(name: projectName, projectId: projectId)

        XCTAssertTrue(fileManager.directoryExists(expectedProjectPath))
        XCTAssertTrue(fileManager.directoryExists(expectedImageDir))
        XCTAssertTrue(fileManager.directoryExists(expectedSoundsDir))
        XCTAssertTrue(fileManager.fileExists(automaticScreenshotPath))
        XCTAssertTrue(imageCache.cleared)

        let automaticScreenshot = fileManager.dataWritten[automaticScreenshotPath]
        XCTAssertTrue(projectIconImages.contains(automaticScreenshot!))
    }
    
    func testRemoveObjects() {
        
        
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
            _ = ProjectManager.shared.createProject(name: projectName, projectId: projectId)

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
}
