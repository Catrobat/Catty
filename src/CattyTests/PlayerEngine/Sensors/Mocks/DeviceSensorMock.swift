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

final class DeviceSensorMock: SensorMock, DeviceSensor {

    private let mockedValue: Double

    init(tag: String, value: Double, formulaEditorSections: [FormulaEditorSection]) {
        self.mockedValue = value

        super.init(tag: tag, formulaEditorSections: formulaEditorSections)
    }

    convenience init(tag: String, value: Double, formulaEditorSection: FormulaEditorSection) {
        self.init(tag: tag, value: value, formulaEditorSections: [formulaEditorSection])
    }

    convenience init(tag: String, formulaEditorSection: FormulaEditorSection) {
        self.init(tag: tag, value: 0, formulaEditorSections: [formulaEditorSection])
    }

    override convenience init(tag: String, formulaEditorSections: [FormulaEditorSection]) {
        self.init(tag: tag, value: 0, formulaEditorSections: formulaEditorSections)
    }

    convenience init(tag: String, value: Double) {
        self.init(tag: tag, value: value, formulaEditorSections: [])
    }

    convenience init(tag: String) {
        self.init(tag: tag, formulaEditorSections: [])
    }

    func rawValue() -> Double {
        return mockedValue
    }

    func convertToStandardized(rawValue: Double) -> Double {
        return rawValue
    }
}
