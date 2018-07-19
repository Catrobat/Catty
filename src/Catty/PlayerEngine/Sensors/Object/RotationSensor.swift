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

    func rawValue(for spriteObject: SpriteObject) -> Double {
        guard let spriteNode = spriteObject.spriteNode else {
            return type(of: self).defaultRawValue
        }
        return Double(spriteNode.zRotation)
    }
    
    func convertToStandardized(rawValue: Double) -> Double {
        return self.convertSceneToDegrees(Util.radians(toDegree: Double(rawValue)))
    }
    
    func convertToRaw(standardizedValue: Double) -> Double {
        return Util.degree(toRadians: self.convertDegreesToScene(standardizedValue))
    }
    
    func showInFormulaEditor(for spriteObject: SpriteObject) -> Bool {
        return true
    }
    
    func convertDegreesToScene(_ degrees: Double) -> Double {
        if degrees < 0.0 {
            return (-1 * (360.0 - type(of: self).rotationDegreeOffset) - (degrees.truncatingRemainder(dividingBy: -360.0))).truncatingRemainder(dividingBy: -360.0)
        }
        
        // TODO move to constant here
        return (360.0 - (degrees.truncatingRemainder(dividingBy: 360.0) - type(of: self).rotationDegreeOffset)).truncatingRemainder(dividingBy: 360.0)
    }
    
    func convertSceneToDegrees(_ scene: Double) -> Double {
        let sceneDegrees = self.convertDegreesToScene(scene)
        
        if sceneDegrees > 180.0 {
            return sceneDegrees - 360.0
        }
        
        if sceneDegrees < -180.0 {
            return 360 + sceneDegrees
        }
        
        return sceneDegrees
    }
}
