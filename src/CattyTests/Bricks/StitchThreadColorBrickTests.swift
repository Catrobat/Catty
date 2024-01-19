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

final class StitchThreadColorBrickTests: AbstractBrickTest {

    func testStichThreadColorBrick() {
        super.setUp()

        let spriteObject = SpriteObject()
        let scene = Scene(name: "testScene")
        spriteObject.scene = scene

        let spriteNode = CBSpriteNode(spriteObject: spriteObject)
        let script = Script()
        script.object = spriteObject

        let brick = StitchThreadColorBrick()
        brick.script = script
        let action = brick.actionBlock(self.formulaInterpreter)

        let stream = spriteNode.embroideryStream
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        action()
        stream.add(Stitch(atPosition: CGPoint(x: 250, y: 0)))

        XCTAssertFalse(stream[0].isColorChange)
        XCTAssertTrue(stream[1].isColorChange)
        XCTAssertEqual(stream[1].getColor(), UIColor(red: 255, green: 0, blue: 0))
    }

    func testStichThreadColorBrickWithOtherColor() {
        super.setUp()

        let spriteObject = SpriteObject()
        let scene = Scene(name: "testScene")
        spriteObject.scene = scene

        let spriteNode = CBSpriteNode(spriteObject: spriteObject)
        let script = Script()
        script.object = spriteObject

        let brick = StitchThreadColorBrick()
        brick.script = script
        let action = brick.actionBlock(self.formulaInterpreter)

        let stream = spriteNode.embroideryStream
        stream.add(Stitch(atPosition: CGPoint(x: 0, y: 0)))
        brick.stitchColor = Formula(string: "#00ff00")
        action()
        stream.add(Stitch(atPosition: CGPoint(x: 250, y: 0)))

        XCTAssertFalse(stream[0].isColorChange)
        XCTAssertTrue(stream[1].isColorChange)
        XCTAssertEqual(stream[1].getColor(), UIColor(red: 0, green: 255, blue: 0))
    }
}
