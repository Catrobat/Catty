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

@objc extension StagePresenterViewController {

    func shareDST() {

        var embroideryStream = [EmbroideryStream]()
        for object in project.scene.objects() {
            embroideryStream.append(object.spriteNode.embroideryStream)
        }
        let embroideryStreamMerged = EmbroideryStream(streams: embroideryStream)
        let data = EmbroideryDSTService().generateOutput(embroideryStream: embroideryStreamMerged)

        let temporaryFolder = FileManager.default.temporaryDirectory
        let fileName = String(self.project.header.programName!) + ".dst"
        let temporaryFileURL = temporaryFolder.appendingPathComponent(fileName)
        do {
            try data.write(to: temporaryFileURL)
        } catch {
            print("File could not be written!")
            return
        }

        let shareData = [temporaryFileURL]
        let activityViewController = UIActivityViewController(activityItems: shareData, applicationActivities: nil)

        // This lines is for the popover you need to show in iPad
        activityViewController.popoverPresentationController?.sourceView = self.view

        // This line remove the arrow of the popover to show in iPad
        activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        // Pre-configuring activity items
        if #available(iOS 13.0, *) {
            activityViewController.activityItemsConfiguration = [
                UIActivity.ActivityType.message
            ] as? UIActivityItemsConfigurationReading
        }

        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            UIActivity.ActivityType.postToFacebook
        ]

        if #available(iOS 13.0, *) {
            activityViewController.isModalInPresentation = true
        }
        self.present(activityViewController, animated: true, completion: nil)
    }

    func isEmbroideryStreamFilled() -> Bool {
        for object in self.project.allObjects() where !object.spriteNode.embroideryStream.isEmpty {
            return true
        }
        return false
    }
}
