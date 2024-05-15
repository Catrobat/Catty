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

@testable import Pocket_Code

class BrickCellVariableDataTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteObject2: SpriteObject!
    var script: Script!
    var brick: ChangeVariableBrick!
    var brickCell: ChangeVariableBrickCell!

    var userDataContainer: UserDataContainer!
    var objectVariable1: UserVariable!
    var objectVariable2: UserVariable!
    var secondObjectVariable: UserVariable!
    var programVariable: UserVariable!

    override func setUp() {
        let scene = Scene(name: "testScene2")

        spriteObject = SpriteObject()
        spriteObject.scene = scene
        spriteObject.name = "testObject"

        spriteObject2 = SpriteObject()
        spriteObject2.scene = scene
        spriteObject2.name = "testObject2"

        userDataContainer = UserDataContainer()
        objectVariable1 = UserVariable(name: "testVariable1")
        objectVariable2 = UserVariable(name: "testVariable2")
        secondObjectVariable = UserVariable(name: "testVariable3")
        programVariable = UserVariable(name: "testVariable4")

        spriteObject.userData.add(objectVariable1)
        spriteObject.userData.add(objectVariable2)
        spriteObject2.userData.add(secondObjectVariable)
        userDataContainer.add(programVariable)
        project = Project()
        project.scenes[0] = spriteObject.scene!
        project.userData = userDataContainer

        spriteObject.scene.project = project
        spriteObject2.scene.project = project

        script = Script()
        script.object = spriteObject

        brick = ChangeVariableBrick()
        brick.script = script
        brickCell = ChangeVariableBrickCell()

    }

    func testValuesWhenBrickUserVariableIsNil() {

        brick.userVariable = nil
        brickCell.scriptOrBrick = brick

        let brickCellVariableData = BrickCellVariableData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickCellVariableData?.currentValue == kLocalizedNewElement)

        let values = brickCellVariableData?.values as? [String]
        XCTAssertEqual(values?[0], kLocalizedNewElement)
        XCTAssertEqual(values?[1], programVariable.name)
        XCTAssertEqual(values?[2], objectVariable1.name)
        XCTAssertEqual(values?[3], objectVariable2.name)
        XCTAssertEqual(values?.count, 4)

    }

    func testValuesWhenBrickUserVariableIsObjectVariable() {

        brick.userVariable = objectVariable2
        brickCell.scriptOrBrick = brick

        let brickCellVariableData = BrickCellVariableData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickCellVariableData?.currentValue == brick.userVariable.name)

        let values = brickCellVariableData?.values as? [String]
        XCTAssertEqual(values?[0], kLocalizedNewElement)
        XCTAssertEqual(values?[1], programVariable.name)
        XCTAssertEqual(values?[2], objectVariable1.name)
        XCTAssertEqual(values?[3], objectVariable2.name)
        XCTAssertEqual(values?.count, 4)

    }

    func testValuesWhenBrickUserVariableIsProgramVariable() {

       brick.userVariable = programVariable
       brickCell.scriptOrBrick = brick

        let brickCellVariableData = BrickCellVariableData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickCellVariableData?.currentValue == brick.userVariable.name)

        let values = brickCellVariableData?.values as? [String]
        XCTAssertEqual(values?[0], kLocalizedNewElement)
        XCTAssertEqual(values?[1], programVariable.name)
        XCTAssertEqual(values?[2], objectVariable1.name)
        XCTAssertEqual(values?[3], objectVariable2.name)
        XCTAssertEqual(values?.count, 4)

    }

    func testValuesWhenNoVariableInContainer() {

        project.userData = UserDataContainer()
        spriteObject.userData.removeAllVariables()
        brick.userVariable = nil
        brickCell.scriptOrBrick = brick

        let brickCellVariableData = BrickCellVariableData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickCellVariableData?.currentValue == kLocalizedNewElement)

        let values = brickCellVariableData?.values as? [String]
        XCTAssertEqual(values?[0], kLocalizedNewElement)
        XCTAssertEqual(values?.count, 1)

    }

}
