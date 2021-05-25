/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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
        let expectedSection = FormulaEditorSection.functions(position: 10, subsection: .maths)
        let function = ZeroParameterDoubleFunctionMock(tag: "tag", value: 1.0, formulaEditorSection: expectedSection)

        let item = FormulaEditorItem(function: function)
        XCTAssertEqual(function.nameWithParameters(), item.title)
        XCTAssertEqual(1, item.sections.count)
        XCTAssertEqual(expectedSection, item.sections[0])
        XCTAssertNotNil(item.function)
        XCTAssertNil(item.sensor)
        XCTAssertNil(item.op)
    }

    func testInitWithSensor() {
        let expectedSection = FormulaEditorSection.object(position: 10, subsection: .general)
        let sensor = SensorMock(tag: "tag", formulaEditorSection: expectedSection)

        let item = FormulaEditorItem(sensor: sensor, spriteObject: SpriteObject())
        XCTAssertEqual(type(of: sensor).name, item.title)
        XCTAssertEqual(1, item.sections.count)
        XCTAssertEqual(expectedSection, item.sections[0])
        XCTAssertNotNil(item.sensor)
        XCTAssertNil(item.function)
        XCTAssertNil(item.op)
    }

    func testInitWithOperator() {
        let expectedSection = FormulaEditorSection.logic(position: 10, subsection: .logical)
        let op = BinaryOperatorMock(value: 0, formulaEditorSection: expectedSection)

        let item = FormulaEditorItem(op: op)
        XCTAssertEqual(type(of: op).name, item.title)
        XCTAssertEqual(1, item.sections.count)
        XCTAssertEqual(expectedSection, item.sections[0])
        XCTAssertNotNil(item.op)
        XCTAssertNil(item.sensor)
        XCTAssertNil(item.function)
    }

    func testSection() {
        XCTAssertEqual(FormulaEditorSection.logic(position: 10, subsection: .logical), FormulaEditorSection.logic(position: 10, subsection: .logical))
        XCTAssertNotEqual(FormulaEditorSection.functions(position: 1, subsection: .maths), FormulaEditorSection.functions(position: 10, subsection: .maths))
        XCTAssertEqual(FormulaEditorSection.functions(position: 2, subsection: .maths), FormulaEditorSection.functions(position: 2, subsection: .maths))
    }
}
