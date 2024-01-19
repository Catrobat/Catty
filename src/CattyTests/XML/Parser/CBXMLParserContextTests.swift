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

class CBXMLParserContextTests: XMLAbstractTest {

    func testIsEqualToLanguageVersion() {
        let parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.93)), andRootElement: GDataXMLElement())
        XCTAssertTrue(parserContext!.isEqual(toLanguageVersion: 0.93))
        XCTAssertFalse(parserContext!.isEqual(toLanguageVersion: 0.993))
        XCTAssertFalse(parserContext!.isEqual(toLanguageVersion: 0.92))
        XCTAssertFalse(parserContext!.isEqual(toLanguageVersion: 0.94))
    }

    func testIsGreaterThanOrEqualToLanguageVersion() {
        let parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.996)), andRootElement: GDataXMLElement())
        XCTAssertTrue(parserContext!.isGreaterThanOrEqual(toLanguageVersion: 0.996))
        XCTAssertTrue(parserContext!.isGreaterThanOrEqual(toLanguageVersion: 0.96))
        XCTAssertFalse(parserContext!.isGreaterThanOrEqual(toLanguageVersion: 0.997))
        XCTAssertTrue(parserContext!.isGreaterThanOrEqual(toLanguageVersion: 0.995))
    }

    func testIsGreaterThanLanguageVersion() {
        let parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.9994)), andRootElement: GDataXMLElement())
        XCTAssertFalse(parserContext!.isGreaterThanLanguageVersion(0.9994))
        XCTAssertTrue(parserContext!.isGreaterThanLanguageVersion(0.994))
        XCTAssertFalse(parserContext!.isGreaterThanLanguageVersion(0.99994))
        XCTAssertFalse(parserContext!.isGreaterThanLanguageVersion(0.9995))
    }

    func testIsSmallerThanOrEqualToLanguageVersion() {
        let parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(0.9992)), andRootElement: GDataXMLElement())
        XCTAssertTrue(parserContext!.isSmallerThanOrEqual(toLanguageVersion: 0.9992))
        XCTAssertFalse(parserContext!.isSmallerThanOrEqual(toLanguageVersion: 0.96))
        XCTAssertFalse(parserContext!.isSmallerThanOrEqual(toLanguageVersion: 0.9991))
        XCTAssertTrue(parserContext!.isSmallerThanOrEqual(toLanguageVersion: 0.9993))
    }

    func testIsSmallerThanLanguageVersion() {
        let parserContext = CBXMLParserContext(languageVersion: CGFloat(Float32(1.04)), andRootElement: GDataXMLElement())
        XCTAssertFalse(parserContext!.isSmallerThanLanguageVersion(1.04))
        XCTAssertFalse(parserContext!.isSmallerThanLanguageVersion(1.004))
        XCTAssertFalse(parserContext!.isSmallerThanLanguageVersion(1.03))
        XCTAssertTrue(parserContext!.isSmallerThanLanguageVersion(1.05))
    }
}
