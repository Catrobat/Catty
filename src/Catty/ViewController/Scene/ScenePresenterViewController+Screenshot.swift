/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

@objc extension ScenePresenterViewController {

    public static var previewImageWidth: CGFloat { return UIScreen.main.bounds.width }
    public static var previewImageHeight: CGFloat { return previewImageWidth }

    @objc(takeAutomaticScreenshotForSKView: andProgram:)
    func takeAutomaticScreenshot(for skView: SKView, and program: Program) {
        guard let snapshot = self.screenshot(for: skView) else { return }
        saveScreenshot(snapshot, for: program, manualScreenshot: false)
    }

    @objc(takeManualScreenshotForSKView: andProgram:)
    func takeManualScreenshot(for skView: SKView, and program: Program) {
        guard let snapshot = self.screenshot(for: skView) else { return }
        saveScreenshot(snapshot, for: program, manualScreenshot: true)
    }

    private func screenshot(for skView: SKView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(skView.frame.size, false, 1)
        skView.drawHierarchy(in: skView.frame, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        let size = CGSize(width: type(of: self).previewImageWidth, height: type(of: self).previewImageHeight)
        let center = CGPoint(x: 0, y: (skView.bounds.size.height) / 2 - (size.height / 2))

        return image.crop(rect: CGRect(origin: center, size: size))!
    }

    private func saveScreenshot(_ screenshot: UIImage, for program: Program, manualScreenshot: Bool) {
        let fileName = manualScreenshot ? kScreenshotManualFilename : kScreenshotAutoFilename
        let filePath = program.projectPath() + fileName
        let thumbnailPath = program.projectPath() + kScreenshotThumbnailPrefix + fileName
        guard let data = UIImagePNGRepresentation(screenshot) else { return }

        DispatchQueue.main.async {
            do {
                try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                RuntimeImageCache.shared()?
                    .overwriteThumbnailImageFromDisk(withThumbnailPath: thumbnailPath,
                                                     image: screenshot,
                                                     thumbnailFrameSize: CGSize(width: CGFloat(kPreviewThumbnailWidth),
                                                                                height: CGFloat(kPreviewThumbnailHeight)))
                if manualScreenshot {
                    Util.showNotificationForSaveAction()
                }
            } catch {
                AlertControllerBuilder.alert(title: kLocalizedError, message: kLocalizedSaveError)
                    .addDefaultAction(title: kLocalizedOK) { }
                    .build()
                    .showWithController(self)
            }
        }
    }
}
