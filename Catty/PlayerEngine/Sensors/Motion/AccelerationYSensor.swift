/**
 *  Copyright (C) 2010-2019 The Catrobat Team
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

@objc class AccelerationYSensor: NSObject, DeviceSensor {

    @objc static let tag = "Y_ACCELERATION"
    static let name = kUIFESensorAccelerationY
    static let defaultRawValue = 0.0
    static let position = 30
    static let requiredResource = ResourceType.deviceMotion

    let getMotionManager: () -> MotionManager?

    init(motionManagerGetter: @escaping () -> MotionManager?) {
        self.getMotionManager = motionManagerGetter
    }

    func tag() -> String {
        return type(of: self).tag
    }

    func rawValue() -> Double {
        return self.getMotionManager()?.deviceMotion?.userAcceleration.y ?? type(of: self).defaultRawValue
    }

    func convertToStandardized(rawValue: Double) -> Double {
        return rawValue * 9.8
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        return [.device(position: type(of: self).position)]
    }
}
