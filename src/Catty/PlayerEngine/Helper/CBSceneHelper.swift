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

@objc class CBSceneHelper: NSObject {
    
    // MARK: - Operations (Helpers)
    @objc class func convertPointToScene(_ point: CGPoint, sceneSize: CGSize) -> CGPoint {
        let x = convertXCoordinateToScene(point.x, sceneSize: sceneSize)
        let y = convertYCoordinateToScene(point.y, sceneSize: sceneSize)
        return CGPoint(x: x, y: y)
    }
    
    @objc class func convertXCoordinateToScene(_ x: CGFloat, sceneSize: CGSize) -> CGFloat {
        return (sceneSize.width/2.0 + x)
    }
    
    @objc class func convertYCoordinateToScene(_ y: CGFloat, sceneSize: CGSize) -> CGFloat {
        return (sceneSize.height/2.0 + y)
    }
    
    @objc class func convertSceneCoordinateToPoint(_ point: CGPoint, sceneSize: CGSize) -> CGPoint {
        let x = point.x - sceneSize.width/2.0
        let y = point.y - sceneSize.height/2.0
        return CGPoint(x: x, y: y);
    }
    
    @objc class func convertDegreesToScene(_ degrees: Double) -> Double {
        if degrees < 0.0 {
            return (-1 * (360.0 - PlayerConfig.RotationDegreeOffset) - (degrees.truncatingRemainder(dividingBy: -360.0))).truncatingRemainder(dividingBy: -360.0)
        }
        
        return (360.0 - (degrees.truncatingRemainder(dividingBy: 360.0) - PlayerConfig.RotationDegreeOffset)).truncatingRemainder(dividingBy: 360.0)
    }
    
    @objc class func convertSceneToDegrees(_ scene: Double) -> Double {
        let sceneDegrees = self.convertDegreesToScene(scene)
        
        if sceneDegrees > 180.0 {
            return sceneDegrees - 360.0
        }
        
        if sceneDegrees < -180.0 {
            return 360 + sceneDegrees
        }
        
        return sceneDegrees
    }
    
    class func convertRawScreenCoordinateToScene(coordinate: CGPoint, sceneSize: CGSize) -> CGPoint {
        let screenSize = Util.screenSize()
        var x = (coordinate.x - screenSize.width/2.0)
        x = x * (sceneSize.width / screenSize.width)
        var y = (screenSize.height/2.0 - coordinate.y)
        y = y * (sceneSize.height / screenSize.height)
        return CGPoint(x: x, y: y)
    }

}
