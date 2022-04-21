/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

final class IndexSensorTest: XCTestCase {

    var indexXSensor: LeftIndexKnuckleXSensor!
    var indexYSensor: LeftIndexKnuckleYSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.visualDetectionManagerMock.setVisualDetectionFrameSize(stageSize)
        self.indexXSensor = LeftIndexKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
        self.indexYSensor = LeftIndexKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.indexXSensor = nil
        self.indexYSensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let indexXSensor = LeftIndexKnuckleXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: indexXSensor).defaultRawValue, indexXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: indexXSensor).defaultRawValue, indexXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let indexYSensor = LeftIndexKnuckleYSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: indexYSensor).defaultRawValue, indexYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: indexYSensor).defaultRawValue, indexYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftIndexKnuckleXSensor.tag] = 0
        XCTAssertEqual(0, self.indexXSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.indexXSensor.rawValue(landscapeMode: true))

        self.visualDetectionManagerMock.handPosePositionRatioDictionary[LeftIndexKnuckleYSensor.tag] = 0.95
        XCTAssertEqual(0.95, self.indexYSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0.95, self.indexYSensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(type(of: indexXSensor).defaultRawValue, indexXSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), indexXSensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), indexXSensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), indexXSensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), indexXSensor.convertToStandardized(rawValue: 1.0))

        XCTAssertEqual(type(of: indexYSensor).defaultRawValue, indexYSensor.convertToStandardized(rawValue: 0))

        XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), indexYSensor.convertToStandardized(rawValue: 0.01))
        XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), indexYSensor.convertToStandardized(rawValue: 0.4))
        XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), indexYSensor.convertToStandardized(rawValue: 0.95))
        XCTAssertEqual(Double(stageSize.height / 2), indexYSensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        var convertToStandardizedValue = indexXSensor.convertToStandardized(rawValue: indexXSensor.rawValue(landscapeMode: false))
        var standardizedValue = indexXSensor.standardizedValue(landscapeMode: false)
        var standardizedValueLandscape = indexXSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)

        convertToStandardizedValue = indexYSensor.convertToStandardized(rawValue: indexYSensor.rawValue(landscapeMode: false))
        standardizedValue = indexYSensor.standardizedValue(landscapeMode: false)
        standardizedValueLandscape = indexYSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(standardizedValue, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("LEFT_INDEX_X", indexXSensor.tag())
        XCTAssertEqual("LEFT_INDEX_Y", indexYSensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: indexXSensor).requiredResource)
        XCTAssertEqual(ResourceType.faceDetection, type(of: indexYSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = indexXSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: indexXSensor).position, subsection: .pose), sections.first)

        sections = indexYSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: indexYSensor).position, subsection: .pose), sections.first)
    }
}
