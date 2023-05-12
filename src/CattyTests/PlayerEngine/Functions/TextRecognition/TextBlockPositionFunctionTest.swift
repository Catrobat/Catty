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

class TextBlockPositionFunctionTest: XCTestCase {
    private enum SensorType { case x, y, size }
    var textBlockXFunction: TextBlockXFunction!
    var textBlockYFunction: TextBlockYFunction!
    var textBlockSizeFunction: TextBlockSizeFunction!
    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)

        self.textBlockXFunction = TextBlockXFunction(stageSize: stageSize, visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock })
        self.textBlockYFunction = TextBlockYFunction(stageSize: stageSize, visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock })
        self.textBlockSizeFunction = TextBlockSizeFunction(stageSize: stageSize, visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock })

    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.textBlockXFunction = nil
        self.textBlockYFunction = nil
        super.tearDown()
    }

    func testDefaultValue() {
        visualDetectionManagerMock.setTextBlockPositionRecognized(at: CGPoint(x: 0.3, y: 0.45), withSizeRatio: 0.5)

        XCTAssertEqual(type(of: textBlockXFunction).defaultValue, textBlockXFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: textBlockXFunction).defaultValue, textBlockXFunction.value(parameter: nil), accuracy: Double.epsilon)
        let textBlockXFunction = TextBlockXFunction(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: textBlockXFunction).defaultValue, textBlockXFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: textBlockYFunction).defaultValue, textBlockXFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: textBlockYFunction).defaultValue, textBlockXFunction.value(parameter: nil), accuracy: Double.epsilon)
        let textBlockYFunction = TextBlockYFunction(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: textBlockYFunction).defaultValue, textBlockYFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: textBlockSizeFunction).defaultValue, textBlockSizeFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: textBlockSizeFunction).defaultValue, textBlockSizeFunction.value(parameter: nil), accuracy: Double.epsilon)
        let textBlockSizeFunction = TextBlockYFunction(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: textBlockSizeFunction).defaultValue, textBlockSizeFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
    }

    func testValue() {
        let points = [CGPoint(x: 0.3, y: 0.45), CGPoint(x: 0.5, y: 0.2), CGPoint(x: 0.6, y: 0.1)]
        let sizeRatios = [0.5, 0.99, 0.12]

        for (index, point) in points.enumerated() {
            visualDetectionManagerMock.setTextBlockPositionRecognized(at: point, withSizeRatio: sizeRatios[index])
        }

        XCTAssertEqual(type(of: textBlockXFunction).defaultValue, textBlockXFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: textBlockYFunction).defaultValue, textBlockYFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: textBlockSizeFunction).defaultValue, textBlockSizeFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(convertRatios(ratioValue: points[0].x, type: .x), textBlockXFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(ratioValue: points[0].y, type: .y), textBlockYFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(ratioValue: sizeRatios[0], type: .size), textBlockSizeFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(convertRatios(ratioValue: points[2].x, type: .x), textBlockXFunction.value(parameter: 3.4 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(ratioValue: points[2].y, type: .y), textBlockYFunction.value(parameter: 3.4 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(ratioValue: sizeRatios[2], type: .size), textBlockSizeFunction.value(parameter: 3.4 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: textBlockXFunction).defaultValue, textBlockXFunction.value(parameter: 4 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: textBlockYFunction).defaultValue, textBlockYFunction.value(parameter: 4 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: textBlockSizeFunction).defaultValue, textBlockSizeFunction.value(parameter: 4 as AnyObject), accuracy: Double.epsilon)
    }

    func testParameter() {
        XCTAssertEqual(.number(defaultValue: 1), textBlockXFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), textBlockYFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), textBlockSizeFunction.firstParameter())
    }

    func testTag() {
        XCTAssertEqual("TEXT_BLOCK_X", type(of: textBlockXFunction).tag)
        XCTAssertEqual("TEXT_BLOCK_Y", type(of: textBlockYFunction).tag)
        XCTAssertEqual("TEXT_BLOCK_SIZE", type(of: textBlockSizeFunction).tag)
    }

    func testName() {
        XCTAssertEqual(kUIFEFunctionTextBlockX, type(of: textBlockXFunction).name)
        XCTAssertEqual(kUIFEFunctionTextBlockY, type(of: textBlockYFunction).name)
        XCTAssertEqual(kUIFEFunctionTextBlockSize, type(of: textBlockSizeFunction).name)
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.textRecognition, type(of: textBlockXFunction).requiredResource)
        XCTAssertEqual(ResourceType.textRecognition, type(of: textBlockYFunction).requiredResource)
        XCTAssertEqual(ResourceType.textRecognition, type(of: textBlockSizeFunction).requiredResource)
    }

    func testIsIdempotent() {
        XCTAssertFalse(type(of: textBlockXFunction).isIdempotent)
        XCTAssertFalse(type(of: textBlockYFunction).isIdempotent)
        XCTAssertFalse(type(of: textBlockSizeFunction).isIdempotent)
    }

    func testFormulaEditorSections() {
        var sections = textBlockXFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: textBlockXFunction).position, subsection: .textRecognition), sections.first)

        sections = textBlockYFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: textBlockYFunction).position, subsection: .textRecognition), sections.first)

        sections = textBlockSizeFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: textBlockSizeFunction).position, subsection: .textRecognition), sections.first)
    }

    private func convertRatios(ratioValue: Double, type: SensorType) -> Double {
        switch type {
        case .x:
            return stageSize.width * ratioValue - stageSize.width / 2.0
        case .y:
            return stageSize.height * ratioValue - stageSize.height / 2.0
        case .size:
            let textBlockSize = ratioValue * 100
            if textBlockSize > 100 {
                return 100
            }
            if textBlockSize < 0 {
                return 0
            }
            return textBlockSize
        }
    }
}
