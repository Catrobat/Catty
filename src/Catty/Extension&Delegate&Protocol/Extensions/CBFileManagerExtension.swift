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
@objc(CBFileManager)
extension CBFileManager {

    var imageCache: RuntimeImageCache { RuntimeImageCache.shared() }

    func loadPreviewImageAndCache(projectLoadingInfo: ProjectLoadingInfo, completion: @escaping (_ image: UIImage?, _ path: String?) -> Void) {

        let fallbackPaths = [
            projectLoadingInfo.basePath + kScreenshotFilename,
            projectLoadingInfo.basePath + kScreenshotManualFilename,
            projectLoadingInfo.basePath + kScreenshotAutoFilename
        ]

        for fallbackPath in fallbackPaths {

            let filename = NSString(string: fallbackPath).lastPathComponent
            let thumbnailPath = projectLoadingInfo.basePath + kScreenshotThumbnailPrefix + filename

            let image = imageCache.cachedImage(forPath: thumbnailPath)
            if image != nil {
                completion(image, thumbnailPath)
                return
            }
        }

        DispatchQueue.global(qos: .default).async {

            for fallbackPath in fallbackPaths {

                if self.fileExists(fallbackPath as String) {

                    let filename = NSString(string: fallbackPath).lastPathComponent
                    let thumbnailPath = projectLoadingInfo.basePath + kScreenshotThumbnailPrefix + filename

                    self.imageCache.loadThumbnailImageFromDisk(withThumbnailPath: thumbnailPath,
                                                               imagePath: fallbackPath,
                                                               thumbnailFrameSize: CGSize(width: Int(kPreviewThumbnailWidth), height: Int(kPreviewThumbnailHeight)),
                                                               onCompletion: { image, path in completion(image, path) }
                    )

                    return
                }
            }
            completion(nil, nil)
        }

        return
    }
}
