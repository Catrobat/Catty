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

import XCTest

@testable import Pocket_Code

final class PenConfigurationTests: XCTestCase {

    private let width: CGFloat = 100
    private let height: CGFloat = 200

    private func calculateScreenRatio(width: CGFloat, height: CGFloat) -> CGFloat {
        let deviceScreenRect = UIScreen.main.nativeBounds
        let deviceDiagonalPixel = CGFloat(sqrt(pow(deviceScreenRect.width, 2) + pow(deviceScreenRect.height, 2)))

        let creatorDiagonalPixel = CGFloat(sqrt(pow(width, 2) + pow(height, 2)))

        return creatorDiagonalPixel / deviceDiagonalPixel
    }

    func testScreenRatio() {
        let penConfiguration = PenConfiguration(projectWidth: width, projectHeight: height)
        XCTAssertEqual(penConfiguration.screenRatio, calculateScreenRatio(width: width, height: height))
    }

    func testScreenRatioWithParametersNil() {
        let penConfiguration = PenConfiguration(projectWidth: nil, projectHeight: nil)
        XCTAssertEqual(penConfiguration.screenRatio, 1)
    }

    func testCatrobatSizeSKSizeConversion() {
        var penConfiguration = PenConfiguration(projectWidth: width, projectHeight: height)
        let screenRatio = calculateScreenRatio(width: width, height: height)

        XCTAssertEqual(penConfiguration.catrobatSize, SpriteKitDefines.defaultCatrobatPenSize, accuracy: 0.01)

        var expectedPenSize = SpriteKitDefines.defaultCatrobatPenSize * CGFloat(PenConfiguration.sizeConversionFactor) * screenRatio

        XCTAssertEqual(penConfiguration.size, expectedPenSize, accuracy: 0.01)

        penConfiguration.catrobatSize = 10.0

        expectedPenSize = penConfiguration.catrobatSize * CGFloat(PenConfiguration.sizeConversionFactor) * screenRatio
        XCTAssertEqual(penConfiguration.size, expectedPenSize, accuracy: 0.01)
    }

}
