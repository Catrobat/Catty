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

        for imagePath in fallbackPaths {
            let image = imageCache.cachedImage(forPath: imagePath, andSize: UIDefines.previewImageSize)
            if image != nil {
                completion(image, imagePath)
                return
            }
        }

        DispatchQueue.global(qos: .default).async {
            for imagePath in fallbackPaths {
                if self.fileExists(imagePath as String) {
                    self.imageCache.loadImageFromDisk(withPath: imagePath,
                                                      andSize: UIDefines.previewImageSize,
                                                      onCompletion: { image, path in completion(image, path) })

                    return
                }
            }
            completion(UIImage(named: "catrobat"), nil)
        }

        return
    }

    func writeData(_ data: Data, path: String) {
        do {
            try data.write(to: URL(fileURLWithPath: path), options: .atomic)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
}
