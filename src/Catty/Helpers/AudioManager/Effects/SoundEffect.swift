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

protocol SoundEffect {
    var minExternalValue: Double { get }
    var maxExternalValue: Double { get }
    var neutralInternalValue: Double { get }
    var effectType: SoundEffectType { get }

    mutating func setEffectTo(_ externalValue: Double)
    mutating func changeEffectBy(_ externalValue: Double)
    func mapToInternalValueRange(_ externalValue: Double) -> Double
    func mapToExternalValueRange(_ internalValue: Double) -> Double
    mutating func enableOrDisableEffect()
    func clear()
}

extension SoundEffect {
    func calculateInternalValue(_ externalValue: Double) -> Double {
        var boundedExternalValue = externalValue
        if externalValue < minExternalValue {
            boundedExternalValue = minExternalValue
        } else if  externalValue > maxExternalValue {
            boundedExternalValue = maxExternalValue
        }
        return mapToInternalValueRange(boundedExternalValue)
    }
}
