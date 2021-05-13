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

final class BrickCopyTests: XCTestCase {

    var brick: SetTransparencyBrick!
    var object: SpriteObject!
    var script: StartScript!

    override func setUp() {
        super.setUp()
        object = SpriteObject()
        let scene = Scene(name: "testScene")
        object.scene = scene

        script = StartScript()
        script.object = object
    }

    func testLoopBrickCopy() {
        let loopBeginBrick = LoopBeginBrick()
        loopBeginBrick.script = self.script

        let hideBrick = HideBrick()
        hideBrick.script = self.script

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = self.script

        loopEndBrick.loopBeginBrick = loopBeginBrick
        loopBeginBrick.loopEndBrick = loopEndBrick

        self.script.brickList.add(loopBeginBrick)
        self.script.brickList.add(hideBrick)
        self.script.brickList.add(loopEndBrick)

        let amountBricks = self.script.brickList.count

        let indexPath = NSIndexPath.init()
        let copiedBricksIndexPaths = BrickManager.shared()?.scriptCollectionCopyBrick(with: indexPath as IndexPath, andBrick: loopBeginBrick)

        let amountBricksCopied = self.script.brickList.count

        XCTAssertEqual(amountBricksCopied, amountBricks * 2)
        XCTAssertEqual(amountBricks, copiedBricksIndexPaths?.count)
        XCTAssertTrue((self.script.brickList.object(at: 0) as! Brick).isEqual(to: self.script.brickList.object(at: 0 + amountBricks) as? Brick))
        XCTAssertTrue((self.script.brickList.object(at: 1) as! Brick).isEqual(to: self.script.brickList.object(at: 1 + amountBricks) as? Brick))
        XCTAssertTrue((self.script.brickList.object(at: 2) as! Brick).isEqual(to: self.script.brickList.object(at: 2 + amountBricks) as? Brick))
    }

    func testIfElseBrickCopy() {
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.ifCondition = Formula(integer: 1)
        ifLogicBeginBrick.script = self.script

        let hideBrick = HideBrick()
        hideBrick.script = self.script

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = self.script

        let showBrick = ShowBrick()
        showBrick.script = self.script

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = self.script

        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick

        self.script.brickList.add(ifLogicBeginBrick)
        self.script.brickList.add(hideBrick)
        self.script.brickList.add(ifLogicElseBrick)
        self.script.brickList.add(showBrick)
        self.script.brickList.add(ifLogicEndBrick)

        let amountBricks = self.script.brickList.count

        let indexPath = NSIndexPath.init()
        let copiedBricksIndexPaths = BrickManager.shared()?.scriptCollectionCopyBrick(with: indexPath as IndexPath, andBrick: ifLogicBeginBrick)
        let amountBricksCopied = self.script.brickList.count

        XCTAssertEqual(amountBricksCopied, amountBricks * 2)
        XCTAssertEqual(amountBricks, copiedBricksIndexPaths?.count)
        XCTAssertTrue((self.script.brickList.object(at: 0) as! Brick).isEqual(to: self.script.brickList.object(at: 0 + amountBricks) as? Brick))
        XCTAssertTrue((self.script.brickList.object(at: 1) as! Brick).isEqual(to: self.script.brickList.object(at: 1 + amountBricks) as? Brick))
        XCTAssertTrue((self.script.brickList.object(at: 2) as! Brick).isEqual(to: self.script.brickList.object(at: 2 + amountBricks) as? Brick))
        XCTAssertTrue((self.script.brickList.object(at: 3) as! Brick).isEqual(to: self.script.brickList.object(at: 3 + amountBricks) as? Brick))
        XCTAssertTrue((self.script.brickList.object(at: 4) as! Brick).isEqual(to: self.script.brickList.object(at: 4 + amountBricks) as? Brick))
    }

    func testIfThenBrickCopy() {
        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        ifThenLogicBeginBrick.ifCondition = Formula(integer: 1)
        ifThenLogicBeginBrick.script = self.script

        let hideBrick = HideBrick()
        hideBrick.script = self.script

        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicEndBrick.script = self.script

        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick

        self.script.brickList.add(ifThenLogicBeginBrick)
        self.script.brickList.add(hideBrick)
        self.script.brickList.add(ifThenLogicEndBrick)

        let amountBricks = self.script.brickList.count

        let indexPath = NSIndexPath.init()
        let copiedBricksIndexPaths = BrickManager.shared()?.scriptCollectionCopyBrick(with: indexPath as IndexPath, andBrick: ifThenLogicBeginBrick)

        let amountBricksCopied = self.script.brickList.count

        XCTAssertEqual(amountBricksCopied, amountBricks * 2)
        XCTAssertEqual(amountBricks, copiedBricksIndexPaths?.count)

        XCTAssertTrue((self.script.brickList.object(at: 0) as! Brick).isEqual(to: self.script.brickList.object(at: 0 + amountBricks) as? Brick))
        XCTAssertTrue((self.script.brickList.object(at: 1) as! Brick).isEqual(to: self.script.brickList.object(at: 1 + amountBricks) as? Brick))
        XCTAssertTrue((self.script.brickList.object(at: 2) as! Brick).isEqual(to: self.script.brickList.object(at: 2 + amountBricks) as? Brick))
    }

    func testAllNestedBricksCopy() {
        let loopBeginBrick = LoopBeginBrick()
        loopBeginBrick.script = self.script

        let hideBrick = HideBrick()
        hideBrick.script = self.script

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = self.script

        loopEndBrick.loopBeginBrick = loopBeginBrick
        loopBeginBrick.loopEndBrick = loopEndBrick

        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.ifCondition = Formula(integer: 1)
        ifLogicBeginBrick.script = self.script

        let nextLookBrick = NextLookBrick()
        nextLookBrick.script = self.script

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = self.script

        let showBrick = ShowBrick()
        showBrick.script = self.script

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = self.script

        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick

        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        ifThenLogicBeginBrick.ifCondition = Formula(integer: 1)
        ifThenLogicBeginBrick.script = self.script

        let previousLookBrick = PreviousLookBrick()
        previousLookBrick.script = self.script

        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicEndBrick.script = self.script

        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick

        self.script.brickList.add(loopBeginBrick)
        self.script.brickList.add(hideBrick)
        self.script.brickList.add(ifLogicBeginBrick)
        self.script.brickList.add(nextLookBrick)
        self.script.brickList.add(ifLogicElseBrick)
        self.script.brickList.add(ifThenLogicBeginBrick)
        self.script.brickList.add(previousLookBrick)
        self.script.brickList.add(ifThenLogicEndBrick)
        self.script.brickList.add(showBrick)
        self.script.brickList.add(ifLogicEndBrick)
        self.script.brickList.add(loopEndBrick)

        let amountBricks = self.script.brickList.count

        let indexPath = NSIndexPath.init()
        let copiedBricksIndexPaths = BrickManager.shared()?.scriptCollectionCopyBrick(with: indexPath as IndexPath, andBrick: loopBeginBrick)

        let amountBricksCopied = self.script.brickList.count

        XCTAssertEqual(amountBricksCopied, amountBricks * 2)
        XCTAssertEqual(amountBricks, copiedBricksIndexPaths?.count)

        for i in 0...amountBricks - 1 {
            XCTAssertTrue((self.script.brickList.object(at: i) as! Brick).isEqual(to: self.script.brickList.object(at: i + amountBricks) as? Brick))
        }
    }

}
