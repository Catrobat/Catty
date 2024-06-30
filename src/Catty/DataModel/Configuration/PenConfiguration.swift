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

struct PenConfiguration {
    var penDown = false
    var cut = false
    
    static let sizeConversionFactor = CGFloat(0.634)

    private(set) var size: CGFloat
    let screenRatio: CGFloat

    var catrobatSize: CGFloat {
        set {
            size = PenConfiguration.sizeConversionFactor * newValue * screenRatio
        }
        get {
            (size / PenConfiguration.sizeConversionFactor) / screenRatio
        }
    }

    var color = SpriteKitDefines.defaultPenColor
    var previousPositions = SynchronizedArray<CGPoint>()
    var previousPositionLines = SynchronizedArray<SynchronizedArray<CGPoint>>()
    
    var previousCutPositions = SynchronizedArray<CGPoint>()
    var drawnCutPoints = 0;
    var previousCutPositionLines = SynchronizedArray<SynchronizedArray<CGPoint>>()

    init(projectWidth: CGFloat?, projectHeight: CGFloat?) {

        size = SpriteKitDefines.defaultCatrobatPenSize * PenConfiguration.sizeConversionFactor

        guard let width = projectWidth, let height = projectHeight else {
            screenRatio = 1
            return
        }

        let deviceScreenRect = UIScreen.main.nativeBounds
        let deviceDiagonalPixel = CGFloat(sqrt(pow(deviceScreenRect.width, 2) + pow(deviceScreenRect.height, 2)))

        let creatorDiagonalPixel = CGFloat(sqrt(pow(width, 2) + pow(height, 2)))

        screenRatio = creatorDiagonalPixel / deviceDiagonalPixel
        size *= screenRatio

    }
}
