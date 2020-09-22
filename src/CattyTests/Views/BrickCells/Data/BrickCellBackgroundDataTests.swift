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

class BrickCellBackgroundDataTests: XCTestCase {

    var backgroundObject: SpriteObject!
    var spriteObject: SpriteObject!
    var scene: Scene!
    var currentScript: Script!
    var brick: SetBackgroundBrick!
    var brickCell: SetBackgroundBrickCell!
    var whenBackgroundChangesScript: WhenBackgroundChangesScript!
    var scriptCell: WhenBackgroundChangesScriptCell!

    override func setUp() {
        scene = Scene(name: "scene")

        backgroundObject = SpriteObject()
        backgroundObject.scene = scene
        backgroundObject.lookList = [
            Look(name: "backgroundLookA", andPath: "path") as Any,
            Look(name: "backgroundLookB", andPath: "path") as Any
        ]

        scene.add(object: backgroundObject)

        spriteObject = SpriteObject()
        spriteObject.scene = scene
        spriteObject.lookList = [ Look(name: "objectLook", andPath: "path") as Any ]

        scene.add(object: spriteObject)

        currentScript = Script()
        currentScript.object = spriteObject

        brick = SetBackgroundBrick()
        brick.script = currentScript

        brickCell = SetBackgroundBrickCell()
        brickCell.scriptOrBrick = brick

        whenBackgroundChangesScript = WhenBackgroundChangesScript()
        whenBackgroundChangesScript.object = spriteObject
        scriptCell = WhenBackgroundChangesScriptCell()
        scriptCell.scriptOrBrick = whenBackgroundChangesScript

        XCTAssertNotEqual(spriteObject.lookList.count, backgroundObject.lookList.count)
    }

    func testValuesInsertionMode() {
        brickCell.isInserting = true

        let data = BrickCellBackgroundData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertEqual(kLocalizedNewElement, data?.currentValue)

        let values = data?.values as? [String]
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual(1, values?.count)
    }

    func testValuesInsertionModeForScript() {
        scriptCell.isInserting = true

        let data = BrickCellBackgroundData(frame: CGRect(), andBrickCell: scriptCell, andLineNumber: 0, andParameterNumber: 0)

        XCTAssertEqual(kLocalizedNewElement, data?.currentValue)

        let values = data?.values as? [String]
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual(1, values?.count)
    }

    func testValuesForBackgroundObject() {
        currentScript.object = backgroundObject

        let data = BrickCellBackgroundData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)
        XCTAssertEqual(backgroundObject, data?.object)

        let values = data?.values as? [String]
        XCTAssertEqual(backgroundObject.lookList.count + 1, values?.count)
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual((backgroundObject.lookList[0] as? Look)?.name, values?[1])
        XCTAssertEqual((backgroundObject.lookList[1] as? Look)?.name, values?[2])
    }

    func testValuesForBackgroundObjectForScript() {
        whenBackgroundChangesScript.object = backgroundObject

        let data = BrickCellBackgroundData(frame: CGRect(), andBrickCell: scriptCell, andLineNumber: 0, andParameterNumber: 0)
        XCTAssertEqual(backgroundObject, data?.object)

        let values = data?.values as? [String]
        XCTAssertEqual(backgroundObject.lookList.count + 1, values?.count)
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual((backgroundObject.lookList[0] as? Look)?.name, values?[1])
        XCTAssertEqual((backgroundObject.lookList[1] as? Look)?.name, values?[2])
    }

    func testValuesForNormalObject() {
        currentScript.object = spriteObject

        let data = BrickCellBackgroundData(frame: CGRect(), andBrickCell: brickCell, andLineNumber: 0, andParameterNumber: 0)
        XCTAssertEqual(backgroundObject, data?.object)

        let values = data?.values as? [String]
        XCTAssertEqual(backgroundObject.lookList.count + 1, values?.count)
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual((backgroundObject.lookList[0] as? Look)?.name, values?[1])
        XCTAssertEqual((backgroundObject.lookList[1] as? Look)?.name, values?[2])
    }

    func testValuesForNormalObjectForScript() {
        whenBackgroundChangesScript.object = spriteObject

        let data = BrickCellBackgroundData(frame: CGRect(), andBrickCell: scriptCell, andLineNumber: 0, andParameterNumber: 0)
        XCTAssertEqual(backgroundObject, data?.object)

        let values = data?.values as? [String]
        XCTAssertEqual(backgroundObject.lookList.count + 1, values?.count)
        XCTAssertEqual(kLocalizedNewElement, values?[0])
        XCTAssertEqual((backgroundObject.lookList[0] as? Look)?.name, values?[1])
        XCTAssertEqual((backgroundObject.lookList[1] as? Look)?.name, values?[2])
    }
}
