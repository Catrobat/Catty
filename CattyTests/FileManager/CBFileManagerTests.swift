/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

    override func setUp() {
        super.setUp()

        fileManager = CBFileManager.shared()
    }

    func testUnzipAndStore() {
        let projectId = "1234"
        let projectName = "testProject"

        Project.removeProjectFromDisk(withProjectName: projectName, projectID: projectId)
        XCTAssertFalse(Project.projectExists(withProjectID: projectId))

        let projectData = NSData(contentsOf: Bundle.main.url(forResource: "My first project", withExtension: "catrobat")!)! as Data
        let result = fileManager.unzipAndStore(projectData, withProjectID: projectId, withName: projectName)

        XCTAssertTrue(result)
        XCTAssertTrue(Project.projectExists(withProjectID: projectId))
        XCTAssertTrue(Project.projectExists(withProjectName: projectName, projectID: projectId))
    }

    func testUnzipAndStoreWithInvalidData() {
        let projectId = "1234"
        let projectName = "testProject"

        Project.removeProjectFromDisk(withProjectName: projectName, projectID: projectId)
        XCTAssertFalse(Project.projectExists(withProjectID: projectId))

        let programData = NSData(contentsOf: Bundle.main.url(forResource: "Document-Icon", withExtension: "png")!)! as Data
        let result = fileManager.unzipAndStore(programData, withProjectID: projectId, withName: projectName)

        XCTAssertFalse(result)
        XCTAssertFalse(Project.projectExists(withProjectID: projectId))
    }
}
