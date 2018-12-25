/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

class FormulaEditorItemTest: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitWithFunction() {
        let expectedSection = FormulaEditorSection.math(position: 10)
        let function = ZeroParameterDoubleFunctionMock(tag: "tag", value: 1.0, formulaEditorSection: expectedSection)

        let item = FormulaEditorItem(function: function)
        XCTAssertEqual(function.nameWithParameters(), item.title)
        XCTAssertEqual(function.tag(), item.tag)
        XCTAssertEqual(1, item.sections.count)
        XCTAssertEqual(expectedSection, item.sections[0])
        XCTAssertNotNil(item.function)
        XCTAssertNil(item.sensor)
        XCTAssertNil(item.op)
    }

    func testInitWithSensor() {
        let expectedSection = FormulaEditorSection.object(position: 10)
        let sensor = SensorMock(tag: "tag", formulaEditorSection: expectedSection)

        let item = FormulaEditorItem(sensor: sensor, spriteObject: SpriteObjectMock())
        XCTAssertEqual(type(of: sensor).name, item.title)
        XCTAssertEqual(sensor.tag(), item.tag)
        XCTAssertEqual(1, item.sections.count)
        XCTAssertEqual(expectedSection, item.sections[0])
        XCTAssertNotNil(item.sensor)
        XCTAssertNil(item.function)
        XCTAssertNil(item.op)
    }

    func testInitWithOperator() {
        let expectedSection = FormulaEditorSection.logic(position: 10)
        let op = BinaryOperatorMock(value: 0, formulaEditorSection: expectedSection)

        let item = FormulaEditorItem(op: op)
        XCTAssertEqual(type(of: op).name, item.title)
        XCTAssertEqual(type(of: op).tag, item.tag)
        XCTAssertEqual(1, item.sections.count)
        XCTAssertEqual(expectedSection, item.sections[0])
        XCTAssertNotNil(item.op)
        XCTAssertNil(item.sensor)
        XCTAssertNil(item.function)
    }

    func testSection() {
        XCTAssertEqual(FormulaEditorSection.logic(position: 10), FormulaEditorSection.logic(position: 10))
        XCTAssertNotEqual(FormulaEditorSection.math(position: 1), FormulaEditorSection.math(position: 10))
        XCTAssertEqual(FormulaEditorSection.math(position: 2), FormulaEditorSection.math(position: 2))
    }
}
