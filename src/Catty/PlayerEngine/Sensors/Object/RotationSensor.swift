/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

@objc class RotationSensor: NSObject, ObjectDoubleSensor {

    static let tag = "OBJECT_ROTATION"
    static let name = kUIFEObjectDirection
    static let defaultRawValue = 0.0
    static let requiredResource = ResourceType.noResources
    static let circleMaxDegrees = 360.0
    static let position = 60

    func tag() -> String {
        type(of: self).tag
    }

    static func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return self.defaultRawValue
        }
        return Double(spriteNode.zRotation)
    }

    static func setRawValue(userInput: Double, for spriteObject: SpriteObject) {
        switch spriteObject.spriteNode.rotationStyle {
        case .leftRight:
            let orientedRight = userInput > -Double.epsilon && userInput - 180.0 < Double.epsilon
            let orientedLeft = userInput < -Double.epsilon && userInput + 180.0 > Double.epsilon
            let needsFlipping = (spriteObject.spriteNode.isFlipped() && orientedRight) || (!spriteObject.spriteNode.isFlipped() && orientedLeft)
            if needsFlipping {
                spriteObject.spriteNode.xScale *= -1
            }
            spriteObject.spriteNode.rotationDegreeOffset = userInput
        case .allAround:
            spriteObject.spriteNode.rotationDegreeOffset = 90
        case .notRotate:
            spriteObject.spriteNode.rotationDegreeOffset = userInput
        }
        let rawValue = self.convertToRaw(userInput: userInput, for: spriteObject)
        spriteObject.spriteNode.zRotation = CGFloat(rawValue)
    }

    // raw value is in radians, standardized value is in degrees
    @objc static func convertToStandardized(rawValue: Double, for spriteObject: SpriteObject) -> Double {
        guard let _ = spriteObject.spriteNode else { return self.defaultRawValue }
        let rawValueDegrees = Util.radians(toDegree: rawValue)
        return self.convertSceneToDegrees(rawValueDegrees, for: spriteObject)
    }

    @objc static func convertToRaw(userInput: Double, for spriteObject: SpriteObject) -> Double {
        let standardizedValueOnScreen = convertMathDegreesToSceneDegrees(userInput, for: spriteObject)
        return Util.degree(toRadians: standardizedValueOnScreen)
    }

    static func convertMathDegreesToSceneDegrees(_ mathDegrees: Double, for spriteObject: SpriteObject) -> Double {
        // converts a given value to make it belong to the interval [0, 360) - moves to the first trigonometric circle due to periodicity
        let circleDegrees = circleMaxDegrees
        if mathDegrees < 0.0 {
            return (-1 * (circleDegrees - spriteObject.spriteNode.rotationDegreeOffset) - (mathDegrees.truncatingRemainder(dividingBy: -circleDegrees))).truncatingRemainder(dividingBy: -circleDegrees)
        }

        return (circleDegrees - (mathDegrees.truncatingRemainder(dividingBy: circleDegrees) - spriteObject.spriteNode.rotationDegreeOffset)).truncatingRemainder(dividingBy: circleDegrees)
    }

    static func convertSceneToDegrees(_ mathDegrees: Double, for spriteObject: SpriteObject) -> Double {
        //  ensures that the value is reduced to the first trigonometric circle, meaning [0, 360)
        let sceneDegrees = self.convertMathDegreesToSceneDegrees(mathDegrees, for: spriteObject)

        // ensures that the scene degree (direction of the object) is between (-179, 180]
        if sceneDegrees > 180.0 {
            return sceneDegrees - 360.0
        }
        if sceneDegrees < -180.0 {
            return 360 + sceneDegrees
        }
        return sceneDegrees // it was already in that interval
    }

    func formulaEditorSections(for spriteObject: SpriteObject) -> [FormulaEditorSection] {
        [.object(position: type(of: self).position)]
    }
}
