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

final class XMLMappingToObjcHeaderTests: XCTestCase {

    func testHeadersAreEqual() {
        let mock = HeaderMock()
        let cbProject = mock.getCBProject()
        let project = mock.getProject()
        let mappedProject = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)
        compareHeaders(projectA: mappedProject!, projectB: project)
    }
    
    func testManipulatedHeadersAreEqual() {
        let mock = HeaderMock()
        
        mock.applicationBuildName = ""
        mock.applicationBuildNumber = "abc"
        mock.dateTimeUpload = ""
        mock.landscapeMode = true
        mock.screenWidth = 0
        mock.programID = ""
        
        let cbProject = mock.getCBProject()
        let project = mock.getProject()
        let mappedProject = CBXMLMappingToObjc.mapCBProjectToProject(project: cbProject)
        compareHeaders(projectA: mappedProject!, projectB: project)
    }
    
    func compareHeaders(projectA: Project, projectB: Project) {
        XCTAssertEqual(projectA.header.applicationBuildName, projectB.header.applicationBuildName)
        XCTAssertEqual(projectA.header.applicationBuildNumber, projectB.header.applicationBuildNumber)
        XCTAssertEqual(projectA.header.applicationName, projectB.header.applicationName)
        XCTAssertEqual(projectA.header.applicationVersion, projectB.header.applicationVersion)
        XCTAssertEqual(projectA.header.catrobatLanguageVersion, projectB.header.catrobatLanguageVersion)
        XCTAssertEqual(projectA.header.dateTimeUpload, projectB.header.dateTimeUpload)
        XCTAssertEqual(projectA.header.programDescription, projectB.header.programDescription)
        XCTAssertEqual(projectA.header.deviceName, projectB.header.deviceName)
        XCTAssertEqual(projectA.header.landscapeMode, projectB.header.landscapeMode)
        XCTAssertEqual(projectA.header.mediaLicense, projectB.header.mediaLicense)
        XCTAssertEqual(projectA.header.platform, projectB.header.platform)
        XCTAssertEqual(projectA.header.platformVersion, projectB.header.platformVersion)
        XCTAssertEqual(projectA.header.programLicense, projectB.header.programLicense)
        XCTAssertEqual(projectA.header.programName, projectB.header.programName)
        XCTAssertEqual(projectA.header.remixOf, projectB.header.remixOf)
        XCTAssertEqual(projectA.header.screenHeight, projectB.header.screenHeight)
        XCTAssertEqual(projectA.header.screenWidth, projectB.header.screenWidth)
        XCTAssertEqual(projectA.header.screenMode, projectB.header.screenMode)
        XCTAssertEqual(projectA.header.tags, projectB.header.tags)
        XCTAssertEqual(projectA.header.url, projectB.header.url)
        XCTAssertEqual(projectA.header.userHandle, projectB.header.userHandle)
        XCTAssertEqual(projectA.header.programID, projectB.header.programID)
    }
}
