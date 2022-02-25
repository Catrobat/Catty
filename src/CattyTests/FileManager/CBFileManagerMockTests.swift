/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

final class CBFileManagerMockTest: XCTestCase {

    var baseprojectPath: String!

    override func setUp() {
        super.setUp()

        self.baseprojectPath = Project.basePath()
    }

    func testFileExists() {
        let file1Path = baseprojectPath + "/file1"
        let file2Path = baseprojectPath + "/file2"

        var fileManager = CBFileManagerMock(filePath: [file1Path], directoryPath: [] as! [String])

        XCTAssertTrue(fileManager.fileExists(file1Path))
        XCTAssertFalse(fileManager.fileExists(file2Path))

        fileManager = CBFileManagerMock(filePath: [file1Path, file2Path], directoryPath: [] as! [String])

        XCTAssertTrue(fileManager.fileExists(file1Path))
        XCTAssertTrue(fileManager.fileExists(file2Path))
    }

    func testDirectoryExists() {
        let directory1Path = baseprojectPath + "/directory1"
        let directory2Path = baseprojectPath + "/directory2"

        var fileManager = CBFileManagerMock(filePath: [] as! [String], directoryPath: [directory1Path])

        XCTAssertTrue(fileManager.directoryExists(directory1Path))
        XCTAssertFalse(fileManager.directoryExists(directory2Path))

        fileManager = CBFileManagerMock(filePath: [] as! [String], directoryPath: [directory1Path, directory2Path])

        XCTAssertTrue(fileManager.directoryExists(directory1Path))
        XCTAssertTrue(fileManager.directoryExists(directory2Path))
    }

    func testCreateDirectory() {
        let directoryPath = baseprojectPath + "/directory"

        let fileManager = CBFileManagerMock(filePath: [] as! [String], directoryPath: [] as! [String])

        XCTAssertFalse(fileManager.directoryExists(directoryPath))

        fileManager.createDirectory(directoryPath)

        XCTAssertTrue(fileManager.directoryExists(directoryPath))
    }

    func testMoveExistingFile() {
        let fileInitialPath = baseprojectPath + "/file1"
        let fileFinalpath = baseprojectPath + "newFolder/file1"

        let fileManager = CBFileManagerMock(filePath: [fileInitialPath], directoryPath: [] as! [String])

        XCTAssertTrue(fileManager.fileExists(fileInitialPath))
        XCTAssertFalse(fileManager.fileExists(fileFinalpath))

        fileManager.moveExistingFile(atPath: fileInitialPath, toPath: fileFinalpath, overwrite: false)

        XCTAssertFalse(fileManager.fileExists(fileInitialPath))
        XCTAssertTrue(fileManager.fileExists(fileFinalpath))
    }

    func testMoveExistingDirectory() {
        let directoryInitialPath = baseprojectPath + "/directory"
        let directoryFinalpath = baseprojectPath + "newFolder/directory"

        let fileManager = CBFileManagerMock(filePath: [] as! [String], directoryPath: [directoryInitialPath])

        XCTAssertTrue(fileManager.directoryExists(directoryInitialPath))
        XCTAssertFalse(fileManager.directoryExists(directoryFinalpath))

        fileManager.moveExistingDirectory(atPath: directoryInitialPath, toPath: directoryFinalpath)

        XCTAssertFalse(fileManager.directoryExists(directoryInitialPath))
        XCTAssertTrue(fileManager.directoryExists(directoryFinalpath))
    }

}
