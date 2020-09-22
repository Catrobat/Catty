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

class BrickCellLookDataTests: XCTestCase {

    var backgroundObject: SpriteObject!
    var spriteObject: SpriteObject!
    var scene: Scene!
    var currentScript: Script!
    var brick: SetLookBrick!
    var brickCell: SetLookBrickCell!
    var fakeScriptCell: SetLookBrickCell!
    var whenBackgroundChangesScript: WhenBackgroundChangesScript!

    override func setUp() {
        scene = Scene(name: "scene")

        backgroundObject = SpriteObject()
        backgroundObject.scene = scene
        backgroundObject.lookList = [
            Look(name: "lookA", andPath: "path") as Any,
            Look(name: "lookB", andPath: "path") as Any,
            Look(name: "lookC", andPath: "path") as Any
        ]

        scene.add(object: backgroundObject)

        spriteObject = SpriteObject()
        spriteObject.scene = scene
        spriteObject.lookList = [
            Look(name: "objectLookA", andPath: "path") as Any,
            Look(name: "objectLookB", andPath: "path") as Any
        ]

        scene.add(object: spriteObject)

        currentScript = Script()
        currentScript.object = spriteObject

        brick = SetLookBrick()
        brick.script = currentScript

        brickCell = SetLookBrickCell()
        brickCell.scriptOrBrick = brick

        whenBackgroundChangesScript = WhenBackgroundChangesScript()
        whenBackgroundChangesScript.object = spriteObject
        fakeScriptCell = SetLookBrickCell()
        fakeScriptCell.scriptOrBrick = whenBackgroundChangesScript

        XCTAssertNotEqual(backgroundObject.lookList.count, spriteObject.lookList.count)
    }

    func testValuesInsertionMode() {
        brickCell.isInserting = true

        let data = BrickCellLookData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertEqual(kLocalizedNewElement, data?.currentValue)

        let values = data?.values as? [String]
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual(1, values?.count)
    }

    func testValuesInsertionModeForScript() {
        fakeScriptCell.isInserting = true

        let data = BrickCellLookData(frame: CGRect(), andBrickCell: fakeScriptCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertEqual(kLocalizedNewElement, data?.currentValue)

        let values = data?.values as? [String]
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual(1, values?.count)
    }

    func testValuesForLookObject() {
        currentScript.object = backgroundObject

        let data = BrickCellLookData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)
        XCTAssertEqual(backgroundObject, data?.object)

        let values = data?.values as? [String]
        XCTAssertEqual(backgroundObject.lookList.count + 1, values?.count)
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual((backgroundObject.lookList[0] as? Look)?.name, values?[1])
        XCTAssertEqual((backgroundObject.lookList[1] as? Look)?.name, values?[2])
        XCTAssertEqual((backgroundObject.lookList[2] as? Look)?.name, values?[3])
    }

    func testValuesForLookObjectForScript() {
        whenBackgroundChangesScript.object = spriteObject

        let data = BrickCellLookData(frame: CGRect(), andBrickCell: fakeScriptCell, andLineNumber: 0, andParameterNumber: 0)
        XCTAssertEqual(spriteObject, data?.object)

        let values = data?.values as? [String]
        XCTAssertEqual(spriteObject.lookList.count + 1, values?.count)
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual((spriteObject.lookList[0] as? Look)?.name, values?[1])
        XCTAssertEqual((spriteObject.lookList[1] as? Look)?.name, values?[2])
    }

    func testValuesForNormalObject() {
        currentScript.object = spriteObject

        let data = BrickCellLookData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)
        XCTAssertEqual(spriteObject, data?.object)

        let values = data?.values as? [String]
        XCTAssertEqual(spriteObject.lookList.count + 1, values?.count)
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual((spriteObject.lookList[0] as? Look)?.name, values?[1])
        XCTAssertEqual((spriteObject.lookList[1] as? Look)?.name, values?[2])
    }

    func testValuesForNormalObjectForScript() {
        whenBackgroundChangesScript.object = spriteObject

        let data = BrickCellLookData(frame: CGRect(), andBrickCell: fakeScriptCell, andLineNumber: 0, andParameterNumber: 0)
        XCTAssertEqual(spriteObject, data?.object)

        let values = data?.values as? [String]
        XCTAssertEqual(spriteObject.lookList.count + 1, values?.count)
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual((spriteObject.lookList[0] as? Look)?.name, values?[1])
        XCTAssertEqual((spriteObject.lookList[1] as? Look)?.name, values?[2])
    }
}
