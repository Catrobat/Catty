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

final class BrickInsertManagerRepeatTests: BrickInsertManagerAbstractTest {
    func testInsertNestedRepeatBricks() {
        viewController!.collectionView.reloadData()

        let repeatBrickA = RepeatBrick()
        repeatBrickA.script = startScript
        startScript!.brickList.add(repeatBrickA as Any)

        let loopEndBrickA = LoopEndBrick()
        loopEndBrickA.script = startScript
        loopEndBrickA.loopBeginBrick = repeatBrickA
        startScript!.brickList.add(loopEndBrickA as Any)
        repeatBrickA.loopEndBrick = loopEndBrickA

        let repeatBrickB = RepeatBrick()
        repeatBrickB.script = startScript
        startScript!.brickList.add(repeatBrickB as Any)

        let loopEndBrickB = LoopEndBrick()
        loopEndBrickB.script = startScript
        loopEndBrickB.loopBeginBrick = repeatBrickB
        startScript!.brickList.add(loopEndBrickB as Any)
        repeatBrickB.loopEndBrick = loopEndBrickB

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(5, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)

        repeatBrickA.isAnimatedInsertBrick = true
        let canMoveInsideRepeatBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveInsideRepeatBrickInsertMode, "Should be allowed to insert RepeatBrick inside other RepeatBrick")
    }

    func testInsertIfBrickInsideRepeatBrick() {
        viewController!.collectionView.reloadData()

        let repeatBrick = RepeatBrick()
        repeatBrick.script = startScript
        startScript!.brickList.add(repeatBrick as Any)

        // start if
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
        // end if

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = repeatBrick
        startScript!.brickList.add(loopEndBrick as Any)
        repeatBrick.loopEndBrick = loopEndBrick

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(6, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above repeat brick
        let indexPathFrom = IndexPath(row: 2, section: 0)
        let indexPathTo = IndexPath(row: 1, section: 0)

        ifLogicBeginBrick.isAnimatedInsertBrick = true
        let canMoveAboveRepeatBrickInsertMode = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveAboveRepeatBrickInsertMode, "Should be allowed to move IfBrick inside repeat-loop above RepeatBrick")
    }
}
