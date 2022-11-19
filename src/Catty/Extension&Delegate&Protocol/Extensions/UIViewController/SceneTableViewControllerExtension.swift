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
    @objc func checkProjectContainsWebRequestBricks(_ project: Project) {

        print("I am here to check this shit")
        //check if project has already been checked
        if var warningHasBeenShown = UserDefaults.standard.stringArray(forKey: kWebRequestWarningHasBeenShown) {
            print(warningHasBeenShown)
            if warningHasBeenShown.contains("test1234") {
                print("already checked this one")
                return
            }
        }
        
        //check if project has been downloaded
        
        

        //check if project has webbricks
        print(project.header.programID) //is immer leer???
        print(project.header.programName)
        print(project.scene.name)
        print(project.scene.allObjectNames())

        var spriteObjects = project.scene.objects() as! [SpriteObject]

        outerloop: for currentSpriteObject in spriteObjects {
            print(currentSpriteObject.name)
            print(currentSpriteObject.numberOfScripts())

            for currentScript in currentSpriteObject.scriptList {

                var script = currentScript as! Script
                print("script")
                print(script.description)

                for currentBrickList in script.brickList {
                    var brick = currentBrickList as! Brick
                    print("Brick")
                    print(brick.description)
                    print(brick.isWebRequest())

                    if brick.isWebRequest() {
                        AlertControllerBuilder.alert(title: kLocalizedWarning, message: kLocalizedProjectContainsWebBricksWarning)
                        .addDefaultAction(title: kLocalizedOK) { }
                        .build().showWithController(self)

                        break outerloop
                    }
                }
            }

        }


        if var warningHasBeenShown = UserDefaults.standard.stringArray(forKey: kWebRequestWarningHasBeenShown) {
            warningHasBeenShown.append("test1234")
            UserDefaults.standard.set(warningHasBeenShown, forKey: kWebRequestWarningHasBeenShown)
        } else {
            UserDefaults.standard.set(["test1234"], forKey: kWebRequestWarningHasBeenShown)
        }






    }
}
