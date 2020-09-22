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

import Nimble
import XCTest

class ProjectTest: XCTestCase {

    var project: Project!
    var fileManager: CBFileManager!
    var object: SpriteObject!
    var scene: Scene!

    override func setUp() {
        super.setUp()

        fileManager = CBFileManager.shared()
        deleteAllProjectsAndCreateDefaultProject()

        self.scene = project.scene
        self.object = SpriteObject()
        self.object.scene = scene
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
        let imageDirectory = project.scene.imagesPath()
        let directoryExists = fileManager.directoryExists(imageDirectory)
        XCTAssertTrue(directoryExists)
    }

    func testSoundsDirectoryExists() {
        let soundsDirectory = project.scene.soundsPath()
        let directoryExists = fileManager.directoryExists(soundsDirectory)
        XCTAssertTrue(directoryExists)
    }

    func testCopyObjectWithIfThenLogicBeginBrick() {
        let objectName = "newObject"
        let copiedObjectName = "copiedObject"

        object.name = objectName

        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        ifThenLogicBeginBrick.ifCondition = Formula(double: 2)

        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick

        let script = StartScript()
        script.brickList.addObjects(from: [ifThenLogicBeginBrick, ifThenLogicEndBrick] as [AnyObject])
        object.scriptList.add(script)
        project.scene.add(object: object)

        let initialObjectSize = project.scene.objects().count
        XCTAssertTrue(initialObjectSize > 0)

        let copiedObject = project.scene.copy(object, withNameForCopiedObject: copiedObjectName)!
        XCTAssertEqual(1, copiedObject.scriptList.count)

        let objectList = project.scene.objects()
        XCTAssertEqual(initialObjectSize + 1, objectList.count)
        XCTAssertEqual(copiedObjectName, (objectList[initialObjectSize] ).name)

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
        project.scene.add(object: object)

        let initialObjectSize = project.scene.objects().count
        XCTAssertTrue(initialObjectSize > 0)

        let copiedObject = project.scene.copy(object, withNameForCopiedObject: copiedObjectName)!
        XCTAssertEqual(1, copiedObject.scriptList.count)

        let objectList = project.scene.objects()
        XCTAssertEqual(initialObjectSize + 1, objectList.count)
        XCTAssertEqual(copiedObjectName, (objectList[initialObjectSize] ).name)

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
        object.name = "newObjectName"
        project.scene.add(object: object)

        let variable = UserVariable(name: "userVariable")
        object.userData.add(variable)

        let setVariableBrick = SetVariableBrick()
        setVariableBrick.userVariable = variable

        let script = StartScript()
        script.brickList.addObjects(from: [setVariableBrick] as [AnyObject])
        object.scriptList.add(script)

        let initialObjectSize = project.scene.objects().count
        XCTAssertTrue(initialObjectSize > 0)

        let initialVariableSize = UserDataContainer.allVariables(for: project).count
        XCTAssertTrue(initialVariableSize > 0)

        let copiedObject = project.scene.copy(object, withNameForCopiedObject: "copiedObjectName")!
        XCTAssertEqual(1, copiedObject.scriptList.count)

        let objectList = project.scene.objects()
        XCTAssertEqual(initialObjectSize + 1, objectList.count)
        XCTAssertEqual(initialVariableSize + 1, UserDataContainer.allVariables(for: project).count)
        XCTAssertEqual((objectList[initialObjectSize] ).name, copiedObject.name)

        let copiedScript = copiedObject.scriptList[0] as! Script

        XCTAssertEqual(1, copiedScript.brickList.count)
        XCTAssertTrue(copiedScript.brickList[0] is SetVariableBrick)

        let copiedSetVariableBrick = copiedScript.brickList[0] as! SetVariableBrick
        XCTAssertNotNil(copiedSetVariableBrick.userVariable)
        XCTAssertFalse(variable === copiedSetVariableBrick.userVariable)
        XCTAssertEqual(variable.name, copiedSetVariableBrick.userVariable.name)
    }

    func testCopyObjectWithObjectList() {
        object.name = "newObjectName"
        project.scene.add(object: object)

        let list = UserList(name: "userList")
        object.userData.add(list)

        let brick = InsertItemIntoUserListBrick()
        brick.userList = list

        let script = StartScript()
        script.brickList.addObjects(from: [brick] as [AnyObject])
        object.scriptList.add(script)

        let initialObjectSize = project.scene.objects().count
        XCTAssertTrue(initialObjectSize > 0)

        let initialListSize = UserDataContainer.allLists(for: project).count
        XCTAssertTrue(initialListSize > 0)

        let copiedObject = project.scene.copy(object, withNameForCopiedObject: "copiedObjectName")!
        XCTAssertEqual(1, copiedObject.scriptList.count)

        let objectList = project.scene.objects()
        XCTAssertEqual(initialObjectSize + 1, objectList.count)
        XCTAssertEqual(initialListSize + 1, UserDataContainer.allLists(for: project).count)
        XCTAssertEqual((objectList[initialObjectSize] ).name, copiedObject.name)

        let copiedScript = copiedObject.scriptList[0] as! Script

        XCTAssertEqual(1, copiedScript.brickList.count)
        XCTAssertTrue(copiedScript.brickList[0] is InsertItemIntoUserListBrick)

        let copiedBrick = copiedScript.brickList[0] as! InsertItemIntoUserListBrick
        XCTAssertNotNil(copiedBrick.userList)
        XCTAssertFalse(list === copiedBrick.userList)
        XCTAssertEqual(list.name, copiedBrick.userList.name)
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

    func testNotificationForValidProjectWithLoadingInfo() {
        let loadingInfo = ProjectLoadingInfo.init(forProjectWithName: project.header.programName, projectID: kNoProjectIDYetPlaceholder)

        expect(Project(loadingInfo: loadingInfo!)).to(postNotifications(equal([])))
    }

    func testNotificationForInvalidProjectWithLoading() {
        let loadingInfo = ProjectLoadingInfo.init(forProjectWithName: project.header.programName + "InvalidProject", projectID: kNoProjectIDYetPlaceholder)

        let expectedNotification = Notification(name: .projectInvalidVersion, object: loadingInfo)
        expect(Project(loadingInfo: loadingInfo!)).to(postNotifications(equal([expectedNotification])))
    }

    func testAllObject() {
        self.project = Project()
        self.project.scene = Scene()

        XCTAssertEqual(0, self.project.scene.objects().count)

        let objectA = SpriteObject()
        objectA.name = "objectA"

        project.scene.add(object: objectA)
        XCTAssertEqual(1, self.project.scene.objects().count)
        XCTAssertTrue(self.project.scene.objects()[0] === objectA)
    }

    func testChangeProjectOrientation() {
        let project = ProjectMock()
        let screenWidth = project.header.screenWidth
        let screenHeight = project.header.screenHeight

        project.header.landscapeMode = false
        project.changeOrientation()

        XCTAssertEqual(project.header.landscapeMode, true)
        XCTAssertEqual(screenWidth, project.header.screenHeight)
        XCTAssertEqual(screenHeight, project.header.screenWidth)
        project.changeOrientation()

        XCTAssertEqual(project.header.landscapeMode, false)
        XCTAssertEqual(screenWidth, project.header.screenWidth)
        XCTAssertEqual(screenHeight, project.header.screenHeight)
    }
}
