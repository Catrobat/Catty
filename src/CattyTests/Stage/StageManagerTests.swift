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

import XCTest

class StagePresenterVCMock: StagePresenterViewControllerStageManagerDelegate {
    func continueScene() {
        self.stageManager.resumeScheduler()
    }

    let stageManager: StageManager

    init(stageManager: StageManager) {
        self.stageManager = stageManager
    }

    func startNewScene() {
        stageManager.setupStage()

        if !stageManager.stage.startProject() {
            stopAction()
        }
        stageManager.resumeScheduler()
    }

    func stopAction() {
        stageManager.stopProject()
    }

    func restartAction() {
        stageManager.stopProject()
        startNewScene()
    }
}

@testable import Pocket_Code

final class StageManagerTests: XMLAbstractTest {

    func testStageManagerWithMultipleScenesAndGlobalVars() {
        let project = self.getProjectForXML(xmlFile: "SceneStartBrick")
        project.activeScene = project.scenes[0] as! Scene
        let stageManager = StageManager(project: project)
        let stagepresenterVC = StagePresenterVCMock(stageManager: stageManager)
        stageManager.stagePresenterDeleagte = stagepresenterVC
        XCTAssertTrue(project.userData.variables().first!.value == nil)
        stageManager.setupStage()
        stagepresenterVC.startNewScene()
        print(project.userData.variables())
        XCTAssertTrue(project.activeScene == project.scenes[2] as! Scene)
        XCTAssertTrue(project.userData.variables().first!.value as! Int == 3)

        stageManager.restartSceneAndResetUserData()
        XCTAssertTrue(project.activeScene == project.scenes[2] as! Scene)
        XCTAssertTrue(project.userData.variables().first!.value as! Int == 1)
    }

    // test case stuck in infinity loop
    func testStageManagerWithMultipleScenesAndGlobalVarsSceneTransition() {
        let project = self.getProjectForXML(xmlFile: "SceneTransitionBrickGlobalVar")
        project.activeScene = project.scenes[0] as! Scene
        print(project.activeScene.name)
        let stageManager = StageManager(project: project)
        let stagepresenterVC = StagePresenterVCMock(stageManager: stageManager)
        stageManager.stagePresenterDeleagte = stagepresenterVC
        XCTAssertTrue(project.userData.variables().first!.value == nil)
        stageManager.setupStage()
        stagepresenterVC.startNewScene()
        XCTAssertTrue(project.activeScene == project.scenes[0] as! Scene)
        XCTAssertTrue(project.userData.variables().first!.value as! Int == 5)
        stageManager.stopActionAndResetUserData()
        XCTAssertTrue(project.activeScene == project.scenes[0] as! Scene)
        XCTAssertTrue(project.userData.variables().first!.value == nil)
    }
}
