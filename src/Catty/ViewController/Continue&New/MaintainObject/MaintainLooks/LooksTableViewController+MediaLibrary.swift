/**
 *  Copyright (C) 2010-2023 The Catrobat Team
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
import PhotosUI

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

extension LooksTableViewController {

    @available(iOS 14, *)
    @objc
    func checkAndUpdateLimitedPhotosAccess() {
        let accessLevel: PHAccessLevel = .readWrite
        let status = PHPhotoLibrary.authorizationStatus(for: accessLevel)

        if status == .limited {
            AlertControllerBuilder.alert(title: kLocalizedAllowAccessToPhotos, message: kLocalizedAllowAccessToPhotosDescription)
                .addDefaultAction(title: kLocalizedSettings) {
                    self.gotoAppPrivacySettings()
                }
                .addCancelAction(title: kLocalizedCancel, handler: {
                })
                .build()
                .showWithController(self)
        }
    }

    func gotoAppPrivacySettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url) else {
                assertionFailure("Not able to open App privacy settings")
                return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
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
