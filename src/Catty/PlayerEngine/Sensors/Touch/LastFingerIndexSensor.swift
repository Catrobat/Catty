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

@objc class LastFingerIndexSensor: NSObject, TouchSensor {

    @objc static let tag = "LAST_FINGER_INDEX"
    static let name = kUIFESensorLastFingerIndex
    static let defaultRawValue = 0.0
    static let requiredResource = ResourceType.touchHandler
    static let position = 150
    
    let getTouchManager: () -> TouchManagerProtocol?
    
    init(touchManagerGetter: @escaping () -> TouchManagerProtocol?) {
        self.getTouchManager = touchManagerGetter
    }

    func rawValue() -> Double {
        guard let numberOfTouches = getTouchManager()?.numberOfTouches() else { return type(of: self).defaultRawValue }
        return Double(numberOfTouches)
    }

    func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        return rawValue
    }
    
    func formulaEditorSection(for spriteObject: SpriteObject) -> FormulaEditorSection {
        return .device(position: type(of: self).position)
    }
}
