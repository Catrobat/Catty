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

class MultiFingerYFunction: SingleParameterDoubleObjectFunction {

    static var tag = "MULTI_FINGER_Y"
    static var name = kUIFESensorFingerY
    static var defaultValue = 0.0
    static var requiredResource = ResourceType.touchHandler
    static var isIdempotent = false
    static let position = 90

    let getTouchManager: () -> TouchManagerProtocol?

    init(touchManagerGetter: @escaping () -> TouchManagerProtocol?) {
        self.getTouchManager = touchManagerGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func firstParameter() -> FunctionParameter {
        .number(defaultValue: 1)
    }

    func value(parameter: AnyObject?, spriteObject: SpriteObject) -> Double {
        guard let touchNumber = parameter as? Double else { return type(of: self).defaultValue }
        guard let position = getTouchManager()?.getPositionInScene(for: Int(touchNumber)) else { return type(of: self).defaultValue }
        return convertToStandardized(rawValue: Double(position.y), for: spriteObject)
    }

    func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        PositionYSensor.convertToStandardized(rawValue: rawValue, for: spriteObject)
    }

    func formulaEditorSections() -> [FormulaEditorSection] {
        [.sensors(position: type(of: self).position, subsection: .touch)]
    }
}
