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

final class FunctionTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    func testParameters() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "tagA", value: 1.0)
        let functionB = SingleParameterDoubleFunctionMock(tag: "tagB", value: 2.0, parameter: .list(defaultValue: "list"))
        let functionC = DoubleParameterDoubleFunctionMock(tag: "tagC", value: 3.0, firstParameter: .number(defaultValue: 2.0), secondParameter: .string(defaultValue: "test"))

        var parameters = functionA.parameters()
        XCTAssertEqual(0, parameters.count)

        parameters = functionB.parameters()
        XCTAssertEqual(1, parameters.count)

        XCTAssertEqual("list", parameters[0].defaultValueString())
        XCTAssertEqual("*list*", parameters[0].defaultValueForFunctionSignature())

        parameters = functionC.parameters()
        XCTAssertEqual(2, parameters.count)

        XCTAssertEqual("2", parameters[0].defaultValueString())
        XCTAssertEqual("2", parameters[0].defaultValueForFunctionSignature())

        XCTAssertEqual("test", parameters[1].defaultValueString())
        XCTAssertEqual("'test'", parameters[1].defaultValueForFunctionSignature())
    }

    func testNameWithParameters() {
        let functionA = ZeroParameterDoubleFunctionMock(tag: "tagA", value: 1.0)
        let functionB = SingleParameterDoubleFunctionMock(tag: "tagB", value: 2.0, parameter: .list(defaultValue: "list"))
        let functionC = DoubleParameterDoubleFunctionMock(tag: "tagC", value: 3.0, firstParameter: .number(defaultValue: 2.0), secondParameter: .string(defaultValue: "test"))

        XCTAssertEqual(type(of: functionA).name, functionA.nameWithParameters())

        var parameters = functionB.parameters()
        XCTAssertEqual(type(of: functionB).name + type(of: functionB).bracketOpen + parameters[0].defaultValueForFunctionSignature() + type(of: functionB).bracketClose, functionB.nameWithParameters())

        parameters = functionC.parameters()
        XCTAssertEqual(type(of: functionC).name + type(of: functionC).bracketOpen + parameters[0].defaultValueForFunctionSignature() + type(of: functionC).parameterDelimiter +
            parameters[1].defaultValueForFunctionSignature() + type(of: functionC).bracketClose, functionC.nameWithParameters())
    }
}
