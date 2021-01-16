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

import XCTest

@testable import Pocket_Code

final class RuntimeImageCacheTests: XCTestCase {

    var imageCache: RuntimeImageCache!
    var imageFilePath: String!
    var expectation: XCTestExpectation!

    override func setUp() {
        imageCache = RuntimeImageCache()

        let bundle = Bundle(for: type(of: self))
        imageFilePath = bundle.path(forResource: "test.png", ofType: nil)

        expectation = XCTestExpectation()
    }

    func testLoadImageFromDisk() {
        let expectedImage = UIImage(contentsOfFile: imageFilePath)

        imageCache.loadImageFromDisk(withPath: imageFilePath, onCompletion: { image, path in
            XCTAssertEqual(self.imageFilePath, path)
            XCTAssertEqual(expectedImage?.size, image!.size)
            XCTAssertNotNil(self.imageCache.cachedImage(forPath: self.imageFilePath))

            self.expectation.fulfill()

        })

        wait(for: [expectation], timeout: 1.0)
    }

    func testLoadImageFromDiskNotAvailable() {
        imageCache.loadImageFromDisk(withPath: imageFilePath, onCompletion: { image, path in
            XCTAssertNotNil(image)
            XCTAssertNotNil(path)

            self.expectation.fulfill()

        })

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNotNil(imageCache.cachedImage(forPath: imageFilePath))
    }

    func testLoadImageFromDiskWithSize() {
        let expectedImage = UIImage(contentsOfFile: imageFilePath)!
        let size = CGSize(width: expectedImage.size.width * 0.5, height: expectedImage.size.height * 0.5)
        let expectedSize = CGSize(width: round((expectedImage.size.width * size.width) / expectedImage.size.height), height: size.height)

        imageCache.loadImageFromDisk(withPath: imageFilePath, andSize: size, onCompletion: { image, path in
            XCTAssertEqual(self.imageFilePath, path)
            XCTAssertEqual(expectedSize, image!.size)
            XCTAssertNotNil(self.imageCache.cachedImage(forPath: self.imageFilePath, andSize: size))

            self.expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1.0)
    }

    func testCachedImageForPath() {
        var expectedImage: UIImage?
        XCTAssertNil(imageCache.cachedImage(forPath: imageFilePath))

        imageCache.loadImageFromDisk(withPath: imageFilePath, onCompletion: { image, _ in
            expectedImage = image
            self.expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1.0)

        let cachedImage = imageCache.cachedImage(forPath: imageFilePath)
        XCTAssertNotNil(cachedImage)
        XCTAssertEqual(expectedImage!, cachedImage)
    }

    func testCachedImageForPathAndSize() {
        let expectedSize = CGSize(width: 10, height: 10)
        XCTAssertNil(imageCache.cachedImage(forPath: imageFilePath))

        imageCache.loadImageFromDisk(withPath: imageFilePath, andSize: expectedSize, onCompletion: { _, _ in
            self.expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNil(imageCache.cachedImage(forPath: imageFilePath))
        XCTAssertNil(imageCache.cachedImage(forPath: imageFilePath, andSize: .zero))
        XCTAssertNotNil(imageCache.cachedImage(forPath: imageFilePath, andSize: expectedSize))
    }

    func testClearImageCache() {
        imageCache.loadImageFromDisk(withPath: imageFilePath, onCompletion: { _, _ in
            self.expectation.fulfill()
        })

        wait(for: [expectation], timeout: 1.0)

        XCTAssertNotNil(self.imageCache.cachedImage(forPath: self.imageFilePath))

        imageCache.clear()

        XCTAssertNil(self.imageCache.cachedImage(forPath: self.imageFilePath))
    }
}
