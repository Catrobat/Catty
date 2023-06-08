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

class RunningStitchPattern: StitchPatternProtocol {
    unowned let stream: EmbroideryStream
    var length: CGFloat
    var firstPoint: CGPoint
    var first = true

    init(for embroideryStream: EmbroideryStream,
         at currentPosition: CGPoint,
         with stitchingLength: CGFloat) {

        stream = embroideryStream
        length = stitchingLength

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

            interpolateStitches(interpolationCount: interpolationCount, x: currentX, y: currentY)
            firstPoint = CGPoint(x: currentX, y: currentY)
        }
    }

    func interpolateStitches(interpolationCount: Int, x: CGFloat, y: CGFloat) {
        if first {
            first = false
            stream.add(Stitch(atPosition: CGPoint(x: firstPoint.x, y: firstPoint.y)))
        }

        for interpolationFactor in 1 ..< interpolationCount + 1 {
            let splitFactor = Float(interpolationFactor) / Float(interpolationCount)
            let currentX = interpolate(endValue: x, startValue: firstPoint.x, percentage: CGFloat(splitFactor))
            let currentY = interpolate(endValue: y, startValue: firstPoint.y, percentage: CGFloat(splitFactor))
            stream.add(Stitch(atPosition: CGPoint(x: currentX, y: currentY)))
        }
    }

    func interpolate(endValue: CGFloat, startValue: CGFloat, percentage: CGFloat) -> CGFloat {
        CGFloat(round(startValue + percentage * (endValue - startValue)))
    }
}
