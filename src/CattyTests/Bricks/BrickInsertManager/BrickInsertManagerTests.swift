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

final class BrickInsertManagerTests: BrickInsertManagerAbstractTest {
    func testInsertWaitBehindSetVariableBrick() {
        viewController!.collectionView.reloadData()

        let waitBrick = WaitBrick()
        waitBrick.script = startScript
        startScript!.brickList.add(waitBrick as Any)

        let setVariableBrick = SetVariableBrick()
        setVariableBrick.script = startScript
        startScript!.brickList.add(setVariableBrick as Any)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(3, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        let indexPathTo = IndexPath(row: 2, section: 0)

        waitBrick.isAnimatedInsertBrick = true
        let canInsert = BrickInsertManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canInsertTo: indexPathTo, andObject: spriteObject)

        XCTAssertTrue(canInsert, "Should be allowed to insert WaitBrick behind SetVariableBrick")
    }

    func testInsertWaitBehindForeverBrick() {
        viewController!.collectionView.reloadData()

        let waitBrick = WaitBrick()
        waitBrick.script = startScript
        startScript!.brickList.add(waitBrick as Any)

        let foreverBrick = ForeverBrick()
        foreverBrick.script = startScript
        startScript!.brickList.add(foreverBrick as Any)

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = foreverBrick
        startScript!.brickList.add(loopEndBrick as Any)
        foreverBrick.loopEndBrick = loopEndBrick

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(4, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        var indexPathTo = IndexPath(row: 2, section: 0)

        waitBrick.isAnimatedInsertBrick = true
        let canInsertWaitBrickInsideForeverBrick = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canInsertWaitBrickInsideForeverBrick, "Should be allowed to insert WaitBrick inside ForeverBrick")

        indexPathTo = IndexPath(row: 3, section: 0)
        let canMoveWaitBrickBehindForeverBrick = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveWaitBrickBehindForeverBrick, "Should not be allowed to insert WaitBrick behind ForeverBrick")
    }

    func testInsertWaitBehindRepeatBrick() {
        viewController!.collectionView.reloadData()

        let waitBrick = WaitBrick()
        waitBrick.script = startScript
        startScript!.brickList.add(waitBrick as Any)

        let repeatBrick = RepeatBrick()
        repeatBrick.script = startScript
        startScript!.brickList.add(repeatBrick as Any)

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = repeatBrick
        startScript!.brickList.add(loopEndBrick as Any)
        repeatBrick.loopEndBrick = loopEndBrick

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(4, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)

        waitBrick.isAnimatedInsertBrick = true
        let canInsertWaitBrickBehindRepeatBrick = BrickInsertManager
            .sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canInsertTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canInsertWaitBrickBehindRepeatBrick, "Should be allowed to insert WaitBrick behind RepeatBrick")
    }

    func testCopyIfThenLogicBeginBrick() {
        viewController!.collectionView.reloadData()

        let ifThenLogicBeginBrick = IfThenLogicBeginBrick()
        ifThenLogicBeginBrick.ifCondition = Formula(integer: 3)
        ifThenLogicBeginBrick.script = startScript

        let ifThenLogicEndBrick = IfThenLogicEndBrick()
        ifThenLogicEndBrick.script = startScript
        ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick
        ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick

        startScript!.brickList.add(ifThenLogicBeginBrick as Any)
        startScript!.brickList.add(ifThenLogicEndBrick as Any)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(3, viewController!.collectionView.numberOfItems(inSection: 0))
        XCTAssertEqual(2, startScript!.brickList.count)

        let indexPath = IndexPath(row: 1, section: 0)

        let copiedBricksIndexPaths = BrickManager.shared().scriptCollectionCopyBrick(with: indexPath, andBrick: ifThenLogicBeginBrick)

        XCTAssertEqual(2, copiedBricksIndexPaths!.count)
        XCTAssertEqual(indexPath.section, (copiedBricksIndexPaths![0] as! IndexPath).section)
        XCTAssertEqual(indexPath.row, (copiedBricksIndexPaths![0] as! IndexPath).row)
        XCTAssertEqual(indexPath.section, (copiedBricksIndexPaths![1] as! IndexPath).section)
        XCTAssertEqual(indexPath.row + 1, (copiedBricksIndexPaths![1] as! IndexPath).row)
        XCTAssertEqual(4, startScript!.brickList.count)
    }
}
