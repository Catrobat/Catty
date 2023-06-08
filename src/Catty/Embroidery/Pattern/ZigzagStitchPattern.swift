/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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

import Foundation
import SpriteKit

class ZigzagStitchPattern: StitchPatternProtocol {
    unowned let stream: EmbroideryStream
    let length: CGFloat
    let width: CGFloat
    var direction: Int
    var firstPoint: CGPoint
    var first = true

    init(for embroideryStream: EmbroideryStream,
         at currentPosition: CGPoint,
         withLength length: CGFloat,
         andWidth width: CGFloat) {

        stream = embroideryStream
        self.length = length
        self.width = width
        self.direction = 1
        firstPoint = currentPosition
        stream.startPoint = currentPosition
    }

    func spriteDidMove(to pos: CGPoint, rotation: Double) {

        var distance = CGPoint.distance(from: firstPoint, to: pos)
        var currentX = pos.x
        var currentY = pos.y

        if distance >= length {
            let surplusPercentage = (distance - (distance.truncatingRemainder(dividingBy: length))) / distance
            currentX = firstPoint.x + (surplusPercentage * (currentX - firstPoint.x))
            currentY = firstPoint.y + (surplusPercentage * (currentY - firstPoint.y))
            distance -= distance.truncatingRemainder(dividingBy: length)
            let interpolationCount = Int(floor(distance / length))

            interpolateStitches(interpolationCount: interpolationCount, x: currentX, y: currentY, degrees: rotation)
            firstPoint = CGPoint(x: currentX, y: currentY)
        }
    }

    func interpolateStitches(interpolationCount: Int, x: CGFloat, y: CGFloat, degrees: CGFloat) {
        if first {
            first = false
            addPointInDirection(x: firstPoint.x, y: firstPoint.y, degrees: degrees)
        }

        for interpolationFactor in 1 ..< interpolationCount {
            let splitFactor = Float(interpolationFactor) / Float(interpolationCount)
            let currentX = interpolate(endValue: x, startValue: firstPoint.x, percentage: CGFloat(splitFactor))
            let currentY = interpolate(endValue: y, startValue: firstPoint.y, percentage: CGFloat(splitFactor))
            addPointInDirection(x: currentX, y: currentY, degrees: degrees)
        }
        addPointInDirection(x: x, y: y, degrees: degrees)
    }

    func interpolate(endValue: CGFloat, startValue: CGFloat, percentage: CGFloat) -> CGFloat {
        let value = CGFloat(round(startValue + percentage * (endValue - startValue)))
        return value
    }

    func addPointInDirection(x: CGFloat, y: CGFloat, degrees: CGFloat) {
        let xCoord = x - (width / 2) * CGFloat(sin(degreesToRadians(degrees: Float(degrees + 90))) * Float(direction))
        let yCoord = y - (width / 2) * CGFloat(cos(degreesToRadians(degrees: Float(degrees + 90))) * Float(direction))
        direction *= -1
        stream.add(Stitch(atPosition: CGPoint(x: xCoord, y: yCoord), withColor: self.stream.color))
    }

    func degreesToRadians(degrees: Float) -> Float {
        let radians = degrees * Float.pi / Float(180)
        return radians
    }
}
