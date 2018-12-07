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

final class BrickInsertManagerLogicTests: BrickInsertManagerAbstractTest {

    func testInsertForeverBrickInsideIfBrick() {
        viewController!.collectionView.reloadData()

        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        startScript!.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        startScript!.brickList.add(ifLogicEndBrick as Any)

        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick

        let foreverBrick = ForeverBrick()
        foreverBrick.script = startScript
        startScript!.brickList.add(foreverBrick as Any)

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = foreverBrick
        startScript!.brickList.add(loopEndBrick as Any)
        foreverBrick.loopEndBrick = loopEndBrick

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(6, viewController!.collectionView.numberOfItems(inSection: 0))

        // if-branch
        var indexPathFrom = IndexPath(row: 4, section: 0)
        var indexPathTo = IndexPath(row: 2, section: 0)

        foreverBrick.isAnimatedInsertBrick = true
        var canMoveInsideIfBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveInsideIfBrickInsertMode, "Should be allowed to move ForeverBrick inside if-branch IfLogicBeginBrick")

        // else-branch
        indexPathFrom = IndexPath(row: 4, section: 0)
        indexPathTo = IndexPath(row: 3, section: 0)

        foreverBrick.isAnimatedInsertBrick = true
        canMoveInsideIfBrickInsertMode = BrickInsertManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canInsertTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveInsideIfBrickInsertMode, "Should be allowed to move ForeverBrick inside else-branch of IfLogicBeginBrick")
    }

    func testInsertForeverBrickInsideIfThenBrick() {
        viewController!.collectionView.reloadData()

        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        ifThenLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifThenLogicBeginBrick as Any)

        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicEndBrick.script = startScript
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick
        startScript!.brickList.add(ifThenLogicEndBrick as Any)

        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick

        let foreverBrick = ForeverBrick()
        foreverBrick.script = startScript
        startScript!.brickList.add(foreverBrick as Any)

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = foreverBrick
        startScript!.brickList.add(loopEndBrick as Any)
        foreverBrick.loopEndBrick = loopEndBrick

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(5, viewController!.collectionView.numberOfItems(inSection: 0))

        // if-branch
        let indexPathFrom = IndexPath(row: 3, section: 0)
        let indexPathTo = IndexPath(row: 2, section: 0)

        foreverBrick.isAnimatedInsertBrick = true
        let canMoveInsideIfBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveInsideIfBrickInsertMode, "Should be allowed to move ForeverBrick inside if-branch IfLogicBeginBrick")
    }

    func testInsertIfBrickAboveIfBrick() {
        viewController!.collectionView.reloadData()

        let ifLogicBeginBrick1 = IfLogicBeginBrick()
        ifLogicBeginBrick1.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick1 as Any)

        // begin nested if
        let ifLogicBeginBrick2 = IfLogicBeginBrick()
        ifLogicBeginBrick2.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick2 as Any)

        let ifLogicElseBrick2 = IfLogicElseBrick()
        ifLogicElseBrick2.script = startScript
        ifLogicElseBrick2.ifBeginBrick = ifLogicBeginBrick2
        startScript!.brickList.add(ifLogicElseBrick2 as Any)
        ifLogicBeginBrick2.ifElseBrick = ifLogicElseBrick2

        let ifLogicEndBrick2 = IfLogicEndBrick()
        ifLogicEndBrick2.script = startScript
        ifLogicEndBrick2.ifBeginBrick = ifLogicBeginBrick2
        ifLogicEndBrick2.ifElseBrick = ifLogicElseBrick2
        startScript!.brickList.add(ifLogicEndBrick2 as Any)

        ifLogicBeginBrick2.ifEndBrick = ifLogicEndBrick2
        ifLogicElseBrick2.ifEndBrick = ifLogicEndBrick2
        // end nested if

        let ifLogicElseBrick1 = IfLogicElseBrick()
        ifLogicElseBrick1.script = startScript
        ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1
        startScript!.brickList.add(ifLogicElseBrick1)
        ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1

        let ifLogicEndBrick1 = IfLogicEndBrick()
        ifLogicEndBrick1.script = startScript
        ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1
        ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1
        startScript!.brickList.add(ifLogicEndBrick1 as Any)

        ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1
        ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(7, viewController!.collectionView.numberOfItems(inSection: 0))

        // nested if brick
        let indexPathFrom = IndexPath(row: 2, section: 0)
        let indexPathTo = IndexPath(row: 1, section: 0)

        ifLogicBeginBrick2.isAnimatedInsertBrick = true
        let canInsertAboveIfBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canInsertAboveIfBrickInsertMode, "Should be allowed to insert nested IfLogicBeginBrick above main IfLogicBeginBrick")
    }

    func testInsertIfLogicBeginBricksInsideElseBranch() {
        viewController!.collectionView.reloadData()

        let ifLogicBeginBrick1 = IfLogicBeginBrick()
        ifLogicBeginBrick1.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick1 as Any)

        let ifLogicElseBrick1 = IfLogicElseBrick()
        ifLogicElseBrick1.script = startScript
        ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1
        startScript!.brickList.add(ifLogicElseBrick1 as Any)
        ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1

        // begin nested if
        let ifLogicBeginBrick2 = IfLogicBeginBrick()
        ifLogicBeginBrick2.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick2 as Any)

        let ifLogicElseBrick2 = IfLogicElseBrick()
        ifLogicElseBrick2.script = startScript
        ifLogicElseBrick2.ifBeginBrick = ifLogicBeginBrick2
        startScript!.brickList.add(ifLogicElseBrick2 as Any)
        ifLogicBeginBrick2.ifElseBrick = ifLogicElseBrick2

        let ifLogicEndBrick2 = IfLogicEndBrick()
        ifLogicEndBrick2.script = startScript
        ifLogicEndBrick2.ifBeginBrick = ifLogicBeginBrick2
        ifLogicEndBrick2.ifElseBrick = ifLogicElseBrick2
        startScript!.brickList.add(ifLogicEndBrick2 as Any)

        ifLogicBeginBrick2.ifEndBrick = ifLogicEndBrick2
        ifLogicElseBrick2.ifEndBrick = ifLogicEndBrick2
        // end nested if

        let ifLogicEndBrick1 = IfLogicEndBrick()
        ifLogicEndBrick1.script = startScript
        ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1
        ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1
        startScript!.brickList.add(ifLogicEndBrick1 as Any)

        ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1
        ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(7, viewController!.collectionView.numberOfItems(inSection: 0))

        // nested if brick
        var indexPathFrom = IndexPath(row: 3, section: 0)
        var indexPathTo = IndexPath(row: 2, section: 0)

        ifLogicBeginBrick2.isAnimatedInsertBrick = true
        let canInsertAboveIfBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canInsertAboveIfBrickInsertMode, "Should be allowed to insert nested IfLogicBeginBrick above main IfLogicElseBrick")

        // main else brick
        ifLogicBeginBrick2.isAnimatedInsertBrick = false
        indexPathFrom = IndexPath(row: 2, section: 0)
        indexPathTo = IndexPath(row: 3, section: 0)

        ifLogicElseBrick1.isAnimatedInsertBrick = true
        let canInsertBelowIfBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canInsertBelowIfBrickInsertMode, "Should be allowed to insert main IfLogicElseBrick below nested IfLogicElseBrick")
    }

    func testInsertIfThenLogicBeginBricksInsideElseBranch() {
        viewController!.collectionView.reloadData()

        let ifLogicBeginBrick1 = IfLogicBeginBrick()
        ifLogicBeginBrick1.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick1 as Any)

        let ifLogicElseBrick1 = IfLogicElseBrick()
        ifLogicElseBrick1.script = startScript
        ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1
        startScript!.brickList.add(ifLogicElseBrick1 as Any)
        ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1

        // begin nested if - then
        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        ifThenLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifThenLogicBeginBrick as Any)

        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicEndBrick.script = startScript
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick
        startScript!.brickList.add(ifThenLogicEndBrick as Any)

        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick
        // end nested if - then

        let ifLogicEndBrick1 = IfLogicEndBrick()
        ifLogicEndBrick1.script = startScript
        ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1
        ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1
        startScript!.brickList.add(ifLogicEndBrick1 as Any)

        ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1
        ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(6, viewController!.collectionView.numberOfItems(inSection: 0))

        // nested if brick
        let indexPathFrom = IndexPath(row: 3, section: 0)
        let indexPathTo = IndexPath(row: 2, section: 0)

        ifThenLogicBeginBrick.isAnimatedInsertBrick = true
        let canInsertAboveIfBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canInsertAboveIfBrickInsertMode, "Should be allowed to insert nested IfThenLogicBeginBrick above main IfLogicElseBrick")
    }

    func testInsertMoveLogicBricks() {
        viewController!.collectionView.reloadData()

        let ifLogicBeginBrick1 = IfLogicBeginBrick()
        ifLogicBeginBrick1.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick1 as Any)

        let ifLogicElseBrick1 = IfLogicElseBrick()
        ifLogicElseBrick1.script = startScript
        ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1
        startScript!.brickList.add(ifLogicElseBrick1 as Any)
        ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1

        let ifLogicEndBrick1 = IfLogicEndBrick()
        ifLogicEndBrick1.script = startScript
        ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1
        ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1
        startScript!.brickList.add(ifLogicEndBrick1 as Any)

        ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1
        ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1

        let ifLogicBeginBrick2 = IfLogicBeginBrick()
        ifLogicBeginBrick2.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick2 as Any)

        let ifLogicElseBrick2 = IfLogicElseBrick()
        ifLogicElseBrick2.script = startScript
        ifLogicElseBrick2.ifBeginBrick = ifLogicBeginBrick2
        startScript!.brickList.add(ifLogicElseBrick2 as Any)
        ifLogicBeginBrick2.ifElseBrick = ifLogicElseBrick2

        let ifLogicEndBrick2 = IfLogicEndBrick()
        ifLogicEndBrick2.script = startScript
        ifLogicEndBrick2.ifBeginBrick = ifLogicBeginBrick2
        ifLogicEndBrick2.ifElseBrick = ifLogicElseBrick2
        startScript!.brickList.add(ifLogicEndBrick2 as Any)

        ifLogicBeginBrick2.ifEndBrick = ifLogicEndBrick2
        ifLogicElseBrick2.ifEndBrick = ifLogicEndBrick2

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(7, viewController!.collectionView.numberOfItems(inSection: 0))

        // second if brick (move up)
        var indexPathFrom = IndexPath(row: 4, section: 0)
        var indexPathTo = IndexPath(row: 3, section: 0)

        ifLogicBeginBrick2.isAnimatedInsertBrick = true
        let canInsertAboveEndBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canInsertAboveEndBrickInsertMode, "Should be allowed to insert IfLogicBeginBrick above IfLogicEndBrick")

        // first end brick (move down)
        ifLogicBeginBrick2.isAnimatedInsertBrick = false
        indexPathFrom = IndexPath(row: 3, section: 0)
        indexPathTo = IndexPath(row: 4, section: 0)

        ifLogicEndBrick1.isAnimatedInsertBrick = true
        let canInsertBelowIfBeginBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canInsertBelowIfBeginBrickInsertMode,
                      "Should not allowed to insert IfLogicEndBrick below IfLogicBeginBrick")
    }
}
