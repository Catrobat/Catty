/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

final class CBXMLParserHelperTests: XCTestCase {

    func testFindUserVariableInArray() {
        let userVariableA = UserVariable(name: "userVariableA")
        let userVariableArray = [userVariableA]

        XCTAssertNotNil(CBXMLParserHelper.findUserVariable(in: userVariableArray, withName: userVariableA.name))
        XCTAssertNil(CBXMLParserHelper.findUserVariable(in: userVariableArray, withName: "userVariable"))
    }

    func testFindUserListInArray() {
        let userListA = UserList(name: "userListA")
        let userListArray = [userListA]

        XCTAssertNotNil(CBXMLParserHelper.findUserList(in: userListArray, withName: userListA.name))
        XCTAssertNil(CBXMLParserHelper.findUserList(in: userListArray, withName: "userList"))
    }

    func testGetDepthOfResourceAndRelativePathToResourceList() {
        let scene = Scene(name: "testScene")
        let object = SpriteObject()
        object.scene = scene
        let project = Project()
        project.scene = object.scene

        let spriteNode = CBSpriteNode(spriteObject: object)
        let startScript = StartScript()
        object.spriteNode = spriteNode
        object.scene.project = project
        object.scriptList.add(startScript)

        let lookBrick = SetLookBrick()
        let look = Look(name: "lookResource", filePath: "look")
        lookBrick.look = look
        object.add(look, andSaveToDisk: false)
        startScript.add(lookBrick, at: 0)

        let soundBrick = PlaySoundAndWaitBrick()
        let sound = Sound(name: "soundResource", fileName: "sound")
        soundBrick.sound = sound
        object.soundList.add(sound)
        startScript.add(soundBrick, at: 1)

        let expected_relativePathLook = "../../../../../lookList/look"
        let expected_relativePathSound = "../../../../../soundList/sound"
        let expected_depth = 5

        XCTAssertEqual(CBXMLSerializerHelper.getDepthOfResource(lookBrick, for: object), expected_depth)
        XCTAssertEqual(CBXMLSerializerHelper.getDepthOfResource(soundBrick, for: object), expected_depth)
        XCTAssertEqual(CBXMLSerializerHelper.relativeXPath(to: look, inLookList: object.lookList as? [Any], withDepth: expected_depth), expected_relativePathLook)
        XCTAssertEqual(CBXMLSerializerHelper.relativeXPath(to: sound, inSoundList: (object.soundList as! [Any]), withDepth: expected_depth), expected_relativePathSound)
    }
}
