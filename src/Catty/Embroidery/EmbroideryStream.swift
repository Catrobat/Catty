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

import Foundation

class EmbroideryStream: Collection {

    typealias IndexType = Array<Stitch>.Index

    var startIndex: IndexType { stitches.startIndex }
    var endIndex: IndexType { stitches.endIndex }

    var name: String?
    var nextStitchIsColorChange: Bool

    var stitches = SynchronizedArray<Stitch>()
    var drawEmbroideryQueue = SynchronizedArray<Stitch>()

    private(set) var size: CGFloat

    init(projectWidth: CGFloat?, projectHeight: CGFloat?, withName name: String? = nil) {
        self.name = name
        self.nextStitchIsColorChange = false

        size = SpriteKitDefines.defaultCatrobatStitchingSize * EmbroideryDefines.sizeConversionFactor
        guard let width = projectWidth, let height = projectHeight else {
            return
        }

        let deviceScreenRect = UIScreen.main.nativeBounds
        let deviceDiagonalPixel = CGFloat(sqrt(pow(deviceScreenRect.width, 2) + pow(deviceScreenRect.height, 2)))

        let creatorDiagonalPixel = CGFloat(sqrt(pow(width, 2) + pow(height, 2)))

        let screenRatio = creatorDiagonalPixel / deviceDiagonalPixel
        size *= screenRatio
    }

    init(streams: [EmbroideryStream], withName name: String? = nil) {
        self.name = name
        self.nextStitchIsColorChange = false
        size = SpriteKitDefines.defaultCatrobatStitchingSize * EmbroideryDefines.sizeConversionFactor

        for stream in streams {
            let syncArrayEnumerated = stream.stitches.enumerated()

            for (_, value1) in syncArrayEnumerated {
                self.append(value1)
            }
            self.addColorChange()
        }
    }

    subscript(index: IndexType) -> Stitch {
        guard let stitch = stitches[index] else {
            fatalError("Array index out of bounds")
        }
        return stitch
    }

    func index(after i: IndexType) -> IndexType {
        stitches.index(after: i)
    }

    func add(_ stitch: Stitch) {
        if let lastStitch = stitches.last {
            if lastStitch.maxDistanceInEmbroideryDimensions(stitch: stitch) > EmbroideryDefines.MAX_STITCHING_DISTANCE {
                addInterpolatedStiches(stitch: stitch)
            }
        }
        append(stitch)
    }

    func addColorChange() {
        nextStitchIsColorChange = true
    }

    private func addInterpolatedStiches(stitch: Stitch) {
        guard let lastStitch = stitches.last else {
            return
        }
        let splitCount = ceil(
            Double(lastStitch.maxDistanceInEmbroideryDimensions(stitch: stitch))
                / (Double(EmbroideryDefines.MAX_STITCHING_DISTANCE))
        )

        for i in 0...Int(splitCount) {
            let splitFactor = CGFloat(Double(i) / splitCount)
            let interpolatedX = round(lastStitch.x + splitFactor * (stitch.x - lastStitch.x))
            let interpolatedY = round(lastStitch.y + splitFactor * (stitch.y - lastStitch.y))

            let interpolatedStitch = Stitch(atPosition: CGPoint(x: interpolatedX, y: interpolatedY), asJump: true, isInterpolated: true)
            append(interpolatedStitch)
        }
    }

    private func append(_ stitch: Stitch) {
        if nextStitchIsColorChange {
            stitch.isColorChange = true
            nextStitchIsColorChange = false
        }
        drawEmbroideryQueue.append(stitch)
        stitches.append(stitch)
    }
}
