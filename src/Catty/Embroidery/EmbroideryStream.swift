/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

    var name: String?
    var stitches = [Stitch]()

    typealias IndexType = Array<Stitch>.Index

    var startIndex: IndexType { stitches.startIndex }
    var endIndex: IndexType { stitches.endIndex }

    init(withName name: String? = nil) {
        self.name = name
    }

    subscript(index: IndexType) -> Stitch {
        stitches[index]
    }

    func index(after i: IndexType) -> IndexType {
        stitches.index(after: i)
    }

    func addStich(stitch: Stitch) {
        if let lastStitch = stitches.last {
            if lastStitch.maxDistanceInEmbroideryDimensions(stitch: stitch) > EmbroideryDefines.MAX_STITCHING_DISTANCE {
                addInterpolatedStiches(stitch: stitch)
            }
        }
        stitches.append(stitch)
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
            let interploatedX = round(lastStitch.x + splitFactor * stitch.x - lastStitch.x)
            let interploatedY = round(lastStitch.y + splitFactor * stitch.y - lastStitch.y)
            stitches.append(Stitch(atPosition: CGPoint(x: interploatedX, y: interploatedY), asJump: true))
        }
    }
}
