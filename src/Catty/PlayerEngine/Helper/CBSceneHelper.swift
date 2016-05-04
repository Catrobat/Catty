/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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
    
    static let ROTATION_DEGREE_OFFSET = 90.0
    
    // MARK: - Operations (Helpers)
    class func convertPointToScene(point: CGPoint, sceneSize: CGSize) -> CGPoint {
        let x = convertXCoordinateToScene(point.x, sceneSize: sceneSize)
        let y = convertYCoordinateToScene(point.y, sceneSize: sceneSize)
        return CGPoint(x: x, y: y)
    }
    
    class func convertXCoordinateToScene(x: CGFloat, sceneSize: CGSize) -> CGFloat {
        return (sceneSize.width/2.0 + x)
    }
    
    class func convertYCoordinateToScene(y: CGFloat, sceneSize: CGSize) -> CGFloat {
        return (sceneSize.height/2.0 + y)
    }
    
    class func convertSceneCoordinateToPoint(point: CGPoint, sceneSize: CGSize) -> CGPoint {
        let x = point.x - sceneSize.width/2.0
        let y = point.y - sceneSize.height/2.0
        return CGPointMake(x, y);
    }
    
    class func convertDegreesToScene(degrees: Double) -> Double {
        return 360.0 - (degrees - ROTATION_DEGREE_OFFSET)
    }
    
    class func convertSceneToDegrees(degrees: CGFloat) -> CGFloat {
        return 360.0 + degrees
    }

}