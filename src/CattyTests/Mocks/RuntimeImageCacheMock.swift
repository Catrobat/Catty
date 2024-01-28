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

@testable import Pocket_Code

final class CachedImage {
    let path: String
    let image: UIImage
    let size: CGSize?

    init(path: String, image: UIImage, size: CGSize? = nil) {
        self.path = path
        self.image = image
        self.size = size
    }
}

final class RuntimeImageCacheMock: RuntimeImageCache {
    var imagesOnDisk: [String: UIImage]
    var cachedImages: [CachedImage]
    var cleared = false
    var loadImageFromDiskCalledPaths: [String]

    init(imagesOnDisk: [String: UIImage], cachedImages: [CachedImage]) {
        self.imagesOnDisk = imagesOnDisk
        self.cachedImages = cachedImages
        self.loadImageFromDiskCalledPaths = []
        super.init()
    }

    override func loadImageFromDisk(withPath path: String!) {
        loadImageFromDisk(withPath: path, andSize: .zero, onCompletion: nil)
    }

    override func loadImageFromDisk(withPath imagePath: String!, andSize size: CGSize, onCompletion completion: ((UIImage?, String?) -> Void)!) {
        self.loadImageFromDiskCalledPaths.append(imagePath)

        if let image = self.imagesOnDisk[imagePath], let completion = completion {
            completion(image, imagePath)
            return
        }

        if let completion = completion {
            completion(nil, nil)
        }
    }

    override func cachedImage(forPath path: String!) -> UIImage? {
        findInCache(path)?.image
    }

    override func cachedImage(forPath path: String!, andSize size: CGSize) -> UIImage! {
        findInCache(path, size: size)?.image
    }

    override func clear() {
        cleared = true
    }

    private func findInCache(_ path: String, size: CGSize? = nil) -> CachedImage? {
        for cachedImage in cachedImages {
            if cachedImage.path == path && ((size == nil && cachedImage.size == nil) || (size == cachedImage.size)) {
                return cachedImage
            }
        }
        return nil
    }
}
