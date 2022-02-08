/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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
    @objc class func convertTouchCoordinateToPoint(coordinate: CGPoint, stageSize: CGSize) -> CGPoint {
        let screenSize = Util.screenSize(false)
        let scaling = stageSize.width / screenSize.width
        let x = (coordinate.x - screenSize.width / 2.0) * scaling
        let y = (screenSize.height / 2.0 - coordinate.y) * scaling
        return CGPoint(x: x, y: y)
    }

    @objc class func convertPointToTouchCoordinate(point: CGPoint, stageSize: CGSize) -> CGPoint {
        let screenSize = Util.screenSize(false)
        let scaling = screenSize.width / stageSize.width
        let x = point.x * scaling + screenSize.width / 2.0
        let y = screenSize.height / 2.0 - point.y * scaling
        return CGPoint(x: x, y: y)
    }
}
