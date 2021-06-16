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

import Foundation
import XCTest

@testable import Pocket_Code

final class URLExtensionTests: XCTestCase {

    let testId = "817"
    let testAppProjectUrl = URL(string: "https://share.catrob.at/app/project/817")
    let testAppDownloadUrl = URL(string: "https://share.catrob.at/app/download/817.catrobat?fname=Tic-Tac-Toe%20Master")
    let testPocketcodeProjectUrl = URL(string: "https://share.catrob.at/pocketcode/project/817")
    let testPocketcodeDownloadUrl = URL(string: "https://share.catrob.at/pocketcode/download/817.catrobat?fname=Tic-Tac-Toe%20Master")
    let testInvalidTooShortUrl = URL(string: "https://share.catrob.at/invalid")
    let testInvalidTooLongUrl = URL(string: "https://share.catrob.at/invalid/invalid/invalid/invalid")
    let testInvalidPathUrl = URL(string: "https://share.catrob.at/app/invalid/817")

    func testIdFromURLAppProjectURL() {
        XCTAssertEqual(testId, testAppProjectUrl!.catrobatProjectId())
    }

    func testIdFromURLAppDownloadURL() {
        XCTAssertEqual(testId, testAppDownloadUrl!.catrobatProjectId())
    }

    func testIdFromURLPocketcodeProjectURL() {
        XCTAssertEqual(testId, testPocketcodeProjectUrl!.catrobatProjectId())
    }

    func testIdFromURLPocketcodeDownloadURL() {
        XCTAssertEqual(testId, testPocketcodeDownloadUrl!.catrobatProjectId())
    }

    func testIdFromURLInvalidTooLongURL() {
        XCTAssertNil(testInvalidTooShortUrl!.catrobatProjectId())
    }

    func testIdFromURLInvalidTooShortURL() {
        XCTAssertNil(testInvalidTooLongUrl!.catrobatProjectId())
    }

    func testIdFromURLInvalidPathURL() {
        XCTAssertNil(testInvalidPathUrl!.catrobatProjectId())
    }
}
