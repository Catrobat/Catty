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

final class HeadTopSensorTest: XCTestCase {

    var headTopXSensor: HeadTopXSensor!
    var headTopYSensor: HeadTopYSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.headTopXSensor = HeadTopXSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
        self.headTopYSensor = HeadTopYSensor(stageSize: stageSize, visualDetectionManagerGetter: { [ weak self ] in self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.headTopXSensor = nil
        self.headTopYSensor = nil
        super.tearDown()
    }

    func testDefaultRawValue() {
        let headTopXSensor = HeadTopXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: headTopXSensor).defaultRawValue, headTopXSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: headTopXSensor).defaultRawValue, headTopXSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        let headTopYSensor = HeadTopXSensor(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: headTopYSensor).defaultRawValue, headTopYSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: headTopYSensor).defaultRawValue, headTopYSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testRawValue() {
        self.visualDetectionManagerMock.faceLandmarkPositionRatioDictionary[HeadTopXSensor.tag] = 0
        XCTAssertEqual(0, self.headTopXSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0, self.headTopXSensor.rawValue(landscapeMode: true))

        self.visualDetectionManagerMock.faceLandmarkPositionRatioDictionary[HeadTopYSensor.tag] = 0.95
        XCTAssertEqual(0.95, self.headTopYSensor.rawValue(landscapeMode: false))
        XCTAssertEqual(0.95, self.headTopYSensor.rawValue(landscapeMode: true))
    }

    func testConvertToStandardized() {
        XCTAssertEqual(Double(stageSize.width * 0.02) - Double(stageSize.width / 2), headTopXSensor.convertToStandardized(rawValue: 0.02))
        XCTAssertEqual(Double(stageSize.width * 0.45) - Double(stageSize.width / 2), headTopXSensor.convertToStandardized(rawValue: 0.45))
        XCTAssertEqual(Double(stageSize.width * 0.93) - Double(stageSize.width / 2), headTopXSensor.convertToStandardized(rawValue: 0.93))
        XCTAssertEqual(Double(stageSize.width / 2), headTopXSensor.convertToStandardized(rawValue: 1.0))

        XCTAssertEqual(Double(stageSize.height * 0.01) - Double(stageSize.height / 2), headTopYSensor.convertToStandardized(rawValue: 0.01))
        XCTAssertEqual(Double(stageSize.height * 0.4) - Double(stageSize.height / 2), headTopYSensor.convertToStandardized(rawValue: 0.4))
        XCTAssertEqual(Double(stageSize.height * 0.95) - Double(stageSize.height / 2), headTopYSensor.convertToStandardized(rawValue: 0.95))
        XCTAssertEqual(Double(stageSize.height / 2), headTopYSensor.convertToStandardized(rawValue: 1.0))
    }

    func testStandardizedValue() {
        var convertToStandardizedValue = headTopXSensor.convertToStandardized(rawValue: headTopXSensor.rawValue(landscapeMode: false))
        var standardizedValue = headTopXSensor.standardizedValue(landscapeMode: false)
        var convertToStandardizedValueLandscape = headTopXSensor.convertToStandardized(rawValue: headTopXSensor.rawValue(landscapeMode: true))
        var standardizedValueLandscape = headTopXSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)

        convertToStandardizedValue = headTopYSensor.convertToStandardized(rawValue: headTopYSensor.rawValue(landscapeMode: false))
        standardizedValue = headTopYSensor.standardizedValue(landscapeMode: false)
        convertToStandardizedValueLandscape = headTopYSensor.convertToStandardized(rawValue: headTopYSensor.rawValue(landscapeMode: true))
        standardizedValueLandscape = headTopYSensor.standardizedValue(landscapeMode: true)
        XCTAssertEqual(convertToStandardizedValue, standardizedValue)
        XCTAssertEqual(convertToStandardizedValueLandscape, standardizedValueLandscape)
    }

    func testTag() {
        XCTAssertEqual("HEAD_TOP_X", headTopXSensor.tag())
        XCTAssertEqual("HEAD_TOP_Y", headTopYSensor.tag())
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.faceDetection, type(of: headTopXSensor).requiredResource)
        XCTAssertEqual(ResourceType.faceDetection, type(of: headTopYSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = headTopXSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: headTopXSensor).position, subsection: .pose), sections.first)

        sections = headTopYSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: headTopYSensor).position, subsection: .pose), sections.first)
    }
}
