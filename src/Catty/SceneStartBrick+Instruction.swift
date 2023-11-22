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

// Implemnt Start Brick Logic here

extension SceneStartBrick: CBInstructionProtocol {
    func instruction() -> CBInstruction {
        return CBInstruction.highPriorityExecClosure { context, scheduler, broadcastHandler in

            let scenes = ProjectManager.shared.currentProject.scenes.map {$0 as! Scene}
            let newStagePres = StagePresenterViewController()
            newStagePres.project = ProjectManager.shared.currentProject
            newStagePres.stageNavigationController = ProjectManager.shared.currentProject.stagePresenterViewController.stageNavigationController
            if let selectedSceneName = self.selectedSceneName {
                print(selectedSceneName)

                ProjectManager.shared.currentProject.stagePresenterViewController.stopAction()
                newStagePres.project.activeScene = scenes.first {$0.name == selectedSceneName}!
                newStagePres.playScene(to:   newStagePres.stageNavigationController)
            }
        }
    }
//    func instruction() -> CBInstruction {
//
//        .execClosure { context, _ in
//
//            let scenes = ProjectManager.shared.currentProject.scenes.map {$0 as! Scene}
//
//            if let selectedSceneName = self.selectedSceneName {
//                ProjectManager.shared.currentProject.activeScene = scenes.first {$0.name == selectedSceneName}!
//                let stageP =  scenes.first {$0.name == selectedSceneName}! as? Stage
//            }
//            if let stage = self.script.object.spriteNode.scene as? Stage {
//                stage.view?.allowsTransparency = self.isEnabled()
//                stage.backgroundColor = self.isEnabled() ? UIColor.clear : UIColor.white
//                stage.stopProject()
////                self.isEnabled() ? CameraPreviewHandler.shared().startCameraPreview() : CameraPreviewHandler.shared().stopCamera()
//            }
//
//            context.state = .runnable
//        }
//    }
}
