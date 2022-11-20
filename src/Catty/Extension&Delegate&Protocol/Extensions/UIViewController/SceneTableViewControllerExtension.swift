/**
 *  Copyright (C) 2010-2022 The Catrobat Team
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

@objc extension SceneTableViewController: LoginViewControllerDelegate {
    public func afterSuccessfulLogin() {
        DispatchQueue.main.async {
            if UserDefaults().bool(forKey: NetworkDefines.kUserIsLoggedIn) {
                if self.shouldPerformSegue(withIdentifier: kSegueToUpload, sender: self) {
                    self.performSegue(withIdentifier: kSegueToUpload, sender: self)
                }
            }
        }
    }
}

@objc extension SceneTableViewController: UploadViewControllerDelegate {
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

extension SceneTableViewController {
    /// Step 1: Check if project has already been checked before
    /// Step 2: Check if project has been downloaded
    /// Step 3: Check if project contains WebRequestBricks
    /// Step 4: Remember this project to not check it again
    @objc func checkProjectContainsWebRequestBricks(_ project: Project) {

        /// Step 1
        // TODO: Require a UUID() for a project
        if let warningHasBeenShown = UserDefaults.standard.stringArray(forKey: kWebRequestWarningHasBeenShown) {
            print(warningHasBeenShown)
            if warningHasBeenShown.contains("requiredUUID") {
                return
            }
        }
        
        /// Step 2
        // TODO: Is there an identifier if a project has been download?
                
        /// Step 3
        let spriteObjects = project.scene.objects()

        spriteLoop: for currentSpriteObject in spriteObjects {
            scriptLoop: for currentScript in currentSpriteObject.scriptList {

                let script = currentScript as! Script
                brickLoop: for currentBrickList in script.brickList {

                    let brick = currentBrickList as! Brick

                    if brick.isWebRequest() {
                        AlertControllerBuilder.alert(title: kLocalizedWarning, message: kLocalizedProjectContainsWebBricksWarning)
                        .addDefaultAction(title: kLocalizedOK) { }
                        .build().showWithController(self)

                        break spriteLoop
                    }
                }
            }
        }

        if var warningHasBeenShown = UserDefaults.standard.stringArray(forKey: kWebRequestWarningHasBeenShown) {
            warningHasBeenShown.append("requiredUUID")
            UserDefaults.standard.set(warningHasBeenShown, forKey: kWebRequestWarningHasBeenShown)
        } else {
            UserDefaults.standard.set(["requiredUUID"], forKey: kWebRequestWarningHasBeenShown)
        }
    }
}
