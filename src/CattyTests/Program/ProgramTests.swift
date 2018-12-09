/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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

final class ProgramTests: XCTestCase {
    var program: Program?

    var fileManager: CBFileManager? {
        return CBFileManager.shared()
    }

    override func setUp() {
        super.setUp()
        if fileManager?.directoryExists(Program.basePath()) == nil {
            fileManager?.createDirectory(Program.basePath())
        }
    }

    override func tearDown() {
        if program != nil {
            ProgramTests.removeProject(program?.projectPath())
        }
        program = nil
        //fileManager = nil
        super.tearDown()
    }

    func setupForNewProgram() {
        program = Program.defaultProgram(withName: kLocalizedNewProgram, programID: nil)
    }

    func testNewProgramIfProjectFolderExists() {
        setupForNewProgram()
        XCTAssertTrue((fileManager?.directoryExists(program?.projectPath()))!, "No project folder created for the new project")
    }

    func testNewProgramIfImagesFolderExists() {
        setupForNewProgram()
        var imagesDirName: String?
        if let aPath = program?.projectPath() {
            imagesDirName = "\(aPath)\(kProgramImagesDirName)"
        }
        XCTAssertTrue((fileManager?.directoryExists(imagesDirName))!, "No images folder created for the new project")
    }

    func testNewProgramIfSoundsFolderExists() {
        setupForNewProgram()
        var soundsDirName: String?
        if let aPath = program?.projectPath() {
            soundsDirName = "\(aPath)\(kProgramSoundsDirName)"
        }
        XCTAssertTrue((fileManager?.directoryExists(soundsDirName))!, "No sounds folder created for the new project")
    }

    func testCopyObjectWithIfThenLogicBeginBrick() {
        let objectName = "newObject"
        let copiedObjectName = "copiedObject"

        setupForNewProgram()

        let object = SpriteObject()
        object.name = objectName

        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        ifThenLogicBeginBrick.ifCondition = Formula(double: 2)

        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick

        let script = StartScript()
        script.brickList.add(ifThenLogicBeginBrick)
        script.brickList.add(ifThenLogicEndBrick)
        object.scriptList.add(script)
        program?.objectList.add(object)

        let initialObjectSize = program?.objectList.count

        let copiedObject: SpriteObject? = program?.copy(object, withNameForCopiedObject: copiedObjectName)
        XCTAssertEqual(1, copiedObject?.scriptList.count)

        let objectList = program?.objectList
        XCTAssertEqual((initialObjectSize ?? 0) + 1, objectList?.count)
        XCTAssertTrue(((objectList?[initialObjectSize!] as! SpriteObject).name == copiedObjectName))

        XCTAssertEqual(2, (copiedObject!.scriptList[0] as! Script).brickList.count)
        XCTAssertTrue(((copiedObject!.scriptList[0] as! Script).brickList[0] is IfThenLogicBeginBrick))
        XCTAssertTrue(((copiedObject!.scriptList[0] as! Script).brickList[1] is IfThenLogicEndBrick))

        let beginBrick = (copiedObject!.scriptList[0] as! Script).brickList[0] as? IfThenLogicBeginBrick
        let endBrick = (copiedObject!.scriptList[0] as! Script).brickList[1] as? IfThenLogicEndBrick

        XCTAssertEqual(endBrick, beginBrick?.ifEndBrick)
        XCTAssertEqual(beginBrick, endBrick?.ifBeginBrick)
        XCTAssertNotEqual(ifThenLogicEndBrick, beginBrick?.ifEndBrick)
        XCTAssertNotEqual(ifThenLogicBeginBrick, endBrick?.ifBeginBrick)
    }

    func testCopyObjectWithIfTLogicBeginBrick() {
        let objectName = "newObject"
        let copiedObjectName = "copiedObject"

        setupForNewProgram()

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
        script.brickList.add(ifLogicBeginBrick)
        script.brickList.add(ifLogicElseBrick)
        script.brickList.add(ifLogicEndBrick)
        object.scriptList.add(script)
        program?.objectList.add(object)

        let initialObjectSize = program?.objectList.count

        let copiedObject: SpriteObject? = program?.copy(object, withNameForCopiedObject: copiedObjectName)
        XCTAssertEqual(1, copiedObject?.scriptList.count)

        let objectList = program?.objectList
        XCTAssertEqual((initialObjectSize ?? 0) + 1, objectList?.count)
        XCTAssertTrue(((objectList?[initialObjectSize!] as! SpriteObject).name == copiedObjectName))

        XCTAssertEqual(3, (copiedObject?.scriptList[0] as! Script).brickList.count)
        XCTAssertTrue(((copiedObject!.scriptList[0] as! Script).brickList[0] is IfLogicBeginBrick))
        XCTAssertTrue(((copiedObject!.scriptList[0] as! Script).brickList[1] is IfLogicElseBrick))
        XCTAssertTrue(((copiedObject!.scriptList[0] as! Script).brickList[2] is IfLogicEndBrick))

        let beginBrick = (copiedObject!.scriptList[0] as! Script).brickList[0] as? IfLogicBeginBrick
        let elseBrick = (copiedObject!.scriptList[0] as! Script).brickList[1] as? IfLogicElseBrick
        let endBrick = (copiedObject!.scriptList[0] as! Script).brickList[2] as? IfLogicEndBrick

        XCTAssertEqual(endBrick, beginBrick?.ifEndBrick)
        XCTAssertEqual(elseBrick, beginBrick?.ifElseBrick)
        XCTAssertEqual(elseBrick, endBrick?.ifElseBrick)
        XCTAssertEqual(beginBrick, elseBrick?.ifBeginBrick)
        XCTAssertEqual(endBrick, elseBrick?.ifEndBrick)
        XCTAssertEqual(beginBrick, endBrick?.ifBeginBrick)

        XCTAssertNotEqual(ifLogicEndBrick, beginBrick?.ifEndBrick)
        XCTAssertNotEqual(ifLogicElseBrick, beginBrick?.ifElseBrick)
        XCTAssertNotEqual(ifLogicElseBrick, endBrick?.ifElseBrick)
        XCTAssertNotEqual(ifLogicBeginBrick, elseBrick?.ifBeginBrick)
        XCTAssertNotEqual(ifLogicEndBrick, elseBrick?.ifEndBrick)
        XCTAssertNotEqual(ifLogicBeginBrick, endBrick?.ifBeginBrick)
    }

    func testCopyObjectWithObjectVariable() {
        setupForNewProgram()

        let object = SpriteObject()
        object.name = "newObject"
        program?.objectList.add(object)

        let variable = UserVariable()
        variable.name = "userVariable"
        program?.variables.addObjectVariable(variable, for: object)

        let setVariableBrick = SetVariableBrick()
        setVariableBrick.userVariable = variable

        let script = StartScript()
        script.brickList.add(setVariableBrick)
        object.scriptList.add(script)

        let initialObjectSize = program?.objectList.count
        let initialVariableSize = program?.variables.allVariables().count

        let copiedObject: SpriteObject? = program?.copy(object, withNameForCopiedObject: "copiedObject")
        XCTAssertEqual(1, copiedObject?.scriptList.count)

        let objectList = program?.objectList
        XCTAssertEqual((initialObjectSize!) + 1, objectList?.count)
        XCTAssertEqual((initialVariableSize!) + 1, program?.variables.allVariables().count)
        XCTAssertTrue(((objectList?[initialObjectSize!] as! SpriteObject).name == copiedObject?.name))

        XCTAssertEqual(1, (copiedObject!.scriptList[0] as! Script).brickList.count)
        XCTAssertTrue(((copiedObject!.scriptList[0] as! Script).brickList[0] is SetVariableBrick))

        let copiedSetVariableBrick = (copiedObject!.scriptList[0] as! Script).brickList[0] as? SetVariableBrick
        XCTAssertNotNil(copiedSetVariableBrick?.userVariable)
        XCTAssertNotEqual(variable, copiedSetVariableBrick?.userVariable)
        XCTAssertTrue((variable.name == copiedSetVariableBrick?.userVariable.name))
    }

    func testCopyObjectWithObjectList() {
        setupForNewProgram()

        let object = SpriteObject()
        object.name = "newObject"
        program?.objectList.add(object)

        let list = UserVariable()
        list.name = "userList"
        list.isList = true
        program?.variables.addObjectList(list, for: object)

        let setVariableBrick = SetVariableBrick()
        setVariableBrick.userVariable = list

        let script = StartScript()
        script.brickList.add(setVariableBrick)
        object.scriptList.add(script)

        let initialObjectSize = program?.objectList.count
        let initialListSize = program?.variables.allLists().count

        let copiedObject: SpriteObject? = program?.copy(object, withNameForCopiedObject: "copiedObject")
        XCTAssertEqual(1, copiedObject?.scriptList.count)

        let objectList = program?.objectList
        XCTAssertEqual((initialObjectSize!) + 1, objectList?.count)
        XCTAssertEqual((initialListSize!) + 1, program?.variables.allLists().count)
        XCTAssertTrue(((objectList?[initialObjectSize!] as! SpriteObject).name == copiedObject?.name))

        XCTAssertEqual(1, (copiedObject!.scriptList[0] as! Script).brickList.count)
        XCTAssertTrue(((copiedObject!.scriptList[0] as! Script).brickList[0] is SetVariableBrick))

        let copiedSetVariableBrick = (copiedObject!.scriptList[0] as! Script).brickList[0] as? SetVariableBrick
        XCTAssertNotNil(copiedSetVariableBrick?.userVariable)
        XCTAssertNotEqual(list, copiedSetVariableBrick?.userVariable)
        XCTAssertTrue((list.name == copiedSetVariableBrick?.userVariable.name))
    }

    // MARK: - getters and setters

    class func removeProject(_ projectPath: String?) {
        let fileManager = CBFileManager.shared()
        if fileManager?.directoryExists(projectPath) != nil {
            fileManager?.deleteDirectory(projectPath)
        }
        Util.setLastProgramWithName(nil, programID: nil)
    }
}
