/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

class ProjectMigratorTest: XCTestCase {

    var newFolderName: String!
    var header: Header!
    var project: Project!

    override func setUp() {
        super.setUp()
        newFolderName = Util.defaultSceneName(forSceneNumber: 1)

        self.header = Header()
        self.header.catrobatLanguageVersion = "\(ProjectMigrator.minimumCatrobatLanguageVersionForScenes)"

        project = Project()
        project.header = header
        project.scenes[0] = Scene(name: newFolderName)
        (project.scenes[0] as! Scene).project = project
    }

    func testMigrateToScene() {
        let projectPath = project.projectPath()

        var automaticScreenShortAtPath = String(describing: projectPath) + kScreenshotAutoFilename
        var imageDirectoryAtPath = String(describing: projectPath) + kProjectImagesDirName
        var soundDirectoryAtPath = String(describing: projectPath) + kProjectSoundsDirName
        var manualScreenShotAtPath = String(describing: projectPath) + kScreenshotManualFilename
        var screeShotAtPath = String(describing: projectPath) + kScreenshotFilename

        let fileManager = CBFileManagerMock(filePath: [automaticScreenShortAtPath, manualScreenShotAtPath, screeShotAtPath], directoryPath: [imageDirectoryAtPath, soundDirectoryAtPath, projectPath])

        let migrate = ProjectMigrator(fileManager: fileManager)

        do {
            try migrate.migrateToScene(project: project)
        } catch {
            XCTFail("Some error occured")
        }

        XCTAssertTrue(fileManager.fileExists(automaticScreenShortAtPath))
        XCTAssertFalse(fileManager.directoryExists(imageDirectoryAtPath))
        XCTAssertFalse(fileManager.directoryExists(soundDirectoryAtPath))
        XCTAssertTrue(fileManager.fileExists(manualScreenShotAtPath))
        XCTAssertTrue(fileManager.fileExists(screeShotAtPath))

        automaticScreenShortAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotAutoFilename
        imageDirectoryAtPath = "\(String(describing: projectPath) + newFolderName)/" + kProjectImagesDirName
        soundDirectoryAtPath = "\(String(describing: projectPath) + newFolderName)/" + kProjectSoundsDirName
        manualScreenShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotManualFilename
        screeShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotFilename

        XCTAssertTrue(fileManager.fileExists(automaticScreenShortAtPath))
        XCTAssertTrue(fileManager.directoryExists(imageDirectoryAtPath))
        XCTAssertTrue(fileManager.directoryExists(soundDirectoryAtPath))
        XCTAssertTrue(fileManager.fileExists(manualScreenShotAtPath))
        XCTAssertTrue(fileManager.fileExists(screeShotAtPath))
    }

    func testMigrateToSceneForAllButNoImageDirectory() {
       let projectPath = project.projectPath()

        var automaticScreenShortAtPath = String(describing: projectPath) + kScreenshotAutoFilename
        var soundDirectoryAtPath = String(describing: projectPath) + kProjectSoundsDirName
        var manualScreenShotAtPath = String(describing: projectPath) + kScreenshotManualFilename
        var screeShotAtPath = String(describing: projectPath) + kScreenshotFilename

        let fileManager = CBFileManagerMock(filePath: [automaticScreenShortAtPath, manualScreenShotAtPath, screeShotAtPath], directoryPath: [soundDirectoryAtPath, projectPath])

        let migrate = ProjectMigrator(fileManager: fileManager)

        do {
            try migrate.migrateToScene(project: project)
        } catch {
            XCTFail("Some error occured")
        }

        XCTAssertTrue(fileManager.fileExists(automaticScreenShortAtPath))
        XCTAssertFalse(fileManager.directoryExists(soundDirectoryAtPath))
        XCTAssertTrue(fileManager.fileExists(manualScreenShotAtPath))
        XCTAssertTrue(fileManager.fileExists(screeShotAtPath))

        automaticScreenShortAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotAutoFilename
        soundDirectoryAtPath = "\(String(describing: projectPath) + newFolderName)/" + kProjectSoundsDirName
        manualScreenShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotManualFilename
        screeShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotFilename

        XCTAssertTrue(fileManager.fileExists(automaticScreenShortAtPath))
        XCTAssertTrue(fileManager.directoryExists(soundDirectoryAtPath))
        XCTAssertTrue(fileManager.fileExists(manualScreenShotAtPath))
        XCTAssertTrue(fileManager.fileExists(screeShotAtPath))
    }

    func testMigrateToSceneForAllButNoSoundDirectory() {
       let projectPath = project.projectPath()

       var automaticScreenShortAtPath = String(describing: projectPath) + kScreenshotAutoFilename
       var imageDirectoryAtPath = String(describing: projectPath) + kProjectImagesDirName
       var manualScreenShotAtPath = String(describing: projectPath) + kScreenshotManualFilename
       var screeShotAtPath = String(describing: projectPath) + kScreenshotFilename

       let fileManager = CBFileManagerMock(filePath: [automaticScreenShortAtPath, manualScreenShotAtPath, screeShotAtPath], directoryPath: [imageDirectoryAtPath, projectPath])

       let migrate = ProjectMigrator(fileManager: fileManager)

       do {
           try migrate.migrateToScene(project: project)
       } catch {
           XCTFail("Some error occured")
       }

       XCTAssertTrue(fileManager.fileExists(automaticScreenShortAtPath))
       XCTAssertFalse(fileManager.directoryExists(imageDirectoryAtPath))
       XCTAssertTrue(fileManager.fileExists(manualScreenShotAtPath))
       XCTAssertTrue(fileManager.fileExists(screeShotAtPath))

       automaticScreenShortAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotAutoFilename
       imageDirectoryAtPath = "\(String(describing: projectPath) + newFolderName)/" + kProjectImagesDirName
       manualScreenShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotManualFilename
       screeShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotFilename

       XCTAssertTrue(fileManager.fileExists(automaticScreenShortAtPath))
       XCTAssertTrue(fileManager.directoryExists(imageDirectoryAtPath))
       XCTAssertTrue(fileManager.fileExists(manualScreenShotAtPath))
       XCTAssertTrue(fileManager.fileExists(screeShotAtPath))
    }

    func testMigrateToSceneForAllButNoAutomaticScreenshotFile() {
       let projectPath = project.projectPath()

       var imageDirectoryAtPath = String(describing: projectPath) + kProjectImagesDirName
       var soundDirectoryAtPath = String(describing: projectPath) + kProjectSoundsDirName
       var manualScreenShotAtPath = String(describing: projectPath) + kScreenshotManualFilename
       var screeShotAtPath = String(describing: projectPath) + kScreenshotFilename

       let fileManager = CBFileManagerMock(filePath: [manualScreenShotAtPath, screeShotAtPath], directoryPath: [imageDirectoryAtPath, soundDirectoryAtPath, projectPath])

       let migrate = ProjectMigrator(fileManager: fileManager)

       do {
           try migrate.migrateToScene(project: project)
       } catch {
           XCTFail("Some error occured")
       }

       XCTAssertFalse(fileManager.directoryExists(imageDirectoryAtPath))
       XCTAssertFalse(fileManager.directoryExists(soundDirectoryAtPath))
       XCTAssertTrue(fileManager.fileExists(manualScreenShotAtPath))
       XCTAssertTrue(fileManager.fileExists(screeShotAtPath))

       imageDirectoryAtPath = "\(String(describing: projectPath) + newFolderName)/" + kProjectImagesDirName
       soundDirectoryAtPath = "\(String(describing: projectPath) + newFolderName)/" + kProjectSoundsDirName
       manualScreenShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotManualFilename
       screeShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotFilename

       XCTAssertTrue(fileManager.directoryExists(imageDirectoryAtPath))
       XCTAssertTrue(fileManager.directoryExists(soundDirectoryAtPath))
       XCTAssertTrue(fileManager.fileExists(manualScreenShotAtPath))
       XCTAssertTrue(fileManager.fileExists(screeShotAtPath))
    }

    func testMigrateToSceneForAllButNoManualScreenshot() {
        let projectPath = project.projectPath()

        var automaticScreenShortAtPath = String(describing: projectPath) + kScreenshotAutoFilename
        var imageDirectoryAtPath = String(describing: projectPath) + kProjectImagesDirName
        var soundDirectoryAtPath = String(describing: projectPath) + kProjectSoundsDirName
        var screeShotAtPath = String(describing: projectPath) + kScreenshotFilename

        let fileManager = CBFileManagerMock(filePath: [automaticScreenShortAtPath, screeShotAtPath], directoryPath: [imageDirectoryAtPath, soundDirectoryAtPath, projectPath])

        let migrate = ProjectMigrator(fileManager: fileManager)

        do {
            try migrate.migrateToScene(project: project)
        } catch {
            XCTFail("Some error occured")
        }

        XCTAssertTrue(fileManager.fileExists(automaticScreenShortAtPath))
        XCTAssertFalse(fileManager.directoryExists(imageDirectoryAtPath))
        XCTAssertFalse(fileManager.directoryExists(soundDirectoryAtPath))
        XCTAssertTrue(fileManager.fileExists(screeShotAtPath))

        automaticScreenShortAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotAutoFilename
        imageDirectoryAtPath = "\(String(describing: projectPath) + newFolderName)/" + kProjectImagesDirName
        soundDirectoryAtPath = "\(String(describing: projectPath) + newFolderName)/" + kProjectSoundsDirName
        screeShotAtPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotFilename

        XCTAssertTrue(fileManager.fileExists(automaticScreenShortAtPath))
        XCTAssertTrue(fileManager.directoryExists(imageDirectoryAtPath))
        XCTAssertTrue(fileManager.directoryExists(soundDirectoryAtPath))
        XCTAssertTrue(fileManager.fileExists(screeShotAtPath))
    }

    func testMigrateToSceneForInvalidCatrobatLanguageVersion() {
        header.catrobatLanguageVersion = "0.991"
        project.header = header

        let fileManager = CBFileManagerMock(filePath: [] as! [String], directoryPath: [] as! [String])

        let migrate = ProjectMigrator(fileManager: fileManager)

        expect { try migrate.migrateToScene(project: self.project) }.to(throwError(ProjectMigratorError.unsupportedCatrobatLanguageVersion))
    }

    func testMigrateToSceneForProjectPathNotFound() {
        let fileManager = CBFileManagerMock(filePath: [] as! [String], directoryPath: [] as! [String])

        let migrate = ProjectMigrator(fileManager: fileManager)

        expect { try migrate.migrateToScene(project: self.project) }.to(throwError(ProjectMigratorError.pathNotFound))
    }

    func testMigrateToSceneForUnknownException() {
        project.header.catrobatLanguageVersion = "catrobatLanguageVersion"
        let projectPath = project.projectPath()

        let automaticScreenShortAtPath = String(describing: projectPath) + kScreenshotAutoFilename
        let imageDirectoryAtPath = String(describing: projectPath) + kProjectImagesDirName
        let soundDirectoryAtPath = String(describing: projectPath) + kProjectSoundsDirName
        let manualScreenShotAtPath = String(describing: projectPath) + kScreenshotManualFilename
        let screeShotAtPath = String(describing: projectPath) + kScreenshotFilename

        let fileManager = CBFileManagerMock(filePath: [automaticScreenShortAtPath, manualScreenShotAtPath, screeShotAtPath], directoryPath: [imageDirectoryAtPath, soundDirectoryAtPath, projectPath])

        let migrate = ProjectMigrator(fileManager: fileManager)

        let error = ProjectMigratorError.unknown(description: "Unable to convert version number to Float")

        expect { try migrate.migrateToScene(project: self.project) }.to(throwError(error))
    }

    func testMigrateToSceneForCopyScreenshot() {
        let projectPath = project.projectPath()

        let automaticScreenshortAtPath = String(describing: projectPath) + kScreenshotAutoFilename
        let manualScreenshotAtPath = String(describing: projectPath) + kScreenshotManualFilename
        let screeshotAtPath = String(describing: projectPath) + kScreenshotFilename

        let automaticScreenshortExpectedPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotAutoFilename
        let manualScreenshotExpectedPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotManualFilename
        let screeshotExpectedPath = "\(String(describing: projectPath) + newFolderName)/" + kScreenshotFilename

        let fileManager = CBFileManagerMock(filePath: [automaticScreenshortAtPath, manualScreenshotAtPath, screeshotAtPath], directoryPath: [projectPath])

        XCTAssertTrue(fileManager.fileExists(automaticScreenshortAtPath))
        XCTAssertTrue(fileManager.fileExists(manualScreenshotAtPath))
        XCTAssertTrue(fileManager.fileExists(screeshotAtPath))

        XCTAssertFalse(fileManager.fileExists(automaticScreenshortExpectedPath))
        XCTAssertFalse(fileManager.fileExists(manualScreenshotExpectedPath))
        XCTAssertFalse(fileManager.fileExists(screeshotExpectedPath))

        let migrate = ProjectMigrator(fileManager: fileManager)

        do {
            try migrate.migrateToScene(project: project)
        } catch {
             XCTFail("Some error occured")
        }

        XCTAssertTrue(fileManager.fileExists(automaticScreenshortAtPath))
        XCTAssertTrue(fileManager.fileExists(manualScreenshotAtPath))
        XCTAssertTrue(fileManager.fileExists(screeshotAtPath))

        XCTAssertTrue(fileManager.fileExists(automaticScreenshortExpectedPath))
        XCTAssertTrue(fileManager.fileExists(manualScreenshotExpectedPath))
        XCTAssertTrue(fileManager.fileExists(screeshotExpectedPath))
    }

}
