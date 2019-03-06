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

import AudioKit
import Foundation

class PanEffect: AKPanner, SoundEffect {

    var effectType: SoundEffectType {
        return .pan
    }
    var minExternalValue: Double{
         return -100.0
    }
    var maxExternalValue: Double{
        return 100.0
    }
    var neutralInternalValue: Double{
        return 0.0
    }

    func setEffectTo(_ externalValue: Double) {
        self.pan = calculateInternalValue(externalValue)
        enableOrDisableEffect()
    }

    func changeEffectBy(_ externalValue: Double) {
        let newExternalValue = mapToExternalValueRange(self.pan) + externalValue
        self.pan = calculateInternalValue(newExternalValue)
        enableOrDisableEffect()
    }

    func mapToInternalValueRange(_ externalValue: Double) -> Double {
        return externalValue / 100
    }

    func mapToExternalValueRange(_ internalValue: Double) -> Double {
        return internalValue * 100
    }

    func enableOrDisableEffect() {
        if (self.pan != neutralInternalValue) && (!self.isPlaying) {
            self.start()
        } else if (self.pan == neutralInternalValue) && self.isPlaying {
            self.stop()
        }
    }

    func clear() {
        self.stop()
        self.pan = neutralInternalValue
    }
}
