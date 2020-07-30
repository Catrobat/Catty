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

import XCTest

@testable import Pocket_Code

class BrickCellListDataTests: XCTestCase {

    var project: Project!
    var spriteObject: SpriteObject!
    var spriteObject2: SpriteObject!
    var script: Script!
    var brick: ReplaceItemInUserListBrick!
    var brickCell: ReplaceItemInUserListBrickCell!

    var userDataContainer: UserDataContainer!
    var objectList1: UserList!
    var objectList2: UserList!
    var secondObjectList: UserList!
    var programList: UserList!

    override func setUp() {

        spriteObject = SpriteObject()
        spriteObject.name = "testObject"

        spriteObject2 = SpriteObject()
        spriteObject2.name = "testObject2"

        userDataContainer = UserDataContainer()
        objectList1 = UserList(name: "testList1")
        objectList2 = UserList(name: "testList2")
        secondObjectList = UserList(name: "testList3")
        programList = UserList(name: "testList4")

        spriteObject.userData.add(objectList1)
        spriteObject.userData.add(objectList2)
        spriteObject2.userData.add(secondObjectList)
        userDataContainer.add(programList)

        project = Project()
        project.userData = userDataContainer

        spriteObject.project = project
        spriteObject2.project = project

        script = Script()
        script.object = spriteObject

        brick = ReplaceItemInUserListBrick()
        brick.script = script
        brickCell = ReplaceItemInUserListBrickCell()

    }

    func testValuesWhenBrickUserListIsNil() {

        brick.userList = nil
        brickCell.scriptOrBrick = brick

        let brickCellListData = BrickCellListData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickCellListData?.currentValue == kLocalizedNewElement)

        let values = brickCellListData?.values as? [String]
        XCTAssertEqual(values?[0], kLocalizedNewElement)
        XCTAssertEqual(values?[1], programList.name)
        XCTAssertEqual(values?[2], objectList1.name)
        XCTAssertEqual(values?[3], objectList2.name)
        XCTAssertEqual(values?.count, 4)

    }

    func testValuesWhenBrickUserListIsObjectList() {

        brick.userList = objectList2
        brickCell.scriptOrBrick = brick

        let brickCellListData = BrickCellListData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickCellListData?.currentValue == brick.userList.name)

        let values = brickCellListData?.values as? [String]
        XCTAssertEqual(values?[0], kLocalizedNewElement)
        XCTAssertEqual(values?[1], programList.name)
        XCTAssertEqual(values?[2], objectList1.name)
        XCTAssertEqual(values?[3], objectList2.name)
        XCTAssertEqual(values?.count, 4)

    }

    func testValuesWhenBrickUserListIsProgramList() {

       brick.userList = programList
       brickCell.scriptOrBrick = brick

        let brickCellListData = BrickCellListData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickCellListData?.currentValue == brick.userList.name)

        let values = brickCellListData?.values as? [String]
        XCTAssertEqual(values?[0], kLocalizedNewElement)
        XCTAssertEqual(values?[1], programList.name)
        XCTAssertEqual(values?[2], objectList1.name)
        XCTAssertEqual(values?[3], objectList2.name)
        XCTAssertEqual(values?.count, 4)

    }

    func testValuesWhenNoListInContainer() {

        project.userData = UserDataContainer()
        spriteObject.userData.removeAllLists()
        brick.userList = nil
        brickCell.scriptOrBrick = brick

        let brickCellListData = BrickCellListData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertTrue(brickCellListData?.currentValue == kLocalizedNewElement)

        let values = brickCellListData?.values as? [String]
        XCTAssertEqual(values?[0], kLocalizedNewElement)
        XCTAssertEqual(values?.count, 1)

    }

}
