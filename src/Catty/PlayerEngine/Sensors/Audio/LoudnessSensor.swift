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

@objc class LoudnessSensor: NSObject, DeviceSensor {
    @objc static let tag = "LOUDNESS"
    static let name = kUIFESensorLoudness
    static let defaultRawValue = -160.0
    static let position = 170
    static let requiredResource = ResourceType.loudness

    let getAudioManager: () -> AudioManagerProtocol?

    init(audioManagerGetter: @escaping () -> AudioManagerProtocol?) {
        self.getAudioManager = audioManagerGetter
    }

    func tag() -> String {
        type(of: self).tag
    }

    func rawValue(landscapeMode: Bool) -> Double {
        self.getAudioManager()?.loudness() ?? type(of: self).defaultRawValue
    }

    func convertToStandardized(rawValue: Double) -> Double {
        let rawValueConverted = pow(10, 0.05 * rawValue)
        return rawValueConverted * 100
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.device(position: type(of: self).position)]
    }
}
