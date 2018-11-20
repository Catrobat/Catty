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

    @objc(screenshotForSKView:)
    func screenshot(for skView: SKView) -> UIImage? {
        let size = CGSize(width: CGFloat(kPreviewImageWidth), height: CGFloat(kPreviewImageHeight))
        let center = CGPoint(x: skView.bounds.size.width / 2 - size.width / 2, y: skView.bounds.size.height / 2 - size.height / 2)

        let snapshot = skView.resizableSnapshotView(from: CGRect(origin: center, size: size), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)

        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        snapshot?.drawHierarchy(in: CGRect(origin: CGPoint.zero, size: size), afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();

        return image
    }

    @objc(takeAutomaticScreenshotForSKView: andProgram:)
    func takeAutomaticScreenshot(for skView: SKView, and program: Program) -> String? {
        let path = program.projectPath() + kScreenshotAutoFilename

        if !FileManager.default.fileExists(atPath: path) {
            guard let snapshot = self.screenshot(for: skView) else { return nil }
            return saveScreenshot(snapshot, for: program, manualScreenshot: false)
        }

        return nil
    }

    @objc(takeManualScreenshotForSKView: andProgram:)
    func takeManualScreenshot(for skView: SKView, and program: Program) -> String? {
        guard let snapshot = self.screenshot(for: skView) else { return nil }
        let path = saveScreenshot(snapshot, for: program, manualScreenshot: true)

        Util.showNotificationForSaveAction()
        return path
    }

    private func saveScreenshot(_ screenshot: UIImage, for program: Program, manualScreenshot: Bool) -> String? {
        let fileName = manualScreenshot ? kScreenshotManualFilename : kScreenshotAutoFilename
        let filePath = program.projectPath() + fileName
        let thumbnailPath = program.projectPath() + kScreenshotThumbnailPrefix + fileName
        guard let data = UIImagePNGRepresentation(screenshot) else { return nil }

        DispatchQueue.main.async {
            do {
                try data.write(to: URL(fileURLWithPath: filePath), options: .atomic)
                RuntimeImageCache.shared()?
                    .overwriteThumbnailImageFromDisk(withThumbnailPath: thumbnailPath,
                                                     image: screenshot,
                                                     thumbnailFrameSize: CGSize(width: CGFloat(kPreviewImageWidth),
                                                                                height: CGFloat(kPreviewImageHeight)))
            } catch { }
        }
        return filePath
    }
}
