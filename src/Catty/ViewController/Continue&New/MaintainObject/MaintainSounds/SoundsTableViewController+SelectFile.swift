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
import MobileCoreServices

extension SoundsTableViewController {

    @objc
    func showSoundsSelectFile() {
        var documentPicker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            let supportedAudioFormats = [UTType.wav, UTType.mp3]
            documentPicker = UIDocumentPickerViewController.init(forOpeningContentTypes: supportedAudioFormats, asCopy: true)
        } else {
            documentPicker = UIDocumentPickerViewController(documentTypes: ["public.audio", "public.mp3"], in: .import)
        }
        UINavigationBar.appearance(whenContainedInInstancesOf: [UIDocumentBrowserViewController.self]).tintColor = UIColor.navBar
        documentPicker.allowsMultipleSelection = true
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = .formSheet
        present(documentPicker, animated: true)
    }
}

extension SoundsTableViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let documents = URL(fileURLWithPath:
                                CBFileManager.shared().documentsDirectory)

        for url in urls {
            let fileName = UUID().uuidString
            let name = url.deletingPathExtension().lastPathComponent
            let fileURL = documents
                .appendingPathComponent(fileName)
                .appendingPathExtension(url.pathExtension)

            let sound = Sound(name: name, fileName: fileURL.lastPathComponent)
            do {
                let data = try Data.init(contentsOf: url)
                try data.write(to: fileURL, options: .atomic)
                self.showDownloadSoundAlert(sound)
            } catch {
                self.showImportAlert(itemName: name)
            }
        }
        controller.dismiss(animated: true)
    }

    public func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        controller.dismiss(animated: true)
    }
}
