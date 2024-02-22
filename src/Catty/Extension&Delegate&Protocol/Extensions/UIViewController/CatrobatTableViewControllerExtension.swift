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

@objc extension CatrobatTableViewController: AuthenticationDelegate {
    public func successfullyAuthenticated() {
        DispatchQueue.main.async {
            if StoreAuthenticator.isLoggedIn() {
                if self.shouldPerformSegue(withIdentifier: kSegueToUpload, sender: self) {
                    self.performSegue(withIdentifier: kSegueToUpload, sender: self)
                }
            }
        }
    }
}

@objc extension CatrobatTableViewController: UploadViewControllerDelegate {
    func uploadSuccessful(project: Project, projectId: String) {
        DispatchQueue.main.async(execute: {
            AlertControllerBuilder.alert(title: kLocalizedProjectUploaded, message: kLocalizedProjectUploadedBody)
                .addDefaultAction(title: kLocalizedView) {
                    self.openProjectDetails(projectId: projectId)
                }
            .addDefaultAction(title: kLocalizedOK) { }
            .build().showWithController(self)
        })
    }
}

@objc extension CatrobatTableViewController {
    func openAccountMenu() {
        if StoreAuthenticator.isLoggedIn() {
            DispatchQueue.main.async(execute: {
                AlertControllerBuilder.actionSheet(title: UserDefaults.standard.string(forKey: NetworkDefines.kUsername))
                    .addDestructiveAction(title: kLocalizedLogout, handler: { [weak self] in
                        StoreAuthenticator.logout()
                        self?.navigationItem.rightBarButtonItem?.image = self?.generateAccountImage()
                    })
                .addCancelAction(title: kLocalizedCancel, handler: nil)
                .build().showWithController(self)
            })
        } else {
            self.openLoginScreen()
        }
    }

    func generateAccountImage() -> UIImage? {
        if StoreAuthenticator.isLoggedIn(),
           let initial = UserDefaults.standard.string(forKey: NetworkDefines.kUsername)?.uppercased().first {
            return UIImage(named: "circle.fill#navbar")?.overlayText(String(initial), withFont: UIFont.boldSystemFont(ofSize: 16), andColor: UIColor.clear)
        } else {
            return UIImage(named: "person.crop.circle#navbar")
        }
    }

    func createProject(inputName: String, isdefault: Bool) {
        print("createProject bool: \(isdefault)")
        if isdefault {
            if let project = CBFileManager.shared().addDefaultProject(toProjectsRootDirectory: inputName) {
                self.openProject(project)
            }
        } else {
            let project = self.projectManager.createProject(name: inputName, projectId: nil)
            self.openProject(project)
        }
    }

    func createProjectCreationDialogue() {
        Util.askUser(forProject: #selector(createProject(inputName: isdefault: )),
                     target: self,
                     promptTitle: kLocalizedNewProject,
                     promptMessage: kLocalizedProjectName,
                     promptValue: nil,
                     promptPlaceholder: kLocalizedEnterYourProjectNameHere,
                     minInputLength: UInt(kMinNumOfProjectNameCharacters),
                     maxInputLength: UInt(kMaxNumOfProjectNameCharacters),
                     invalidInputAlertMessage: kLocalizedProjectNameAlreadyExistsDescription,
                     existingNames: Project.allProjectNames())
    }
}
