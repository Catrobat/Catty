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

final class XMLHeaderTests: XCTestCase {

    func testInit() {
        let mock = HeaderMock()
        let cbHeader = mock.getMockCBHeader()
        let header = mock.getHeader()
        let mappedHeader = CBHeader(header)
        compareHeaders(left: mappedHeader, right: cbHeader)
    }

    func testTransform() {
        let mock = HeaderMock()
        let cbHeader = mock.getMockCBHeader()
        let header = mock.getHeader()
        let mappedHeader = cbHeader.transform()
        compareHeaders(left: mappedHeader, right: header)
    }

    func compareHeaders(left: CBHeader, right: CBHeader) {
        XCTAssertEqual(left.applicationBuildName, right.applicationBuildName)
        XCTAssertEqual(left.applicationBuildNumber, right.applicationBuildNumber)
        XCTAssertEqual(left.applicationName, right.applicationName)
        XCTAssertEqual(left.applicationVersion, right.applicationVersion)
        XCTAssertEqual(left.dateTimeUpload, right.dateTimeUpload)
        XCTAssertEqual(left.description, right.description)
        XCTAssertEqual(left.deviceName, right.deviceName)
        XCTAssertEqual(left.landscapeMode, right.landscapeMode)
        XCTAssertEqual(left.mediaLicense, right.mediaLicense)
        XCTAssertEqual(left.platform, right.platform)
        XCTAssertEqual(left.platformVersion, right.platformVersion)
        XCTAssertEqual(left.programLicense, right.programLicense)
        XCTAssertEqual(left.programName, right.programName)
        XCTAssertEqual(left.remixOf, right.remixOf)
        XCTAssertEqual(left.screenHeight, right.screenHeight)
        XCTAssertEqual(left.screenWidth, right.screenWidth)
        XCTAssertEqual(left.screenMode, right.screenMode)
        XCTAssertEqual(left.tags, right.tags)
        XCTAssertEqual(left.url, right.url)
        XCTAssertEqual(left.userHandle, right.userHandle)
        XCTAssertEqual(left.programID, right.programID)
    }

    func compareHeaders(left: Header, right: Header) {
        XCTAssertEqual(left.applicationBuildName, right.applicationBuildName)
        XCTAssertEqual(left.applicationBuildNumber, right.applicationBuildNumber)
        XCTAssertEqual(left.applicationName, right.applicationName)
        XCTAssertEqual(left.applicationVersion, right.applicationVersion)
        XCTAssertEqual(left.catrobatLanguageVersion, right.catrobatLanguageVersion)
        XCTAssertEqual(left.dateTimeUpload, right.dateTimeUpload)
        XCTAssertEqual(left.programDescription, right.programDescription)
        XCTAssertEqual(left.deviceName, right.deviceName)
        XCTAssertEqual(left.landscapeMode, right.landscapeMode)
        XCTAssertEqual(left.mediaLicense, right.mediaLicense)
        XCTAssertEqual(left.platform, right.platform)
        XCTAssertEqual(left.platformVersion, right.platformVersion)
        XCTAssertEqual(left.programLicense, right.programLicense)
        XCTAssertEqual(left.programName, right.programName)
        XCTAssertEqual(left.remixOf, right.remixOf)
        XCTAssertEqual(left.screenHeight, right.screenHeight)
        XCTAssertEqual(left.screenWidth, right.screenWidth)
        XCTAssertEqual(left.screenMode, right.screenMode)
        XCTAssertEqual(left.tags, right.tags)
        XCTAssertEqual(left.url, right.url)
        XCTAssertEqual(left.userHandle, right.userHandle)
        XCTAssertEqual(left.programID, right.programID)
    }
}
