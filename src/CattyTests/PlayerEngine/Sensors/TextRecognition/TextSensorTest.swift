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

class TextSensorTest: XCTestCase {
    var textFromCameraSensor: TextFromCameraSensor!
    var textBlocksNumberSensor: TextBlocksNumberSensor!
    var visualDetectionManagerMock: VisualDetectionManagerMock!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()

        self.textFromCameraSensor = TextFromCameraSensor(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock })
        self.textBlocksNumberSensor = TextBlocksNumberSensor(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.textFromCameraSensor = nil
        self.textBlocksNumberSensor = nil
        super.tearDown()
    }

    func testDefaultValue() {
        let textFromCameraSensor = TextFromCameraSensor(visualDetectionManagerGetter: { nil })
        XCTAssertEqual("", textFromCameraSensor.rawValue(landscapeMode: true))
        XCTAssertEqual("", textFromCameraSensor.rawValue(landscapeMode: false))

        let textBlocksNumberSensor = TextBlocksNumberSensor(visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: textBlocksNumberSensor).defaultRawValue, textBlocksNumberSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: textBlocksNumberSensor).defaultRawValue, textBlocksNumberSensor.rawValue(landscapeMode: false), accuracy: Double.epsilon)
    }

    func testValue() {
        XCTAssertEqual("", textFromCameraSensor.rawValue(landscapeMode: true))
        XCTAssertEqual(type(of: textBlocksNumberSensor).defaultRawValue, textBlocksNumberSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        visualDetectionManagerMock.setTextBlockTextRecognized(text: "Das ist ein Text.", language: "de")

        XCTAssertEqual("Das ist ein Text.", textFromCameraSensor.rawValue(landscapeMode: true))
        XCTAssertEqual(1, textBlocksNumberSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)

        visualDetectionManagerMock.setTextBlockTextRecognized(text: "This is text.", language: "en")

        XCTAssertEqual("Das ist ein Text. This is text.", textFromCameraSensor.rawValue(landscapeMode: true))
        XCTAssertEqual(2, textBlocksNumberSensor.rawValue(landscapeMode: true), accuracy: Double.epsilon)
    }

    func testTag() {
        XCTAssertEqual("TEXT_FROM_CAMERA", type(of: textFromCameraSensor).tag)
        XCTAssertEqual("TEXT_BLOCKS_NUMBER", type(of: textBlocksNumberSensor).tag)
    }

    func testName() {
        XCTAssertEqual(kUIFESensorTextFromCamera, type(of: textFromCameraSensor).name)
        XCTAssertEqual(kUIFESensorTextBlocksNumber, type(of: textBlocksNumberSensor).name)
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.textRecognition, type(of: textFromCameraSensor).requiredResource)
        XCTAssertEqual(ResourceType.textRecognition, type(of: textBlocksNumberSensor).requiredResource)
    }

    func testFormulaEditorSections() {
        var sections = textFromCameraSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: textFromCameraSensor).position, subsection: .textRecognition), sections.first)

        sections = textBlocksNumberSensor.formulaEditorSections(for: SpriteObject())
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: textBlocksNumberSensor).position, subsection: .textRecognition), sections.first)
    }
}
