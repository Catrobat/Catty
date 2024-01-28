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

final class NoseSensorTest: XCTestCase {

    var noseXSensor: NoseXSensor!
    var noseYSensor: NoseYSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.noseXSensor = NoseXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
        self.noseYSensor = NoseYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.noseXSensor = nil
        self.noseYSensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let noseXSensor = NoseXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: noseXSensor).defaultRawValue, noseXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: noseXSensor).defaultRawValue, noseXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let noseYSensor = NoseYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: noseYSensor).defaultRawValue, noseYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: noseYSensor).defaultRawValue, noseYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.visualDetectionManagerMock.faceLandmarkPositionRatioDictionary[NoseXSensor.tag] = 0
        XCTAssertEqual(0, self.noseXSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.noseXSensor.rawValue(landscapeMode: true))

        self.visualDetectionManagerMock.faceLandmarkPositionRatioDictionary[NoseYSensor.tag] = 0.95
        XCTAssertEqual(0.95, self.noseYSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0.95, self.noseYSensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), noseXSensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), noseXSensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), noseXSensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), noseXSensor.convertToStandardized(rawValue: 1.0))

        XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), noseYSensor.convertToStandardized(rawValue: 0.01))
        XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), noseYSensor.convertToStandardized(rawValue: 0.4))
        XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), noseYSensor.convertToStandardized(rawValue: 0.95))
        XCTAssertEqual(Double(stageSize.height / 2), noseYSensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        var convertToStandardizedValue = noseXSensor.convertToStandardized(rawValue: noseXSensor.rawValue(landscapeMode: false))
        var standardizedValue = noseXSensor.standardizedValue(landscapeMode: false)
        var convertToStandardizedValueLandscape = noseXSensor.convertToStandardized(rawValue: noseXSensor.rawValue(landscapeMode: true))
        var standardizedValueLandscape = noseXSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)

        convertToStandardizedValue = noseYSensor.convertToStandardized(rawValue: noseYSensor.rawValue(landscapeMode: false))
        standardizedValue = noseYSensor.standardizedValue(landscapeMode: false)
        convertToStandardizedValueLandscape = noseYSensor.convertToStandardized(rawValue: noseYSensor.rawValue(landscapeMode: true))
        standardizedValueLandscape = noseYSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("NOSE_X", noseXSensor.tag())
        XCTAssertEqual("NOSE_Y", noseYSensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: noseXSensor).requiredResource)
        XCTAssertEqual(ResourceType.faceDetection, type(of: noseYSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = noseXSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: noseXSensor).position, subsection: .pose), sections.first)

        sections = noseYSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: noseYSensor).position, subsection: .pose), sections.first)
    }
}
