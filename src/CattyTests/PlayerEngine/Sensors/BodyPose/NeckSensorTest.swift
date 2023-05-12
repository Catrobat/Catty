/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

final class NeckSensorTest: XCTestCase {

    var neckXSensor: NeckXSensor!
    var neckYSensor: NeckYSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.neckXSensor = NeckXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
        self.neckYSensor = NeckYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.neckXSensor = nil
        self.neckYSensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let neckXSensor = NeckXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: neckXSensor).defaultRawValue, neckXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: neckXSensor).defaultRawValue, neckXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let neckYSensor = NeckYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: neckYSensor).defaultRawValue, neckYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: neckYSensor).defaultRawValue, neckYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.visualDetectionManagerMock.bodyPosePositionRatioDictionary[NeckXSensor.tag] = 0
        XCTAssertEqual(0, self.neckXSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.neckXSensor.rawValue(landscapeMode: true))

        self.visualDetectionManagerMock.bodyPosePositionRatioDictionary[NeckYSensor.tag] = 0.95
        XCTAssertEqual(0.95, self.neckYSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0.95, self.neckYSensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), neckXSensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), neckXSensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), neckXSensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), neckXSensor.convertToStandardized(rawValue: 1.0))

        XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), neckYSensor.convertToStandardized(rawValue: 0.01))
        XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), neckYSensor.convertToStandardized(rawValue: 0.4))
        XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), neckYSensor.convertToStandardized(rawValue: 0.95))
        XCTAssertEqual(Double(stageSize.height / 2), neckYSensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        var convertToStandardizedValue = neckXSensor.convertToStandardized(rawValue: neckXSensor.rawValue(landscapeMode: false))
        var standardizedValue = neckXSensor.standardizedValue(landscapeMode: false)
        var convertToStandardizedValueLandscape = neckXSensor.convertToStandardized(rawValue: neckXSensor.rawValue(landscapeMode: true))
        var standardizedValueLandscape = neckXSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)

        convertToStandardizedValue = neckYSensor.convertToStandardized(rawValue: neckYSensor.rawValue(landscapeMode: false))
        standardizedValue = neckYSensor.standardizedValue(landscapeMode: false)
        convertToStandardizedValueLandscape = neckYSensor.convertToStandardized(rawValue: neckYSensor.rawValue(landscapeMode: true))
        standardizedValueLandscape = neckYSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("NECK_X", neckXSensor.tag())
        XCTAssertEqual("NECK_Y", neckYSensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.bodyPoseDetection, type(of: neckXSensor).requiredResource)
        XCTAssertEqual(ResourceType.bodyPoseDetection, type(of: neckYSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = neckXSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: neckXSensor).position, subsection: .pose), sections.first)

        sections = neckYSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: neckYSensor).position, subsection: .pose), sections.first)
    }
}
