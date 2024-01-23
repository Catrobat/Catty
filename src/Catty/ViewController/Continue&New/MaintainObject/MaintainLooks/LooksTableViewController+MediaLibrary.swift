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

import MobileCoreServices

extension LooksTableViewController {

    @objc
    func showBackgroundsMediaLibrary() {
        let viewController = MediaLibraryViewController(for: .backgrounds)
        viewController.importDelegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    @objc
    func showLooksMediaLibrary() {
        let viewController = MediaLibraryViewController(for: .looks)
        viewController.importDelegate = self
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    private func showImportAlert(itemName: String) {
        let alertTitle = kLocalizedMediaLibraryImportFailedTitle
        let alertMessage = "\(kLocalizedMediaLibraryImportFailedMessage) \(itemName)"
        let buttonTitle = kLocalizedOK

        let alertController = UIAlertController.init(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        alertController.addAction(title: buttonTitle, style: .default, handler: nil)
        self.present(alertController, animated: true, completion: nil)
    }
}

extension LooksTableViewController: MediaLibraryViewControllerImportDelegate {
    func mediaLibraryViewController(_ mediaLibraryViewController: MediaLibraryViewController, didPickItemsForImport items: [MediaItem]) {
        for item in items {
            guard let itemName = item.name else { continue }
            guard let data = item.cachedData else { self.showImportAlert(itemName: itemName); continue }

            if let image = UIImage(data: data) {
                self.addMediaLibraryLoadedImage(image, withName: item.name)
                continue
            }
        }
    }
}

extension LooksTableViewController {
    @available(iOS 14.0, *)
    static var supportedFileFormats = [UTType.png, UTType.jpeg]

    @objc
    func showImagesSelectFile() {
        var documentPicker: UIDocumentPickerViewController
        if #available(iOS 14.0, *) {
            documentPicker = UIDocumentPickerViewController.init(forOpeningContentTypes: type(of: self).supportedFileFormats, asCopy: true)
            documentPicker.allowsMultipleSelection = false
            documentPicker.delegate = self
            documentPicker.modalPresentationStyle = .formSheet
            present(documentPicker, animated: true)
        }
    }
}

extension LooksTableViewController: UIDocumentPickerDelegate, UINavigationControllerDelegate {
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        let documents = URL(fileURLWithPath:
                                CBFileManager.shared().documentsDirectory)

        for url in urls {
            let fileName = UUID().uuidString
            let name = url.deletingPathExtension().lastPathComponent
            let fileURL = documents
                .appendingPathComponent(fileName)
                .appendingPathExtension(url.pathExtension)

            do {
                let data = try Data.init(contentsOf: url)
                try data.write(to: fileURL, options: .atomic)
                if let image = UIImage(data: data) {
                    self.addMediaLibraryLoadedImage(image, withName: name)
                    continue
                }
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
