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

import Foundation

@objc
extension ProjectDetailStoreViewController {
    func download(name: String) {
        storeProjectDownloader.download(
            projectId: self.project.projectID,
            projectName: name,
            completion: { _, storeProjectDownloaderError in
                if let error = storeProjectDownloaderError {
                    switch error {
                    case .cancelled:
                        return
                    case .unexpectedError, .timeout:
                        Util.defaultAlertForNetworkError()
                    case .parse(error: _), .request(error: _, statusCode: _):
                        Util.alert(text: kLocalizedInvalidZip)
                    }

                    self.resetDownloadStatus()
                    return
                }

                self.downloadFinished()

            }, progression: { progress in
                self.updateProgress(Double(progress))
                self.reloadInputViews()
            })
    }

    private func downloadFinished() {
        self.project.isdownloading = false

        if let button = self.view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView {
            button.isHidden = true
            button.progress = 0
        }

        if let openButton = self.view.viewWithTag(Int(kOpenButtonTag)) {
            openButton.isHidden = false
        }

        if let downloadButton = self.view.viewWithTag(Int(kDownloadAgainButtonTag)) as? UIButton {
            downloadButton.isEnabled = true
            downloadButton.isHidden = false
        }

        Util.setNetworkActivityIndicator(false)
    }

    private func resetDownloadStatus() {
        self.view.viewWithTag(Int(kDownloadButtonTag))?.isHidden = false
        self.view.viewWithTag(Int(kOpenButtonTag))?.isHidden = true
        self.view.viewWithTag(Int(kStopLoadingTag))?.isHidden = true
        self.view.viewWithTag(Int(kDownloadAgainButtonTag))?.isHidden = true

        Util.setNetworkActivityIndicator(false)
    }

    private func updateProgress(_ progress: Double) {
        guard let button = self.view.viewWithTag(Int(kStopLoadingTag)) as? EVCircularProgressView else { return }
        button.setProgress(progress, animated: true)
    }
}
