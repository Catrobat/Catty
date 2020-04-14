/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@testable import Pocket_Code

final class DoubleParameterDoubleFunctionMock: DoubleParameterDoubleFunction {

    static var name = "doubleParameterDoubleFunctionMockName"
    static var requiredResource = ResourceType.noResources
    static var isIdempotent = false
    static var defaultValue: Double = 0

    private let mockedTag: String
    private let mockedValue: Double
    private let mockedSections: [FormulaEditorSection]
    private let mockedFirstParameter: FunctionParameter
    private let mockedSecondParameter: FunctionParameter

    convenience init(tag: String, value: Double, firstParameter: FunctionParameter, secondParameter: FunctionParameter) {
        self.init(tag: tag, value: value, firstParameter: firstParameter, secondParameter: secondParameter, formulaEditorSections: [])
    }

    convenience init(tag: String, value: Double, firstParameter: FunctionParameter, secondParameter: FunctionParameter, formulaEditorSection: FormulaEditorSection) {
        self.init(tag: tag, value: value, firstParameter: firstParameter, secondParameter: secondParameter, formulaEditorSections: [formulaEditorSection])
    }

    init(tag: String, value: Double, firstParameter: FunctionParameter, secondParameter: FunctionParameter, formulaEditorSections: [FormulaEditorSection]) {
        self.mockedTag = tag
        self.mockedValue = value
        self.mockedFirstParameter = firstParameter
        self.mockedSecondParameter = secondParameter
        self.mockedSections = formulaEditorSections
    }

    func tag() -> String {
        mockedTag
    }

    func firstParameter() -> FunctionParameter {
        self.mockedFirstParameter
    }

    func secondParameter() -> FunctionParameter {
        self.mockedSecondParameter
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        self.mockedSections
    }

    func value(firstParameter: AnyObject?, secondParameter: AnyObject?) -> Double {
        self.mockedValue
    }
}
