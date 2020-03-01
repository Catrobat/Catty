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

final class LoudnessSensorTest: XCTestCase {

    var audioManager: AudioManagerMock!
    var sensor: LoudnessSensor!

    override func setUp() {
        super.setUp()
        audioManager = AudioManagerMock()
        sensor = LoudnessSensor { [weak self] in self?.audioManager }
    }

    override func tearDown() {
        sensor = nil
        audioManager = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let sensor = LoudnessSensor { nil }
        XCTAssertEqual(type(of: sensor).defaultRawValue, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testRawValue() {
        audioManager.mockedLoudnessInDecibels = 3
        XCTAssertEqual(3, sensor.rawValue(), accuracy: Double.epsilon)

        audioManager.mockedLoudnessInDecibels = -50
        XCTAssertEqual(-50, sensor.rawValue(), accuracy: Double.epsilon)

        audioManager.mockedLoudnessInDecibels = 10.786
        XCTAssertEqual(10.786, sensor.rawValue(), accuracy: Double.epsilon)
    }

    func testConvertToStandardized() {
        // background noise
        XCTAssertEqual(1, sensor.convertToStandardized(rawValue: -40), accuracy: Double.epsilon)

        let whisper = sensor.convertToStandardized(rawValue: -24)
        XCTAssertEqual(6.3095, whisper, accuracy: Double.epsilon)

        let normalVoice = sensor.convertToStandardized(rawValue: -15)
        XCTAssertEqual(17.7827, normalVoice, accuracy: Double.epsilon)

        let shouting = sensor.convertToStandardized(rawValue: -0.99)
        XCTAssertEqual(89.2277, shouting, accuracy: Double.epsilon)
    }

    func testTag() {
        XCTAssertEqual("LOUDNESS", sensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.loudness, type(of: sensor).requiredResource)
    }

    func testFormulaEditorSections() {
        let sections = sensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.device(position: type(of: sensor).position), sections.first)
    }
}
