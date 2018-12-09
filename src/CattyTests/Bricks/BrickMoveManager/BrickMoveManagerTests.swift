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

final class BrickMoveManagerTests: BrickMoveManagerAbstractTest {
    func testMoveWaitBehindSetVariableBrick() {

        /*  Test:
             
             0 startedScript
             1  wait            --->
             2  setVariable     <---
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        let waitBrick = WaitBrick()
        waitBrick.script = startScript
        startScript!.brickList.add(waitBrick as Any)
        addedBricks += 1

        let setVariableBrick = SetVariableBrick()
        setVariableBrick.script = startScript
        startScript!.brickList.add(setVariableBrick as Any)
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        let indexPathTo = IndexPath(row: 2, section: 0)

        let canMove = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)

        XCTAssertTrue(canMove, "Should be allowed to move WaitBrick behind SetVariableBrick")
    }

    func testMoveWaitBehindForeverBrick() {

        /*  Test:
             
             0 startedScript      (1)        (2)
             1  wait             --->       --->
             2  foreverBeginA    <---
             3  foreverEndA                 <---
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        let waitBrick = WaitBrick()
        waitBrick.script = startScript
        startScript!.brickList.add(waitBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)

        do {
            let indexPathTo = IndexPath(row: 2, section: 0)

            let canMoveWaitBrickInsideForeverBrick = BrickMoveManager
                .sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertTrue(canMoveWaitBrickInsideForeverBrick, "Should be allowed to move WaitBrick inside ForeverBrick")
        }

        do {
            let indexPathTo = IndexPath(row: 3, section: 0)
            let canMoveWaitBrickBehindForeverBrick = BrickMoveManager
                .sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveWaitBrickBehindForeverBrick, "Should not be allowed to move WaitBrick behind ForeverBrick")
        }

    }

    func testMoveWaitBehindRepeatBrick() {

        /*  Test:
             0 startedScript
             1  wait            --->
             2  repeatBeginA
             3  repeatEndA      <---
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        let waitBrick = WaitBrick()
        waitBrick.script = startScript
        startScript!.brickList.add(waitBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyRepeatLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)

        let canMoveWaitBrickBehindRepeatBrick = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveWaitBrickBehindRepeatBrick, "Should be allowed to move WaitBrick behind RepeatBrick")
    }

    func testMoveWaitBrickIntoOtherScript() {

        /*  Test:
             
             0 startedScript
             1  wait            --->
             
             0 whenScript
             1                   <---
             */

        viewController!.collectionView.reloadData()

        var addedSections: Int = 1
        var addedBricksStart: Int = 1

        let waitBrick = WaitBrick()
        waitBrick.script = startScript
        startScript!.brickList.add(waitBrick as Any)
        addedBricksStart += 1

        let whenScript = WhenScript()
        whenScript.object = spriteObject
        spriteObject!.scriptList.add(whenScript as Any)
        let addedBricksWhen: Int = 1
        addedSections += 1

        XCTAssertEqual(addedSections, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricksStart, viewController!.collectionView.numberOfItems(inSection: 0))
        XCTAssertEqual(addedBricksWhen, viewController!.collectionView.numberOfItems(inSection: 1))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        let indexPathTo = IndexPath(row: 0, section: 1)

        let canMoveWaitInOtherScript = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveWaitInOtherScript, "Should be allowed to move WaitBrick into other Script")
    }

    func testMoveForeverBeginBrickWithMultipleScripts() {
        /*  Test:
             
             0 startedScript
             1  foreverBeginA
             2      waitA
             3  foreverEndA
             
             0 whenScript
             1  foreverBeginB            --->
             2      waitB              (valid)
             3  foreverEndB
             */

        viewController!.collectionView.reloadData()

        var addedSections: Int = 1
        var addedBricksStart: Int = 1

        let validRow: Int = 2
        let validSection: Int = 1
        let validTarget = IndexPath(row: validRow, section: validSection)

        addedBricksStart += addForeverLoopWithWaitBrick(to: startScript)

        let whenScript = WhenScript()
        whenScript.object = spriteObject
        spriteObject!.scriptList.add(whenScript as Any)
        var addedBricksWhen: Int = 1
        addedSections += 1

        addedBricksWhen += addForeverLoopWithWaitBrick(to: whenScript)

        XCTAssertEqual(addedSections, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricksStart, viewController!.collectionView.numberOfItems(inSection: 0))
        XCTAssertEqual(addedBricksWhen, viewController!.collectionView.numberOfItems(inSection: 1))

        let indexPathFrom = IndexPath(row: 1, section: 1)

        for section in 0..<addedSections {
            for destinationIDX in 1..<addedBricksStart {
                let indexPathTo = IndexPath(row: destinationIDX, section: section)

                if !(indexPathTo == validTarget) && destinationIDX != indexPathFrom.item {
                    BrickMoveManager.sharedInstance().reset()
                    let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to idx %lu in section %lu", UInt(destinationIDX), UInt(section)))
                }
            }
        }
        BrickMoveManager.sharedInstance().reset()
        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: validTarget, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, String(format: "Should be allowed to move to idx %lu in section %lu", UInt(validRow), UInt(validSection)))
    }

    func testMoveForeverEndBrickWithMultipleScripts() {
        /*  Test:
             
             0 startedScript
             1  foreverBeginA
             2      waitA
             3  foreverEndA
             
             0 whenScript
             1  foreverBeginB
             2      waitB
             3  foreverEndB             --->
             */

        viewController!.collectionView.reloadData()

        var addedSections: Int = 1
        var addedBricksStart: Int = 1

        addedBricksStart += addForeverLoopWithWaitBrick(to: startScript)

        let whenScript = WhenScript()
        whenScript.object = spriteObject
        spriteObject!.scriptList.add(whenScript as Any)
        var addedBricksWhen: Int = 1
        addedSections += 1

        addedBricksWhen += addForeverLoopWithWaitBrick(to: whenScript)

        XCTAssertEqual(addedBricksWhen, addedBricksStart)
        XCTAssertEqual(addedSections, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricksStart, viewController!.collectionView.numberOfItems(inSection: 0))
        XCTAssertEqual(addedBricksWhen, viewController!.collectionView.numberOfItems(inSection: 1))

        let indexPathFrom = IndexPath(row: 3, section: 1)

        for section in 0..<addedSections {
            for destinationIDX in 1..<addedBricksStart {
                let indexPathTo = IndexPath(row: destinationIDX, section: section)

                let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
                XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to idx %lu in section %lu", UInt(destinationIDX), UInt(section)))
            }
        }
    }

    func testMoveRepeatBeginBrickWithMultipleScripts() {
        /*  Test:
             
             0 startedScript
             1  repeatBeginA
             2      waitA
             3  repeatEndA
             
             0 whenScript
             1  repeatBeginB            --->
             2      waitB              (valid)
             3  repeatEndB
             */

        viewController!.collectionView.reloadData()

        var addedSections: Int = 1
        var addedBricksStart: Int = 1

        let validRow: Int = 2
        let validSection: Int = 1
        let validTarget = IndexPath(row: validRow, section: validSection)

        addedBricksStart += addRepeatLoopWithWaitBrick(to: startScript)

        let whenScript = WhenScript()
        whenScript.object = spriteObject
        spriteObject!.scriptList.add(whenScript as Any)
        var addedBricksWhen: Int = 1
        addedSections += 1

        addedBricksWhen += addRepeatLoopWithWaitBrick(to: whenScript)

        XCTAssertEqual(addedSections, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricksStart, viewController!.collectionView.numberOfItems(inSection: 0))
        XCTAssertEqual(addedBricksWhen, viewController!.collectionView.numberOfItems(inSection: 1))

        let indexPathFrom = IndexPath(row: 1, section: 1)
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 3, section: 1)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 0, section: 1)
        for section in 0..<addedSections {
            for destinationIDX in 1..<addedBricksStart {
                let indexPathTo = IndexPath(row: destinationIDX, section: section)

                if !(indexPathTo == validTarget) && destinationIDX != indexPathFrom.item {
                    BrickMoveManager.sharedInstance().reset()
                    let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to idx %lu in section %lu", UInt(destinationIDX), UInt(section)))
                }
            }
        }
        BrickMoveManager.sharedInstance().reset()
        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: validTarget, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, String(format: "Should be allowed to move to idx %lu in section %lu", UInt(validRow), UInt(validSection)))

    }

    func testMoveRepeatEndBrickWithMultipleScripts() {
        /*  Test:
             
             0 startedScript
             1  repeatBeginA
             2      waitA
             3  repeatEndA
             
             0 whenScript
             1  repeatBeginB
             2      waitB              (valid)
             3  repeatEndB              --->
             */

        viewController!.collectionView.reloadData()
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        var addedSections: Int = 1
        var addedBricksStart: Int = 1

        let validRow: Int = 2
        let validSection: Int = 1
        let validTarget = IndexPath(row: validRow, section: validSection)

        addedBricksStart += addRepeatLoopWithWaitBrick(to: startScript)

        let whenScript = WhenScript()
        whenScript.object = spriteObject
        spriteObject!.scriptList.add(whenScript as Any)
        var addedBricksWhen: Int = 1
        addedSections += 1

        addedBricksWhen += addRepeatLoopWithWaitBrick(to: whenScript)

        XCTAssertEqual(addedSections, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricksStart, viewController!.collectionView.numberOfItems(inSection: 0))
        XCTAssertEqual(addedBricksWhen, viewController!.collectionView.numberOfItems(inSection: 1))

        let indexPathFrom = IndexPath(row: 3, section: 1)
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 3, section: 1)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 1, section: 1)
        for section in 0..<addedSections {
            for destinationIDX in 1..<addedBricksStart {
                let indexPathTo = IndexPath(row: destinationIDX, section: section)

                if !(indexPathTo == validTarget) && destinationIDX != indexPathFrom.item {
                    let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to idx %lu in section %lu", UInt(destinationIDX), UInt(section)))
                }
            }
        }

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: validTarget, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, String(format: "Should be allowed to move to idx %lu in section %lu", UInt(validRow), UInt(validSection)))

    }

    func testMoveMoveableBricksAround() {
        /*  Test:
             0 startedScript
             1  waitBrickA
             2  setXBrickA
             3  setYBrickA
             4  waitBrickB
             5  placeAtXYA
             6  waitBrickC
             
             0 whenScriptA
             1  waitBrickA
             2  setXBrickA
             3  setYBrickA
             4  waitBrickB
             5  placeAtXYA
             6  waitBrickC
             
             0 whenScriptB
             1  waitBrickA
             2  setXBrickA
             3  setYBrickA
             4  waitBrickB
             5  placeAtXYA
             6  waitBrickC
             
             0 whenScriptC
             1  waitBrickA
             2  setXBrickA
             3  setYBrickA
             4  waitBrickB
             5  placeAtXYA
             6  waitBrickC
             */

        viewController!.collectionView.reloadData()

        var addedSections: Int = 1
        var addedBricksStart: Int = 1

        addedBricksStart += addWaitSetXSetYWaitPlaceAtWaitBricks(to: startScript)

        let whenScriptA = WhenScript()
        whenScriptA.object = spriteObject
        spriteObject!.scriptList.add(whenScriptA as Any)
        var addedBricksWhenA: Int = 1
        addedSections += 1
        addedBricksWhenA += addWaitSetXSetYWaitPlaceAtWaitBricks(to: whenScriptA)

        let whenScriptB = WhenScript()
        whenScriptB.object = spriteObject
        spriteObject!.scriptList.add(whenScriptB as Any)
        var addedBricksWhenB: Int = 1
        addedSections += 1
        addedBricksWhenB += addWaitSetXSetYWaitPlaceAtWaitBricks(to: whenScriptB)

        let whenScriptC = WhenScript()
        whenScriptC.object = spriteObject
        spriteObject!.scriptList.add(whenScriptC as Any)
        var addedBricksWhenC: Int = 1
        addedSections += 1
        addedBricksWhenC += addWaitSetXSetYWaitPlaceAtWaitBricks(to: whenScriptC)

        XCTAssertTrue((addedBricksWhenA == addedBricksWhenB) && (addedBricksWhenB == addedBricksWhenC))
        XCTAssertEqual(addedSections, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricksStart, viewController!.collectionView.numberOfItems(inSection: 0))
        XCTAssertEqual(addedBricksWhenA, viewController!.collectionView.numberOfItems(inSection: 1))
        XCTAssertEqual(addedBricksWhenB, viewController!.collectionView.numberOfItems(inSection: 2))
        XCTAssertEqual(addedBricksWhenC, viewController!.collectionView.numberOfItems(inSection: 3))

        for sourceSection in 0..<addedSections {
            for sourceIDX in 1..<addedBricksStart {

                let indexPathFrom = IndexPath(row: sourceIDX, section: sourceSection)

                for destinationSection in 0..<addedSections {
                    for destinationIDX in 1..<addedBricksStart {

                        let indexPathTo = IndexPath(row: destinationIDX, section: destinationSection)

                        let canMoveToDestination = BrickMoveManager
                            .sharedInstance()
                            .collectionView(viewController!.collectionView,
                                            itemAt: indexPathFrom,
                                            canMoveTo: indexPathTo,
                                            andObject: spriteObject)
                        let errorMsg = String(format: "Should be allowed to move from section %lu, row %lu to section %lu, row %lu",
                                              UInt(sourceSection),
                                              UInt(sourceIDX),
                                              UInt(destinationSection),
                                              UInt(destinationIDX))
                        XCTAssertTrue(canMoveToDestination, errorMsg)
                    }
                }
            }
        }
    }
}
