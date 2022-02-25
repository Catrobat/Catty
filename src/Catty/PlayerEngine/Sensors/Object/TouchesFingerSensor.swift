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

@objc class TouchesFingerSensor: NSObject, TouchSensor {

    @objc static let tag = "COLLIDES_WITH_FINGER"
    static let name = kUIFESensorTouchesFinger
    static let defaultRawValue = 0.0
    static let requiredResource = ResourceType.touchHandler
    static let position = 20

    let getTouchManager: () -> TouchManagerProtocol?

    init(touchManagerGetter: @escaping () -> TouchManagerProtocol?) {
        self.getTouchManager = touchManagerGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let touchManager = getTouchManager(), let lastTouch = touchManager.lastTouch() else { return type(of: self).defaultRawValue }

        let touchesFinger = touchManager.screenTouched() && spriteObject.spriteNode.isTouched(at: lastTouch)
        return touchesFinger ? 1 : 0
    }

    func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        rawValue
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.object(position: type(of: self).position, subsection: .motion)]
    }
}
