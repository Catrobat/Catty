/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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

    var activePattern: StitchPatternProtocol?

    var stitches = SynchronizedArray<Stitch>()
    var drawEmbroideryQueue = SynchronizedArray<Stitch>()
    var color: UIColor

    var last: Stitch? {
        stitches.last
    }

    var startPoint: CGPoint?

    private(set) var size: CGFloat

    init(projectWidth: CGFloat?, projectHeight: CGFloat?, withName name: String? = nil) {
        self.name = name
        self.nextStitchIsColorChange = false
        self.color = SpriteKitDefines.defaultStitchingColor

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

    convenience init() {
        self.init(projectWidth: nil, projectHeight: nil)
    }

    convenience init(streams: [EmbroideryStream], withName name: String? = nil) {
        self.init(projectWidth: nil, projectHeight: nil, withName: name)

        guard streams.isNotEmpty else {
            return
        }

        self.size = streams[0].size
        self.startPoint = streams.first?.startPoint
        for stream in streams {
            for stitch in stream {
                self.add(stitch)
            }
            self.addColorChange()
        }
    }

    convenience init(fromArray stitches: [Stitch], withName name: String? = nil) {
        self.init(projectWidth: nil, projectHeight: nil, withName: name)

        for stitch in stitches {
            self.add(stitch)
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

    func sewUp(at position: CGPoint, inDirectionInDegree angleInDegree: CGFloat) {
        sewUp(at: position, inDirectionInRadians: (angleInDegree * .pi) / 180)
    }

    func sewUp(at position: CGPoint, inDirectionInRadians angleInRadians: CGFloat) {
        enum StitichingDirection: CGFloat {
            case ahead = 1
            case center = 0
            case behind = -1
        }
        let e = CGVector(dx: cos(angleInRadians), dy: sin(angleInRadians))

        for dir in [StitichingDirection.ahead, .center, .behind, .center] {
            add(Stitch(atPosition: position + e * dir.rawValue * CGFloat(EmbroideryDefines.sewUpSteps), withColor: self.color))
        }
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

            let interpolatedStitch = Stitch(atPosition: CGPoint(x: interpolatedX, y: interpolatedY), withColor: self.color, asJump: true, isInterpolated: true)
            append(interpolatedStitch)
        }
    }

    public func setColor(newColor: UIColor) {
        self.color = newColor
    }

    private func append(_ stitch: Stitch) {
        if nextStitchIsColorChange {
            stitch.isColorChange = true
            stitch.setColor(color: self.color)
            nextStitchIsColorChange = false
        }
        drawEmbroideryQueue.append(stitch)
        stitches.append(stitch)
    }
}
