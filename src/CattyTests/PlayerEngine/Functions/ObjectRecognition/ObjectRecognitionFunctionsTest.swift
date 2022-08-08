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

class ObjectRecognitionFunctionsTest: XCTestCase {
    var idOfDetectedObjectFunction: IDOfDetectedObjectFunction!
    var objectWithIDVisibleFunction: ObjectWithIDVisibleFunction!
    var labelOfObjectWithIDFunction: LabelOfObjectWithIDFunction!
    var visualDetectionManagerMock: VisualDetectionManagerMock!

    override func setUp() {
        super.setUp()
        self.visualDetectionManagerMock = VisualDetectionManagerMock()

        self.objectWithIDVisibleFunction = ObjectWithIDVisibleFunction(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
        self.idOfDetectedObjectFunction = IDOfDetectedObjectFunction(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
        self.labelOfObjectWithIDFunction = LabelOfObjectWithIDFunction(visualDetectionManagerGetter: { [weak self] in
            self?.visualDetectionManagerMock
        })
    }

    override func tearDown() {
        self.visualDetectionManagerMock = nil
        self.idOfDetectedObjectFunction = nil
        self.objectWithIDVisibleFunction = nil
        self.labelOfObjectWithIDFunction = nil
        super.tearDown()
    }

    func testDefaultValue() {
        visualDetectionManagerMock.addRecognizedObject(label: "cup")

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
    }

    func testValue() {
        visualDetectionManagerMock.addRecognizedObject(label: "keyboard")
        visualDetectionManagerMock.addRecognizedObject(label: "mouse")

        XCTAssertEqual(type(of: idOfDetectedObjectFunction).defaultValue, idOfDetectedObjectFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: objectWithIDVisibleFunction).defaultValue, objectWithIDVisibleFunction.value(parameter: -1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: labelOfObjectWithIDFunction).defaultValue, labelOfObjectWithIDFunction.value(parameter: -1 as AnyObject))

        XCTAssertEqual(0.0, idOfDetectedObjectFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(1.0, objectWithIDVisibleFunction.value(parameter: 0 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual("keyboard", labelOfObjectWithIDFunction.value(parameter: 0 as AnyObject))

        XCTAssertEqual(1.0, idOfDetectedObjectFunction.value(parameter: 2 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(1.0, objectWithIDVisibleFunction.value(parameter: 1 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual("mouse", labelOfObjectWithIDFunction.value(parameter: 1 as AnyObject))

        XCTAssertEqual(type(of: idOfDetectedObjectFunction).defaultValue, idOfDetectedObjectFunction.value(parameter: 3 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: objectWithIDVisibleFunction).defaultValue, objectWithIDVisibleFunction.value(parameter: 2 as AnyObject), accuracy: Double.epsilon)
        XCTAssertEqual(type(of: labelOfObjectWithIDFunction).defaultValue, labelOfObjectWithIDFunction.value(parameter: 2 as AnyObject))
    }

    func testParameter() {
        XCTAssertEqual(.number(defaultValue: 1), idOfDetectedObjectFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), objectWithIDVisibleFunction.firstParameter())
        XCTAssertEqual(.number(defaultValue: 1), labelOfObjectWithIDFunction.firstParameter())
    }

    func testTag() {
        XCTAssertEqual("ID_OF_DETECTED_OBJECT", type(of: idOfDetectedObjectFunction).tag)
        XCTAssertEqual("OBJECT_WITH_ID_VISIBLE", type(of: objectWithIDVisibleFunction).tag)
        XCTAssertEqual("LABEL_OF_OBJECT_WITH_ID", type(of: labelOfObjectWithIDFunction).tag)
    }

    func testName() {
        XCTAssertEqual(kUIFEFunctionIDOfDetectedObject, type(of: idOfDetectedObjectFunction).name)
        XCTAssertEqual(kUIFEFunctionObjectWithIDVisible, type(of: objectWithIDVisibleFunction).name)
        XCTAssertEqual(kUIFEFunctionLabelOfObjectWithID, type(of: labelOfObjectWithIDFunction).name)
    }

    func testRequiredResources() {
        XCTAssertEqual(ResourceType.objectRecognition, type(of: idOfDetectedObjectFunction).requiredResource)
        XCTAssertEqual(ResourceType.objectRecognition, type(of: objectWithIDVisibleFunction).requiredResource)
        XCTAssertEqual(ResourceType.objectRecognition, type(of: labelOfObjectWithIDFunction).requiredResource)
    }

    func testIsIdempotent() {
        XCTAssertFalse(type(of: idOfDetectedObjectFunction).isIdempotent)
        XCTAssertFalse(type(of: objectWithIDVisibleFunction).isIdempotent)
        XCTAssertFalse(type(of: labelOfObjectWithIDFunction).isIdempotent)
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
    }
}
