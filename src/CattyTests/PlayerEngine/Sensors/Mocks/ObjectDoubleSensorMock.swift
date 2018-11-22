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

@testable import Pocket_Code

final class ObjectDoubleSensorMock: SensorMock, ObjectDoubleSensor {

    private static var mockedValue: Double = 0

    init(tag: String, value: Double, formulaEditorSection: FormulaEditorSection) {
        super.init(tag: tag, formulaEditorSection: formulaEditorSection)
        type(of: self).mockedValue = value
    }

    override convenience init(tag: String, formulaEditorSection: FormulaEditorSection) {
        self.init(tag: tag, value: 0, formulaEditorSection: formulaEditorSection)
    }

    convenience init(tag: String, value: Double) {
        self.init(tag: tag, value: value, formulaEditorSection: .hidden)
    }

    convenience init(tag: String) {
        self.init(tag: tag, formulaEditorSection: .hidden)
    }

    static func rawValue(for spriteObject: SpriteObject) -> Double {
        return mockedValue
    }

    static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        return rawValue
    }

    static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double {
        return userInput
    }

    static func setRawValue(userInput: Double, for spriteObject: SpriteObject) {
    }
}
