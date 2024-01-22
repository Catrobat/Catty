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

final class UserLanguageTest: XCTestCase {

    var sensor: UserLanguageSensor!

    override func setUp() {
        super.setUp()
        sensor = UserLanguageSensor()
    }

    override func tearDown() {
        sensor = nil
        super.tearDown()
    }

    func testTag() {
        XCTAssertEqual("USER_LANGUAGE", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.noResources, type(of: sensor).requiredResource)
    }

    func testRawValue() {
        let expectedLanguage = Locale.preferredLanguages[0]

        XCTAssertEqual(expectedLanguage, sensor.rawValue(landscapeMode: false))
        XCTAssertEqual(expectedLanguage, sensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual("en-GB", sensor.convertToStandardized(rawValue: "en-GB"))
        XCTAssertEqual("de-DE", sensor.convertToStandardized(rawValue: "de-DE"))
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: sensor).position, subsection: .device), sections.first)
    }
}
