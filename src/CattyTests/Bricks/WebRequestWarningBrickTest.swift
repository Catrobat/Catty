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

import XCTest

@testable import Pocket_Code

final class WebRequestWarningBrickTest: XCTestCase {

    var fileManager: CBFileManager!

    var controller: SceneTableViewController!

    var projectWithoutWebRequest: Project!
    var projectWithWebRequest: Project!

    var programId = "123"

    override func setUp() {

        UserDefaults.standard.setValue(true, forKey: kUseWebRequestBrick)
        UserDefaults.standard.setValue([], forKey: kWebRequestWarningWasShown)

        controller = SceneTableViewController()

        fileManager = CBFileManager.shared()
        setupCleanProjects()

        projectWithoutWebRequest.header.programID = programId

        let script = StartScript()

        let url = "http://catrob.at/joke"
        let formula = Formula(string: url)
        let userVariable = UserVariable(name: "var")
        let brick = WebRequestBrick(request: formula!, userVariable: userVariable, script: script)

        script.brickList.addObjects(from: [brick] as [AnyObject])

        let scene = projectWithWebRequest.scene
        let object = SpriteObject()
        object.scene = scene
        object.name = "newObject"
        object.scriptList.add(script)

        projectWithWebRequest.scene.add(object: object)
        projectWithWebRequest.header.programID = "123"
    }

    private func setupCleanProjects() {
        for loadingInfo in Project.allProjectLoadingInfos() as! [ProjectLoadingInfo] {
            fileManager.deleteDirectory(loadingInfo.basePath!)
        }
        fileManager.addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist()

        let loadingInfos = Project.allProjectLoadingInfos()
        XCTAssertEqual(1, loadingInfos.count)

        projectWithWebRequest = Project(loadingInfo: (loadingInfos.first as! ProjectLoadingInfo))
        projectWithoutWebRequest = Project(loadingInfo: (loadingInfos.first as! ProjectLoadingInfo))
    }

    func testCheckWebRequestWarningIsNotShown() {
        if let defaultStorage = UserDefaults.standard.stringArray(forKey: kWebRequestWarningWasShown) {
            XCTAssertFalse(defaultStorage.contains(programId))
        } else {
            XCTFail("Should Never Happen")
        }

        XCTAssertFalse(controller.checkProjectContainsWebRequestBricks(projectWithoutWebRequest))

        if let defaultStorage = UserDefaults.standard.stringArray(forKey: kWebRequestWarningWasShown) {
            XCTAssertTrue(defaultStorage.contains(programId))
        } else {
            XCTFail("Should Never Happen")
        }

        XCTAssertFalse(controller.checkProjectContainsWebRequestBricks(projectWithWebRequest))
    }

    func testCheckWebRequestWarningIsShownFirstTimeOnly() {
        if let defaultStorage = UserDefaults.standard.stringArray(forKey: kWebRequestWarningWasShown) {
            XCTAssertFalse(defaultStorage.contains(programId))
        } else {
            XCTFail("Should Never Happen")
        }

        XCTAssertTrue(controller.checkProjectContainsWebRequestBricks(projectWithWebRequest))

        if let defaultStorage = UserDefaults.standard.stringArray(forKey: kWebRequestWarningWasShown) {
            XCTAssertTrue(defaultStorage.contains(programId))
        } else {
            XCTFail("Should Never Happen")
        }

        XCTAssertFalse(controller.checkProjectContainsWebRequestBricks(projectWithWebRequest))

        if let defaultStorage = UserDefaults.standard.stringArray(forKey: kWebRequestWarningWasShown) {
            XCTAssertTrue(defaultStorage.contains(programId))
        } else {
            XCTFail("Should Never Happen")
        }
    }
}
