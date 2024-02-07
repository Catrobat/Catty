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

import Foundation
import SpriteKit

protocol StageManagerProtocol: AnyObject {
    var project: Project { get }
    func startnewScene(scene: Scene)
    func continueScene(scene: Scene)
}

@objc protocol StagePresenterViewControllerStageManagerDelegate {
    func startNewScene()
    func continueScene()
    func stopAction()
    func restartAction()
}

@objc class StageManager: NSObject, StageManagerProtocol {

    @objc public let project: Project
    @objc public var stage: Stage
    @objc public var scene: Scene
    @objc public let formulaManager: FormulaManager
    var stagePresenterDeleagte: StagePresenterViewControllerStageManagerDelegate?
    var saveStages: [String: Stage] = [:]

    @objc(initWithProject:)
    init(project: Project) {
        self.project = project
        self.formulaManager = FormulaManager(stageSize: Util.screenSize(true), landscapeMode: project.header.landscapeMode)
        self.stage = StageBuilder(scene: project.activeScene).withFormulaManager(formulaManager: self.formulaManager).build()
        self.scene = project.activeScene
    }

    @objc public func stopProject() {
        stage.pauseScheduler()
    }

    @objc public func resumeScheduler() {
        stage.resumeScheduler()
    }

    @objc public func pauseScheduler() {
        stage.pauseScheduler()
    }

    func startnewScene(scene: Scene) {
        print(project.userData.variables())
        pauseScheduler()
        saveStages.updateValue(stage, forKey: self.scene.name)
        project.activeScene = scene
        stagePresenterDeleagte?.startNewScene()
        self.scene = scene
    }

    func continueScene(scene: Scene) {
        print(project.userData.variables())
        if let stage = saveStages[scene.name] {
            pauseScheduler()
            saveStages.updateValue(self.stage, forKey: self.scene.name)
            self.stage = stage
            project.activeScene = scene
            stagePresenterDeleagte?.continueScene()
            self.scene = scene
        } else {
            startnewScene(scene: scene)
        }
    }

    func restartSceneAndResetUserData() {
        self.saveStages = [:]
        self.stage.CBScene.project?.clearUserData()
        self.stagePresenterDeleagte?.restartAction()
        self.stopAllStages()
    }

    func stopActionAndResetUserData() {
        self.saveStages = [:]
        self.stage.CBScene.project?.clearUserData()
        self.stagePresenterDeleagte?.stopAction()
        self.stopAllStages()
    }

    func stopAllStages() {
        for stage in saveStages {
            stage.value.stopProject()
        }
    }

    @objc public func setupStage() {
        self.stage = StageBuilder(scene: project.activeScene)
            .withFormulaManager(formulaManager: FormulaManager(stageSize: Util.screenSize(true), landscapeMode: project.header.landscapeMode)).build()
        self.stage.scheduler.stageManagerDelegate = self
        if self.project.header.screenMode == kCatrobatHeaderScreenModeMaximize {
            stage.scaleMode = .aspectFill
        } else if project.header.screenMode == kCatrobatHeaderScreenModeStretch {
            stage.scaleMode = .aspectFit
        } else {
            stage.scaleMode = .aspectFill
        }
    }
}
