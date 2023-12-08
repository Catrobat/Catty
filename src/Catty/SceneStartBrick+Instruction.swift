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

extension SceneStartBrick: CBInstructionProtocol {
    func instruction() -> CBInstruction {
        CBInstruction.execClosure { _, schedular in

            print("Is this Brick disabled \(self.isDisabled)")
            let scenes = ProjectManager.shared.currentProject.scenes.map { $0 as! Scene }

            if let selectedSceneName = self.selectedSceneName {
                print(selectedSceneName)
                print("active \(ProjectManager.shared.currentProject.activeScene.name)")
                print(selectedSceneName == ProjectManager.shared.currentProject.activeScene.name)
                //ProjectManager.shared.currentProject.stagePresenterVC.pauseAction()
                schedular.stageManagerDelegate?.startnewScene(scene: scenes.first { $0.name == selectedSceneName }!)
//                ProjectManager.shared.currentProject.stagePresenterVC.changeStage(newScene: scenes.first { $0.name == selectedSceneName }!)
            }
        }
    }
}
