/**
 *  Copyright (C) 2010-2020 The Catrobat Team
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

@testable import Pocket_Code
import XCTest

class ProjectsTest: XCTestCase {

    var project: Project!
    var fileManager: CBFileManager!

    override func setUp() {
        super.setUp()

        fileManager = CBFileManager.shared()
        deleteAllProjectsAndCreateDefaultProject()
    }

    override func tearDown() {
        let projectPath = project.projectPath()

        if fileManager.directoryExists(projectPath) {
            fileManager.deleteDirectory(projectPath)
        }

        super.tearDown()
    }

    private func deleteAllProjectsAndCreateDefaultProject() {
        for loadingInfo in Project.allProjectLoadingInfos() as! [ProjectLoadingInfo] {
            fileManager.deleteDirectory(loadingInfo.basePath!)
        }
        fileManager.addDefaultProjectToProjectsRootDirectoryIfNoProjectsExist()

        let loadingInfos = Project.allProjectLoadingInfos()
        XCTAssertEqual(1, loadingInfos.count)

        project = Project(loadingInfo: (loadingInfos.first as! ProjectLoadingInfo))
    }

    func testProjectDirectoryExists() {
        let directoryExists = fileManager.directoryExists(project.projectPath())
        XCTAssertTrue(directoryExists)
    }

    func testImagesDirectoryExists() {
        let imageDirectory = project.projectPath() + kProjectImagesDirName
        let directoryExists = fileManager.directoryExists(imageDirectory)
        XCTAssertTrue(directoryExists)
    }

    func testSoundsDirectoryExists() {
        let soundsDirectory = project.projectPath() + kProjectSoundsDirName
        let directoryExists = fileManager.directoryExists(soundsDirectory)
        XCTAssertTrue(directoryExists)
    }

    func testCopyObjectWithIfThenLogicBeginBrick() {
        let objectName = "newObject"
        let copiedObjectName = "copiedObject"

        let object = SpriteObject()
        object.name = objectName

        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        ifThenLogicBeginBrick.ifCondition = Formula(double: 2)

        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick

        let script = StartScript()
        script.brickList.addObjects(from: [ifThenLogicBeginBrick, ifThenLogicEndBrick] as [AnyObject])
        object.scriptList.add(script)
        project.objectList.add(object)

        let initialObjectSize = project.objectList.count
        XCTAssertTrue(initialObjectSize > 0)

        let copiedObject = project.copy(object, withNameForCopiedObject: copiedObjectName)
        XCTAssertEqual(1, copiedObject.scriptList.count)

        let objectList = project.objectList
        XCTAssertEqual(initialObjectSize + 1, objectList.count)
        XCTAssertEqual(copiedObjectName, (objectList[initialObjectSize] as! SpriteObject).name)

        let copiedScript = copiedObject.scriptList[0] as! Script
        XCTAssertEqual(2, copiedScript.brickList.count)
        XCTAssertTrue(copiedScript.brickList[0] is IfThenLogicBeginBrick)
        XCTAssertTrue(copiedScript.brickList[1] is IfThenLogicEndBrick)

        let beginBrick = copiedScript.brickList[0] as! IfThenLogicBeginBrick
        let endBrick = copiedScript.brickList[1] as! IfThenLogicEndBrick

        XCTAssertEqual(endBrick, beginBrick.ifEndBrick)
        XCTAssertEqual(beginBrick, endBrick.ifBeginBrick)
        XCTAssertNotEqual(ifThenLogicEndBrick, beginBrick.ifEndBrick)
        XCTAssertNotEqual(ifThenLogicBeginBrick, endBrick.ifBeginBrick)
    }

    func testCopyObjectWithIfLogicBeginBrick() {
        let objectName = "newObject"
        let copiedObjectName = "copiedObject"

        let object = SpriteObject()
        object.name = objectName

        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.ifCondition = Formula(double: 1)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick

        let script = StartScript()
        script.brickList.addObjects(from: [ifLogicBeginBrick, ifLogicElseBrick, ifLogicEndBrick] as [AnyObject])
        object.scriptList.add(script)
        project.objectList.add(object)

        let initialObjectSize = project.objectList.count
        XCTAssertTrue(initialObjectSize > 0)

        let copiedObject = project.copy(object, withNameForCopiedObject: copiedObjectName)
        XCTAssertEqual(1, copiedObject.scriptList.count)

        let objectList = project.objectList
        XCTAssertEqual(initialObjectSize + 1, objectList.count)
        XCTAssertEqual(copiedObjectName, (objectList[initialObjectSize] as! SpriteObject).name)

        let copiedScript = copiedObject.scriptList[0] as! Script
        XCTAssertEqual(3, copiedScript.brickList.count)
        XCTAssertTrue(copiedScript.brickList[0] is IfLogicBeginBrick)
        XCTAssertTrue(copiedScript.brickList[1] is IfLogicElseBrick)
        XCTAssertTrue(copiedScript.brickList[2] is IfLogicEndBrick)

        let beginBrick = copiedScript.brickList[0] as! IfLogicBeginBrick
        let elseBrick = copiedScript.brickList[1] as! IfLogicElseBrick
        let endBrick = copiedScript.brickList[2] as! IfLogicEndBrick

        XCTAssertEqual(endBrick, beginBrick.ifEndBrick)
        XCTAssertEqual(elseBrick, beginBrick.ifElseBrick)
        XCTAssertEqual(elseBrick, endBrick.ifElseBrick)
        XCTAssertEqual(beginBrick, elseBrick.ifBeginBrick)
        XCTAssertEqual(endBrick, elseBrick.ifEndBrick)
        XCTAssertEqual(beginBrick, endBrick.ifBeginBrick)

        XCTAssertNotEqual(ifLogicEndBrick, beginBrick.ifEndBrick)
        XCTAssertNotEqual(ifLogicElseBrick, beginBrick.ifElseBrick)
        XCTAssertNotEqual(ifLogicElseBrick, endBrick.ifElseBrick)
        XCTAssertNotEqual(ifLogicBeginBrick, elseBrick.ifBeginBrick)
        XCTAssertNotEqual(ifLogicEndBrick, elseBrick.ifEndBrick)
        XCTAssertNotEqual(ifLogicBeginBrick, endBrick.ifBeginBrick)
    }

    func testCopyObjectWithObjectVariable() {
        let object = SpriteObject()
        object.name = "newObjectName"
        project.objectList.add(object)

        let variable = UserVariable()
        variable.name = "userVariable"
        project.variables.addObjectVariable(variable, for: object)

        let setVariableBrick = SetVariableBrick()
        setVariableBrick.userVariable = variable

        let script = StartScript()
        script.brickList.addObjects(from: [setVariableBrick] as [AnyObject])
        object.scriptList.add(script)

        let initialObjectSize = project.objectList.count
        XCTAssertTrue(initialObjectSize > 0)

        let initialVariableSize = project.variables.allVariables().count
        XCTAssertTrue(initialVariableSize > 0)

        let copiedObject = project.copy(object, withNameForCopiedObject: "copiedObjectName")
        XCTAssertEqual(1, copiedObject.scriptList.count)

        let objectList = project.objectList
        XCTAssertEqual(initialObjectSize + 1, objectList.count)
        XCTAssertEqual(initialVariableSize + 1, project.variables.allVariables().count)
        XCTAssertEqual((objectList[initialObjectSize] as! SpriteObject).name, copiedObject.name)

        let copiedScript = copiedObject.scriptList[0] as! Script

        XCTAssertEqual(1, copiedScript.brickList.count)
        XCTAssertTrue(copiedScript.brickList[0] is SetVariableBrick)

        let copiedSetVariableBrick = copiedScript.brickList[0] as! SetVariableBrick
        XCTAssertNotNil(copiedSetVariableBrick.userVariable)
        XCTAssertNotEqual(variable, copiedSetVariableBrick.userVariable)
        XCTAssertEqual(variable.name, copiedSetVariableBrick.userVariable.name)
    }

    func testCopyObjectWithObjectList() {
        let object = SpriteObject()
        object.name = "newObjectName"
        project.objectList.add(object)

        let list = UserVariable()
        list.name = "userList"
        list.isList = true

        project.variables.addObjectList(list, for: object)

        let variable = UserVariable()
        variable.name = "userVariable"
        project.variables.addObjectVariable(variable, for: object)

        let setVariableBrick = SetVariableBrick()
        setVariableBrick.userVariable = list

        let script = StartScript()
        script.brickList.addObjects(from: [setVariableBrick] as [AnyObject])
        object.scriptList.add(script)

        let initialObjectSize = project.objectList.count
        XCTAssertTrue(initialObjectSize > 0)

        let initialVariableSize = project.variables.allVariables().count
        XCTAssertTrue(initialVariableSize > 0)

        let copiedObject = project.copy(object, withNameForCopiedObject: "copiedObjectName")
        XCTAssertEqual(1, copiedObject.scriptList.count)

        let objectList = project.objectList
        XCTAssertEqual(initialObjectSize + 1, objectList.count)
        XCTAssertEqual(initialVariableSize + 1, project.variables.allVariables().count)
        XCTAssertEqual((objectList[initialObjectSize] as! SpriteObject).name, copiedObject.name)

        let copiedScript = copiedObject.scriptList[0] as! Script

        XCTAssertEqual(1, copiedScript.brickList.count)
        XCTAssertTrue(copiedScript.brickList[0] is SetVariableBrick)

        let copiedSetVariableBrick = copiedScript.brickList[0] as! SetVariableBrick
        XCTAssertNotNil(copiedSetVariableBrick.userVariable)
        XCTAssertNotEqual(list, copiedSetVariableBrick.userVariable)
        XCTAssertEqual(list.name, copiedSetVariableBrick.userVariable.name)
    }

    func testRenameProject() {
        let projectPath = project.projectPath()
        let projectId = project.header.programID

        XCTAssertTrue(fileManager.directoryExists(projectPath))

        project.rename(toProjectName: "newProject", andShowSaveNotification: true)

        let newProjectPath = project.projectPath()

        XCTAssertNotEqual(projectPath, newProjectPath)
        XCTAssertFalse(fileManager.directoryExists(projectPath))
        XCTAssertTrue(fileManager.directoryExists(newProjectPath))
        XCTAssertEqual(projectId, project.header.programID)
    }

    func testRenameProjectWithSameName() {
        let projectPath = project.projectPath()
        let projectId = project.header.programID

        XCTAssertTrue(fileManager.directoryExists(projectPath))

        project.rename(toProjectName: project.header.programName, andShowSaveNotification: true)

        let newProjectPath = project.projectPath()

        XCTAssertEqual(projectPath, newProjectPath)
        XCTAssertTrue(fileManager.directoryExists(newProjectPath))
        XCTAssertEqual(projectId, project.header.programID)
    }

    func testRenameProjectNameAndId() {
        let projectPath = project.projectPath()
        let newProjectId = "newProjectId"

        XCTAssertTrue(fileManager.directoryExists(projectPath))
        XCTAssertNotEqual(newProjectId, project.header.programID)

        project.rename(toProjectName: project.header.programName, andProjectId: newProjectId, andShowSaveNotification: true)

        let newProjectPath = project.projectPath()

        XCTAssertNotEqual(projectPath, newProjectPath)
        XCTAssertFalse(fileManager.directoryExists(projectPath))
        XCTAssertTrue(fileManager.directoryExists(newProjectPath))
        XCTAssertEqual(newProjectId, project.header.programID)
    }

    func testProjectWithLoadingInfoInvalidDirectory() {
        let loadingInfo = ProjectLoadingInfo.init(forProjectWithName: project.header.programName + "invalid", projectID: kNoProjectIDYetPlaceholder)

        XCTAssertFalse(fileManager.directoryExists(loadingInfo!.basePath))

        let project = Project(loadingInfo: loadingInfo!)
        XCTAssertNil(project)
    }

    func testProjectWithLoadingInfo() {
        let loadingInfo = ProjectLoadingInfo.init(forProjectWithName: project.header.programName, projectID: kNoProjectIDYetPlaceholder)

        XCTAssertTrue(fileManager.directoryExists(loadingInfo!.basePath))

        let project = Project(loadingInfo: loadingInfo!)
        XCTAssertNotNil(project)
        XCTAssertEqual(loadingInfo!.visibleName!, project!.header.programName!)
    }

    func testProjectWithLoadingInfoDivergingDirectoryAndProjectName() {
        let oldProjectName = project.header.programName
        let oldDirectoryName = project.projectPath()

        project.header.programName += "new"

        let newProjectName = project.header.programName
        XCTAssertNotEqual(oldProjectName, newProjectName)

        fileManager.moveExistingDirectory(atPath: oldDirectoryName, toPath: project.projectPath())

        let loadingInfo = ProjectLoadingInfo.init(forProjectWithName: newProjectName, projectID: kNoProjectIDYetPlaceholder)
        XCTAssertTrue(fileManager.directoryExists(loadingInfo!.basePath))

        let project = Project(loadingInfo: loadingInfo!)
        XCTAssertEqual(newProjectName, project!.header.programName!)
    }

    func testDefaultProjectWithoutSavedNotification() {
        let project = ProjectMock()

        project.rename(toProjectName: "Project Name", andShowSaveNotification: true)
        XCTAssertTrue(project.saveNotificationShown)

        project.translateDefaultProject()
        XCTAssertFalse(project.saveNotificationShown)
    }
}
