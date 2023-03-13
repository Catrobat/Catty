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

import Foundation

@objc
extension ProjectDetailStoreViewController {
    func reportProject() {
        guard StoreAuthenticator.isLoggedIn() else {
            Util.alert(text: kLocalizedLoginToReport)
            return
        }

        AlertControllerBuilder.textFieldAlert(title: kLocalizedReportProject, message: kLocalizedEnterReason)
            .addCancelActionWithTitle(kLocalizedCancel, handler: nil)
            .addDefaultActionWithTitle(kLocalizedOK, handler: {report in
                let isValidInput = self.validateInput(input: report)
                guard isValidInput.valid else {
                    Util.alert(text: isValidInput.localizedMessage!)
                    return
                }
                self.sendReport(message: report)
                })
        .build()
        .showWithController(self)
    }

    func sendReport(message: String) {
        let reporter = StoreProjectReporter()

        reporter.report(projectId: self.project.projectID, message: message, completion: { error in
            guard error == nil else {
                if Util.isNetworkError(error) {
                    Util.defaultAlertForNetworkError()
                    self.hideLoadingView()
                } else {
                    Util.alert(text: kLocalizedProjectNotReported)
                }
                return
            }

            DispatchQueue.main.async(execute: {
                Util.alert(text: kLocalizedReportedProject)
            })
        })
    }

    func validateInput(input: String) -> InputValidationResult {
        if input.count < NetworkDefines.reportProjectNoteMinLength {
            return InputValidationResult.invalidInput(String(format: kLocalizedNoOrTooShortInputDescription, NetworkDefines.reportProjectNoteMinLength))
        } else if input.count > NetworkDefines.reportProjectNoteMaxLength {
            return InputValidationResult.invalidInput(String(format: kLocalizedTooLongInputDescription, NetworkDefines.reportProjectNoteMaxLength))
        }
        return InputValidationResult.validInput()
    }
}
