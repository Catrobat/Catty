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

@testable import Pocket_Code

final class RuntimeImageCacheMock: RuntimeImageCache {
    var thumbnails: [String: UIImage]
    var cachedImages: [String: UIImage]

    init(thumbnails: [String: UIImage], cachedImages: [String: UIImage]) {
        self.thumbnails = thumbnails
        self.cachedImages = cachedImages
        super.init()
    }

    override func loadThumbnailImageFromDisk(withThumbnailPath thumbnailPath: String!, imagePath: String!, thumbnailFrameSize: CGSize, onCompletion completion: ((UIImage?, String?) -> Void)!) {

        if let thumbnail = thumbnails[thumbnailPath] {
            completion(thumbnail, thumbnailPath)
            return
        }

        if let image = cachedImages[imagePath] {
            completion(image, imagePath)
            return
        }

        completion(nil, nil)
    }

    override func cachedImage(forPath path: String!) -> UIImage? {
        cachedImages[path]
    }

    override func overwriteThumbnailImageFromDisk(withThumbnailPath thumbnailPath: String!, image: UIImage!, thumbnailFrameSize: CGSize) {
        thumbnails[thumbnailPath] = image
        cachedImages[thumbnailPath] = image
    }
}
