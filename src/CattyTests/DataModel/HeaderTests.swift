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

import XCTest

@testable import Pocket_Code

final class HeaderTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testDefaultHeader() {
        let header = Header.default()!

        XCTAssertEqual(Util.appBuildName(), header.applicationBuildName)
        XCTAssertEqual(Util.appBuildVersion(), header.applicationBuildNumber)
        XCTAssertEqual(Util.appName(), header.applicationName)
        XCTAssertEqual(Util.appVersion(), header.applicationVersion)
        XCTAssertEqual(Util.catrobatLanguageVersion(), header.catrobatLanguageVersion)
        XCTAssertEqual(Util.deviceName(), header.deviceName)
        XCTAssertEqual(Util.catrobatMediaLicense(), header.mediaLicense)
        XCTAssertEqual(Util.platformName(), header.platform)
        XCTAssertEqual(Util.platformVersionWithoutPatch(), header.platformVersion)
        XCTAssertEqual(UtilMock.platformVersionWithoutPatch(), "11.4")
        XCTAssertEqual(UtilMock.platformVersionWithPatch(), "11.4.1")
        XCTAssertEqual(Util.catrobatProgramLicense(), header.programLicense)

        XCTAssertEqual(Util.screenHeight(true), CGFloat(truncating: header.screenHeight))
        XCTAssertEqual(Util.screenWidth(true), CGFloat(truncating: header.screenWidth))
        XCTAssertEqual(kCatrobatHeaderScreenModeStretch, header.screenMode)

        XCTAssertFalse(header.isArduinoProject)
        XCTAssertFalse(header.landscapeMode)

        XCTAssertNil(header.dateTimeUpload)
        XCTAssertNil(header.programDescription)
        XCTAssertNil(header.programName)
        XCTAssertNil(header.remixOf)
        XCTAssertNil(header.url)
        XCTAssertNil(header.userHandle)
        XCTAssertNil(header.tags)
        XCTAssertNil(header.programID)
    }
}

class UtilMock: Util {
    override class func platformVersion() -> OperatingSystemVersion {
        OperatingSystemVersion(majorVersion: 11, minorVersion: 4, patchVersion: 1)
    }
}
