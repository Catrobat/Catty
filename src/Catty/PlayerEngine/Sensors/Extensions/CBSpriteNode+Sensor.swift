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

extension CBSpriteNode {

    var catrobatPosition: CBPosition {

        set {
            PositionXSensor.setRawValue(userInput: Double(newValue.x), for: self.spriteObject)
            PositionYSensor.setRawValue(userInput: Double(newValue.y), for: self.spriteObject)
        }

        get {
            CBPosition(x: PositionXSensor.standardizedValue(for: self.spriteObject), y: PositionYSensor.standardizedValue(for: self.spriteObject))
        }

    }

    var catrobatSize: Double {
        set { SizeSensor.setRawValue(userInput: newValue, for: self.spriteObject) }
        get { SizeSensor.standardizedValue(for: self.spriteObject) }
    }

    var catrobatRotation: Double {
        set { RotationSensor.setRawValue(userInput: newValue, for: self.spriteObject) }
        get { RotationSensor.standardizedValue(for: self.spriteObject) }
    }

    var catrobatLayer: Double {
        set { LayerSensor.setRawValue(userInput: newValue, for: self.spriteObject) }
        get { LayerSensor.standardizedValue(for: self.spriteObject) }
    }

    var catrobatTransparency: Double {
        set { TransparencySensor.setRawValue(userInput: newValue, for: self.spriteObject) }
        get { TransparencySensor.standardizedValue(for: self.spriteObject) }
    }

    var catrobatBrightness: Double {
        set { BrightnessSensor.setRawValue(userInput: newValue, for: self.spriteObject) }
        get { BrightnessSensor.standardizedValue(for: self.spriteObject) }
    }

    var catrobatColor: Double {
        set { ColorSensor.setRawValue(userInput: newValue, for: self.spriteObject) }
        get { ColorSensor.standardizedValue(for: self.spriteObject) }
    }
}
