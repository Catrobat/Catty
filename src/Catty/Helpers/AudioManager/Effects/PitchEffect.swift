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

class PitchEffect: AKVariSpeed, SoundEffect {

    var effectType: SoundEffectType{
        return .pitch
    }
    var minExternalValue: Double{
        return -360.0
    }
    var maxExternalValue: Double{
        return 360.0
    }
    var neutralInternalValue: Double{
        return 1.0
    }

    func setEffectTo(_ externalValue: Double) {
        self.rate = calculateInternalValue(externalValue)
        enableOrDisableEffect()
    }

    func changeEffectBy(_ externalValue: Double) {
        let newExternalValue = mapToExternalValueRange(self.rate) + externalValue
        self.rate = calculateInternalValue(newExternalValue)
        enableOrDisableEffect()
    }

    func mapToInternalValueRange(_ externalValue: Double) -> Double {
        return pow(2, externalValue / 120)
    }

    func mapToExternalValueRange(_ internalValue: Double) -> Double {
        return 120 * log2(internalValue)
    }

    func enableOrDisableEffect() {
        //No action required. Effect is automatically enabled if rate is not equal to neutral
        //value and disabled when rate is equal to neutral value
    }

    func clear() {
        self.stop()
        self.rate = neutralInternalValue
    }
}
