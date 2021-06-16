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

import Nimble
import XCTest

@testable import Pocket_Code

final class LookImageViewControllerTests: XCTestCase {

    var controller: LookImageViewController!
    var imageCache: RuntimeImageCache!
    var spriteObject: SpriteObject!
    var scene: Scene!

    override func setUp() {
        super.setUp()

        controller = LookImageViewController()

        scene = SceneMock()
        scene.project = Project()

        spriteObject = SpriteObjectMock()
        spriteObject.scene = scene

        controller.spriteObject = spriteObject

        imageCache = RuntimeImageCache.shared()!
    }

    func testAddPaintedImageAndClearCache() {
        let existingPath = Bundle(for: type(of: self)).path(forResource: "test.png", ofType: nil)
        let image = UIImage(contentsOfFile: existingPath!)
        let newPath = spriteObject.scene.imagesPath()! + "/test_image.png"

        let expectation = XCTestExpectation()

        controller.imagePath = newPath

        imageCache.loadImageFromDisk(withPath: existingPath, onCompletion: { _, _ in
            expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(imageCache.cachedImage(forPath: existingPath)!)

        controller.addPaintedImage(image, andPath: newPath)

        XCTAssertNil(imageCache.cachedImage(forPath: existingPath))
    }
}
