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

@objc class RotationSensor: NSObject, ObjectSensor, ReadWriteSensor {

    static let tag = "OBJECT_ROTATION"
    static let name = kUIFEObjectDirection
    static let defaultRawValue = 0.0
    static let requiredResource = ResourceType.noResources
    static let rotationDegreeOffset = 90.0
    static let circleMaxDegrees = 360.0

    func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return type(of: self).defaultRawValue
        }
        return Double(spriteNode.zRotation)
    }
    
    // raw value is in radians, standardized value is in degrees
    func convertToStandardized(rawValue: Double) -> Double {
        let rawValueDegrees = Util.radians(toDegree: rawValue)
        return self.convertSceneToDegrees(rawValueDegrees)
    }
    
    func convertToRaw(userInput: Double) -> Double {
        let standardizedValueOnScreen = convertMathDegreesToSceneDegrees(userInput)
        return Util.degree(toRadians: standardizedValueOnScreen)
    }
    
    func convertMathDegreesToSceneDegrees(_ mathDegrees: Double) -> Double {
        // converts a given value to make it belong to the interval [0, 360) - moves to the first trigonometric circle due to periodicity
        let circleDegrees = type(of: self).circleMaxDegrees
        if mathDegrees < 0.0 {
            return (-1 * (circleDegrees - type(of: self).rotationDegreeOffset) - (mathDegrees.truncatingRemainder(dividingBy: -circleDegrees))).truncatingRemainder(dividingBy: -circleDegrees)
        }
        
        return (circleDegrees - (mathDegrees.truncatingRemainder(dividingBy: circleDegrees) - type(of: self).rotationDegreeOffset)).truncatingRemainder(dividingBy: circleDegrees)
    }
    
    func convertSceneToDegrees(_ mathDegrees: Double) -> Double {
        //  ensures that the value is reduced to the first trigonometric circle, meaning [0, 360)
        let sceneDegrees = self.convertMathDegreesToSceneDegrees(mathDegrees)
        
        // ensures that the scene degree (direction of the object) is between (-179, 180]
        if sceneDegrees > 180.0 {
            return sceneDegrees - 360.0
        }
        if sceneDegrees < -180.0 {
            return 360 + sceneDegrees
        }
        return sceneDegrees // it was already in that interval
    }
    
    func showInFormulaEditor(for spriteObject: SpriteObject) -> Bool {
        return true
    }
}
