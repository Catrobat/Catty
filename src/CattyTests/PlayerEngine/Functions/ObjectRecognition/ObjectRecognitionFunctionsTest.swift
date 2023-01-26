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

class ObjectRecognitionFunctionsTest: XCTestCase {
    private enum SensorType { case x, y, width, height }
    var idOfDetectedObjectFunction: IDOfDetectedObjectFunction!
    var objectWithIDVisibleFunction: ObjectWithIDVisibleFunction!
    var labelOfObjectWithIDFunction: LabelOfObjectWithIDFunction!
    var xOfObjectWithIDFunction: XOfObjectWithIDFunction!
    var yOfObjectWithIDFunction: YOfObjectWithIDFunction!
    var widthOfObjectWithIDFunction: WidthOfObjectWithIDFunction!
    var heightOfObjectWithIDFunction: HeightOfObjectWithIDFunction!

    var visualDetectionManagerMock: VisualDetectionManagerMock!
    var stageSize: CGSize!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()
        self.stageSize = CGSize(width: 1080, height: 1920)
        self.visualDetectionManagerMock.setVisualDetectionFrameSize(stageSize)

        self.objectWithIDVisibleFunction = ObjectWithIDVisibleFunction(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
        self.idOfDetectedObjectFunction = IDOfDetectedObjectFunction(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
        self.labelOfObjectWithIDFunction = LabelOfObjectWithIDFunction(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
        self.xOfObjectWithIDFunction = XOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
        self.yOfObjectWithIDFunction = YOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
        self.widthOfObjectWithIDFunction = WidthOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
        self.heightOfObjectWithIDFunction = HeightOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.stageSize = nil
        self.idOfDetectedObjectFunction = nil
        self.objectWithIDVisibleFunction = nil
        self.labelOfObjectWithIDFunction = nil
        self.xOfObjectWithIDFunction = nil
        self.yOfObjectWithIDFunction = nil
        self.widthOfObjectWithIDFunction = nil
        self.heightOfObjectWithIDFunction = nil
        super.tearDown()
    }

    func testDefaultValue() {
        visualDetectionManagerMock.addRecognizedObject(label: "cup", boundingBox: CGRect.zero)

        XCTAssertEqual(type(of: idOfDetectedObjectFunction).defaultValue, idOfDetectedObjectFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: idOfDetectedObjectFunction).defaultValue, idOfDetectedObjectFunction.value(parameter: nil), accuracy: Double.epsilon)
        let idOfDetectedObjectFunction = IDOfDetectedObjectFunction(visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: idOfDetectedObjectFunction).defaultValue, idOfDetectedObjectFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: objectWithIDVisibleFunction).defaultValue, objectWithIDVisibleFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: objectWithIDVisibleFunction).defaultValue, objectWithIDVisibleFunction.value(parameter: nil), accuracy: Double.epsilon)
        let objectWithIDVisibleFunction = ObjectWithIDVisibleFunction(visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: objectWithIDVisibleFunction).defaultValue, objectWithIDVisibleFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: labelOfObjectWithIDFunction).defaultValue, labelOfObjectWithIDFunction.value(parameter: "invalidParameter" as AnyObject))
        XCTAssertEqual(type(of: labelOfObjectWithIDFunction).defaultValue, labelOfObjectWithIDFunction.value(parameter: nil))
        let labelOfObjectWithIDFunction = LabelOfObjectWithIDFunction(visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: labelOfObjectWithIDFunction).defaultValue, labelOfObjectWithIDFunction.value(parameter: 1 as AnyObject))

        XCTAssertEqual(type(of: xOfObjectWithIDFunction).defaultValue, xOfObjectWithIDFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: xOfObjectWithIDFunction).defaultValue, xOfObjectWithIDFunction.value(parameter: nil), accuracy: Double.epsilon)
        let xOfObjectWithIDFunction = XOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: xOfObjectWithIDFunction).defaultValue, xOfObjectWithIDFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: yOfObjectWithIDFunction).defaultValue, yOfObjectWithIDFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: yOfObjectWithIDFunction).defaultValue, yOfObjectWithIDFunction.value(parameter: nil), accuracy: Double.epsilon)
        let yOfObjectWithIDFunction = YOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: yOfObjectWithIDFunction).defaultValue, yOfObjectWithIDFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: widthOfObjectWithIDFunction).defaultValue, widthOfObjectWithIDFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: widthOfObjectWithIDFunction).defaultValue, widthOfObjectWithIDFunction.value(parameter: nil), accuracy: Double.epsilon)
        let widthOfObjectWithIDFunction = WidthOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: widthOfObjectWithIDFunction).defaultValue, widthOfObjectWithIDFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: heightOfObjectWithIDFunction).defaultValue, heightOfObjectWithIDFunction.value(parameter: "invalidParameter" as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: heightOfObjectWithIDFunction).defaultValue, heightOfObjectWithIDFunction.value(parameter: nil), accuracy: Double.epsilon)
        let heightOfObjectWithIDFunction = HeightOfObjectWithIDFunction(stageSize: stageSize, visualDetectionManagerGetter: { nil })
        XCTAssertEqual(type(of: heightOfObjectWithIDFunction).defaultValue, heightOfObjectWithIDFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
    }

    func testValue() {
        let boundingBoxes = [CGRect(x: 0.5, y: 0.5, width: 0.1, height: 0.1), CGRect(x: 0, y: 0.3, width: 0.45, height: 0.11)]
        visualDetectionManagerMock.addRecognizedObject(label: "keyboard", boundingBox: boundingBoxes[0])
        visualDetectionManagerMock.addRecognizedObject(label: "mouse", boundingBox: boundingBoxes[1])

        XCTAssertEqual(type(of: idOfDetectedObjectFunction).defaultValue, idOfDetectedObjectFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: objectWithIDVisibleFunction).defaultValue, objectWithIDVisibleFunction.value(parameter: -1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: labelOfObjectWithIDFunction).defaultValue, labelOfObjectWithIDFunction.value(parameter: -1 as AnyObject))
        XCTAssertEqual(type(of: xOfObjectWithIDFunction).defaultValue, xOfObjectWithIDFunction.value(parameter: -1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: yOfObjectWithIDFunction).defaultValue, yOfObjectWithIDFunction.value(parameter: -1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: widthOfObjectWithIDFunction).defaultValue, widthOfObjectWithIDFunction.value(parameter: -1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: heightOfObjectWithIDFunction).defaultValue, heightOfObjectWithIDFunction.value(parameter: -1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(0.0, idOfDetectedObjectFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(1.0, objectWithIDVisibleFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual("keyboard", labelOfObjectWithIDFunction.value(parameter: 0 as AnyObject))
        XCTAssertEqual(convertRatios(boundingBox: boundingBoxes[0], type: .x), xOfObjectWithIDFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(boundingBox: boundingBoxes[0], type: .y), yOfObjectWithIDFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(boundingBox: boundingBoxes[0], type: .width), widthOfObjectWithIDFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(boundingBox: boundingBoxes[0], type: .height), heightOfObjectWithIDFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(1.0, idOfDetectedObjectFunction.value(parameter: 2 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(1.0, objectWithIDVisibleFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual("mouse", labelOfObjectWithIDFunction.value(parameter: 1 as AnyObject))
        XCTAssertEqual(convertRatios(boundingBox: boundingBoxes[1], type: .x), xOfObjectWithIDFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(boundingBox: boundingBoxes[1], type: .y), yOfObjectWithIDFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(boundingBox: boundingBoxes[1], type: .width), widthOfObjectWithIDFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(convertRatios(boundingBox: boundingBoxes[1], type: .height), heightOfObjectWithIDFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)

        XCTAssertEqual(type(of: idOfDetectedObjectFunction).defaultValue, idOfDetectedObjectFunction.value(parameter: 3 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: objectWithIDVisibleFunction).defaultValue, objectWithIDVisibleFunction.value(parameter: 2 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: labelOfObjectWithIDFunction).defaultValue, labelOfObjectWithIDFunction.value(parameter: 2 as AnyObject))
        XCTAssertEqual(type(of: xOfObjectWithIDFunction).defaultValue, xOfObjectWithIDFunction.value(parameter: 2 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: yOfObjectWithIDFunction).defaultValue, yOfObjectWithIDFunction.value(parameter: 2 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: widthOfObjectWithIDFunction).defaultValue, widthOfObjectWithIDFunction.value(parameter: 2 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: heightOfObjectWithIDFunction).defaultValue, heightOfObjectWithIDFunction.value(parameter: 2 as AnyObject), accuracy: Double.epsilon)
    }

    func testParameter() {
        XCTAssertEqual(.number(defaultValue: 1), idOfDetectedObjectFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), objectWithIDVisibleFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), labelOfObjectWithIDFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), xOfObjectWithIDFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), yOfObjectWithIDFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), heightOfObjectWithIDFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), widthOfObjectWithIDFunction.firstParameter())
    }

    func testTag() {
        XCTAssertEqual("ID_OF_DETECTED_OBJECT", type(of: idOfDetectedObjectFunction).tag)
        XCTAssertEqual("OBJECT_WITH_ID_VISIBLE", type(of: objectWithIDVisibleFunction).tag)
        XCTAssertEqual("LABEL_OF_OBJECT_WITH_ID", type(of: labelOfObjectWithIDFunction).tag)
        XCTAssertEqual("X_OF_OBJECT_WITH_ID", type(of: xOfObjectWithIDFunction).tag)
        XCTAssertEqual("Y_OF_OBJECT_WITH_ID", type(of: yOfObjectWithIDFunction).tag)
        XCTAssertEqual("WIDTH_OF_OBJECT_WITH_ID", type(of: widthOfObjectWithIDFunction).tag)
        XCTAssertEqual("HEIGHT_OF_OBJECT_WITH_ID", type(of: heightOfObjectWithIDFunction).tag)
    }

    func testName() {
        XCTAssertEqual(kUIFEFunctionIDOfDetectedObject, type(of: idOfDetectedObjectFunction).name)
        XCTAssertEqual(kUIFEFunctionObjectWithIDVisible, type(of: objectWithIDVisibleFunction).name)
        XCTAssertEqual(kUIFEFunctionLabelOfObjectWithID, type(of: labelOfObjectWithIDFunction).name)
        XCTAssertEqual(kUIFEFunctionXOfObjectWithID, type(of: xOfObjectWithIDFunction).name)
        XCTAssertEqual(kUIFEFunctionYOfObjectWithID, type(of: yOfObjectWithIDFunction).name)
        XCTAssertEqual(kUIFEFunctionWidthOfObjectWithID, type(of: widthOfObjectWithIDFunction).name)
        XCTAssertEqual(kUIFEFunctionHeightOfObjectWithID, type(of: heightOfObjectWithIDFunction).name)
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.objectRecognition, type(of: idOfDetectedObjectFunction).requiredResource)
        XCTAssertEqual(ResourceType.objectRecognition, type(of: objectWithIDVisibleFunction).requiredResource)
        XCTAssertEqual(ResourceType.objectRecognition, type(of: labelOfObjectWithIDFunction).requiredResource)
        XCTAssertEqual(ResourceType.objectRecognition, type(of: xOfObjectWithIDFunction).requiredResource)
        XCTAssertEqual(ResourceType.objectRecognition, type(of: yOfObjectWithIDFunction).requiredResource)
        XCTAssertEqual(ResourceType.objectRecognition, type(of: widthOfObjectWithIDFunction).requiredResource)
        XCTAssertEqual(ResourceType.objectRecognition, type(of: heightOfObjectWithIDFunction).requiredResource)
    }

    func testIsIdempotent() {
        XCTAssertFalse(type(of: idOfDetectedObjectFunction).isIdempotent)
        XCTAssertFalse(type(of: objectWithIDVisibleFunction).isIdempotent)
        XCTAssertFalse(type(of: labelOfObjectWithIDFunction).isIdempotent)
        XCTAssertFalse(type(of: xOfObjectWithIDFunction).isIdempotent)
        XCTAssertFalse(type(of: yOfObjectWithIDFunction).isIdempotent)
        XCTAssertFalse(type(of: widthOfObjectWithIDFunction).isIdempotent)
        XCTAssertFalse(type(of: heightOfObjectWithIDFunction).isIdempotent)
    }

    func testFormulaEditorSections() {
        var sections = idOfDetectedObjectFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: idOfDetectedObjectFunction).position, subsection: .objectDetection), sections.first)

        sections = objectWithIDVisibleFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: objectWithIDVisibleFunction).position, subsection: .objectDetection), sections.first)

        sections = labelOfObjectWithIDFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: labelOfObjectWithIDFunction).position, subsection: .objectDetection), sections.first)

        sections = xOfObjectWithIDFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: xOfObjectWithIDFunction).position, subsection: .objectDetection), sections.first)

        sections = yOfObjectWithIDFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: yOfObjectWithIDFunction).position, subsection: .objectDetection), sections.first)

        sections = widthOfObjectWithIDFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: widthOfObjectWithIDFunction).position, subsection: .objectDetection), sections.first)

        sections = heightOfObjectWithIDFunction.formulaEditorSections()
        XCTAssertEqual(1, sections.count)
        XCTAssertEqual(.sensors(position: type(of: heightOfObjectWithIDFunction).position, subsection: .objectDetection), sections.first)

    }

    private func convertRatios(boundingBox: CGRect, type: SensorType) -> Double {
        let scaledPreviewWidthRatio = stageSize.height / visualDetectionManagerMock.visualDetectionFrameSize!.height
        switch type {
        case .x:
            let objectPositionX = boundingBox.origin.x + boundingBox.width / 2.0
            return (stageSize.width * objectPositionX - stageSize.width / 2.0) * scaledPreviewWidthRatio
        case .y:
            let objectPositionY = boundingBox.origin.y + boundingBox.height / 2.0
            return stageSize.height * objectPositionY - stageSize.height / 2.0
        case .width:
            return stageSize.width * boundingBox.width * scaledPreviewWidthRatio
        case .height:
            return stageSize.height * boundingBox.height
        }
    }
}
