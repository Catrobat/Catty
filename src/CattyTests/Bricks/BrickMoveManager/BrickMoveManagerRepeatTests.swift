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

final class BrickMoveManagerRepeatTests: BrickMoveManagerAbstractTest {
    func testMoveNestedRepeatBricks() {

        /*  Test:
             
             0 startedScript
             1  repeatBeginA    --->
             2  repeatEndA
             3  repeatBeginB    <---
             4  repeatEndB
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addEmptyRepeatLoop(to: startScript)

        addedBricks += addEmptyRepeatLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 2, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 0, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move RepeatBrick inside other RepeatBrick")
    }

    func testMoveIfBrickInsideRepeatBrick() {

        /*  Test:
             
             0 startedScript
             1  repeatBeginA    <---
             2      ifBeginA    --->
             3      elseA
             4      ifEndA
             5  repeatEndA
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        let repeatBrick = RepeatBrick()
        repeatBrick.script = startScript
        startScript!.brickList.add(repeatBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyIfElseEndStructure(to: startScript)

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = repeatBrick
        startScript!.brickList.add(loopEndBrick as Any)
        repeatBrick.loopEndBrick = loopEndBrick
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above repeat brick
        let indexPathFrom = IndexPath(row: 2, section: 0)
        let indexPathTo = IndexPath(row: 1, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination,
                       "Should not be allowed to move IfBrick inside repeat-loop above RepeatBrick")
    }

    func testMoveWaitBrickToAllPossibleDestinations() {

        /*  Test:
             
             0 startedScript
             1  repeatBeginA
             2      waitA
             3  repeatEndA
             4  repeatBeginB
             5      waitB
             6  repeatEndB
             7  repeatBeginC
             8      waitC
             9  repeatEndC
            10  repeatBeginD
            11      waitD               --->
            12  repeatEndD
            13  repeatBeginE
            14      waitE
            15  repeatEndE
            16  repeatBeginF
            17      waitF
            18  repeatEndF
            19  repeatBeginG
            20      waitG
            21  repeatEndG
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1
        let sourceIDX: Int = 11

        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for destinationIDX in 1...21 {
            let indexPathTo = IndexPath(row: destinationIDX, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertTrue(canMoveToDestination,
                          String(format: "Should be allowed to move to line %lu.", UInt(destinationIDX)))
        }
    }

    func testMoveRepeatEndToAllPossibleDestinations() {

        /*  Test:
             
             0 startedScript
             1  repeatBeginA
             2      waitA
             3  repeatEndA
             4  repeatBeginB
             5      waitB
             6  repeatEndB
             7  repeatBeginC
             8      waitC
             9  repeatEndC
            10  repeatBeginD
            11      waitD
            12  repeatEndD
            13  repeatBeginE
            14      waitE                  (valid)
            15  repeatEndE         --->
            16  repeatBeginF
            17      waitF
            18  repeatEndF
            19  repeatBeginG
            20      waitG
            21  repeatEndG
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1
        let sourceIDX: Int = 15
        let validTarget1: Int = 14
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 16, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 13, section: 0)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for destinationIDX in 1..<addedBricks {
            if (destinationIDX != validTarget1) && destinationIDX != sourceIDX {
                let indexPathTo = IndexPath(row: destinationIDX, section: 0)
                BrickMoveManager.sharedInstance().reset()
                let canMoveToDestination = BrickMoveManager.sharedInstance()
                    .collectionView(viewController!.collectionView,
                                    itemAt: indexPathFrom,
                                    canMoveTo: indexPathTo,
                                    andObject: spriteObject)
                XCTAssertFalse(canMoveToDestination,
                               String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
            }
        }

        do {
            let indexPathTo = IndexPath(row: validTarget1, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertTrue(canMoveToDestination,
                          String(format: "Should be allowed to move to line %lu.", UInt(validTarget1)))
        }
    }

    func testMoveRepeatBeginToAllPossibleDestinations() {

        /*  Test:
             
             0 startedScript
             1  repeatBeginA
             2      waitA
             3  repeatEndA
             4  repeatBeginB
             5      waitB
             6  repeatEndB
             7  repeatBeginC        --->
             8      waitC                   (valid)
             9  repeatEndC
             10  repeatBeginD
             11      waitD
             12  repeatEndD
             13  repeatBeginE
             14      waitE
             15  repeatEndE
             16  repeatBeginF
             17      waitF
             18  repeatEndF
             19  repeatBeginG
             20      waitG
             21  repeatEndG
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1
        let sourceIDX: Int = 7
        let validTarget3: Int = 8
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 9, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 6, section: 0)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for destinationIDX in 1...21 {
            if (destinationIDX != validTarget3) && destinationIDX != sourceIDX {
                let indexPathTo = IndexPath(row: destinationIDX, section: 0)
                let canMoveToDestination = BrickMoveManager.sharedInstance()
                    .collectionView(viewController!.collectionView,
                                    itemAt: indexPathFrom,
                                    canMoveTo: indexPathTo,
                                    andObject: spriteObject)
                XCTAssertFalse(canMoveToDestination,
                               String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
            }
        }

        do {
            let indexPathTo = IndexPath(row: validTarget3, section: 0)
            BrickMoveManager.sharedInstance().reset()
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertTrue(canMoveToDestination,
                          String(format: "Should be allowed to move to line %lu.", UInt(validTarget3)))
        }

    }

    func testMoveRepeatBeginToAllPossibleDestinationsNested() {

        /*  Test:
             
             0 startedScript
             1  repeatBeginA
             2      waitA
             3  repeatEndA
             4  repeatBeginB
             5      ifBeginA
             6          foreverBeginA
             7              waitA
             8          foreverEndA
             9      elseA
            10          repeatBeginC        --->
            11              waitB                   (valid)
            12          repeatEndC
            13      ifEndA
            14  repeatEndC
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1
        let validTarget1: Int = 11
        let sourceIDX: Int = 10
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 12, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 9, section: 0)
        // 1, 2, 3
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)

        // 4
        let repeatBrickA = RepeatBrick()
        repeatBrickA.script = startScript
        startScript!.brickList.add(repeatBrickA as Any)
        addedBricks += 1

        // 5
        let ifLogicBeginBrickA = IfLogicBeginBrick()
        ifLogicBeginBrickA.script = startScript
        startScript!.brickList.add(ifLogicBeginBrickA as Any)
        addedBricks += 1

        // 6, 7, 8
        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        // 9
        let ifLogicElseBrickA = IfLogicElseBrick()
        ifLogicElseBrickA.script = startScript
        ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA
        startScript!.brickList.add(ifLogicElseBrickA as Any)
        ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA
        addedBricks += 1

        // 10, 11, 12
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)

        // 13
        let ifLogicEndBrickA = IfLogicEndBrick()
        ifLogicEndBrickA.script = startScript
        ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA
        ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA
        startScript!.brickList.add(ifLogicEndBrickA as Any)
        ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA
        ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA
        addedBricks += 1

        // 14
        let loopEndBrickA = LoopEndBrick()
        loopEndBrickA.script = startScript
        loopEndBrickA.loopBeginBrick = repeatBrickA
        startScript!.brickList.add(loopEndBrickA as Any)
        repeatBrickA.loopEndBrick = loopEndBrickA
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for destinationIDX in 1..<addedBricks {
            if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                let indexPathTo = IndexPath(row: destinationIDX, section: 0)
                BrickMoveManager.sharedInstance().reset()
                let canMoveToDestination = BrickMoveManager.sharedInstance()
                    .collectionView(viewController!.collectionView,
                                    itemAt: indexPathFrom,
                                    canMoveTo: indexPathTo,
                                    andObject: spriteObject)
                XCTAssertFalse(canMoveToDestination,
                               String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
            }
        }

        let indexPathTo = IndexPath(row: validTarget1, section: 0)
        BrickMoveManager.sharedInstance().reset()
        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination,
                      String(format: "Should be allowed to move to line %lu.", UInt(validTarget1)))
    }

    func testMoveRepeatEndToAllPossibleDestinationsNested() {

        /*  Test:
             
             0 startedScript
             1  repeatBeginA
             2      waitA
             3  repeatEndA
             4  repeatBeginB
             5      ifBeginA
             6          foreverBeginA
             7              waitA
             8          foreverEndA
             9      elseA
             10          repeatBeginC
             11              waitB                   (valid)
             12          repeatEndC         --->
             13      ifEndA
             14  repeatEndC
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1
        let validTarget1: Int = 11
        let sourceIDX: Int = 12
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 13, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 10, section: 0)
        // 1, 2, 3
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)

        // 4
        let repeatBrickA = RepeatBrick()
        repeatBrickA.script = startScript
        startScript!.brickList.add(repeatBrickA as Any)
        addedBricks += 1

        // 5
        let ifLogicBeginBrickA = IfLogicBeginBrick()
        ifLogicBeginBrickA.script = startScript
        startScript!.brickList.add(ifLogicBeginBrickA as Any)
        addedBricks += 1

        // 6, 7, 8
        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        // 9
        let ifLogicElseBrickA = IfLogicElseBrick()
        ifLogicElseBrickA.script = startScript
        ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA
        startScript!.brickList.add(ifLogicElseBrickA as Any)
        ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA
        addedBricks += 1

        // 10, 11, 12
        addedBricks += addRepeatLoopWithWaitBrick(to: startScript)

        // 13
        let ifLogicEndBrickA = IfLogicEndBrick()
        ifLogicEndBrickA.script = startScript
        ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA
        ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA
        startScript!.brickList.add(ifLogicEndBrickA as Any)
        ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA
        ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA
        addedBricks += 1

        // 14
        let loopEndBrickA = LoopEndBrick()
        loopEndBrickA.script = startScript
        loopEndBrickA.loopBeginBrick = repeatBrickA
        startScript!.brickList.add(loopEndBrickA as Any)
        repeatBrickA.loopEndBrick = loopEndBrickA
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for destinationIDX in 1..<addedBricks {
            if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                let indexPathTo = IndexPath(row: destinationIDX, section: 0)
                BrickMoveManager.sharedInstance().reset()
                let canMoveToDestination = BrickMoveManager.sharedInstance()
                    .collectionView(viewController!.collectionView,
                                    itemAt: indexPathFrom,
                                    canMoveTo: indexPathTo,
                                    andObject: spriteObject)
                XCTAssertFalse(canMoveToDestination,
                               String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
            }
        }

        let indexPathTo = IndexPath(row: validTarget1, section: 0)
        BrickMoveManager.sharedInstance().reset()
        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination,
                      String(format: "Should be allowed to move to line %lu.", UInt(validTarget1)))
    }

    func testMoveRepeatEndToAllPossibleDestinationsNestedHigherOrder() {

        /*  Test:
             
             0 startedScript                    (1)             (2)             (3)             (4)
             1  ifBeginA
             2      reapeatBeginA
             3          repeatBeginB
             4              repeatBeginC
             5                  waitA
             6              repeatEndC
             7          repeatEndB
             8      repeatEndA
             9  elseA
            10      reapeatBeginA
            11          repeatBeginB
            12             repeatBeginC
            13                  waitA                                          (valid)
            14              repeatEndC                                          --->
            15          repeatEndB
            16      repeatEndA
            17  ifEndA
            18  reapeatBeginA
            19      repeatBeginB            (not valid)
            20          repeatBeginC                           (not valid)                       (all valid)
            21              waitA                                                               --->
            22          repeatEndC
            23      repeatEndB                                  --->
            24  repeatEndA                     --->
             */

        viewController!.collectionView.reloadData()
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        var addedBricks: Int = 1

        // 1
        let ifLogicBeginBrickA = IfLogicBeginBrick()
        ifLogicBeginBrickA.script = startScript
        startScript!.brickList.add(ifLogicBeginBrickA as Any)
        addedBricks += 1

        // 2-8
        addedBricks += addNestedRepeatOrder3WithWaitInHighestLevel(to: startScript)

        // 9
        let ifLogicElseBrickA = IfLogicElseBrick()
        ifLogicElseBrickA.script = startScript
        ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA
        startScript!.brickList.add(ifLogicElseBrickA as Any)
        ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA
        addedBricks += 1

        // 10-16
        addedBricks += addNestedRepeatOrder3WithWaitInHighestLevel(to: startScript)

        // 17
        let ifLogicEndBrickA = IfLogicEndBrick()
        ifLogicEndBrickA.script = startScript
        ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA
        ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA
        startScript!.brickList.add(ifLogicEndBrickA as Any)
        ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA
        ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA
        addedBricks += 1

        // 18-24
        addedBricks += addNestedRepeatOrder3WithWaitInHighestLevel(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // (1)
        do {
            // seperated Namespace for Testcases (1)-(4)
            let sourceIDX: Int = 24
            let validTarget1: Int = 19
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 24, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 23, section: 0)
            let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

            for destinationIDX in 1..<addedBricks {
                if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                    let indexPathTo = IndexPath(row: destinationIDX, section: 0)
                    BrickMoveManager.sharedInstance().reset()
                    let canMoveToDestination = BrickMoveManager.sharedInstance()
                        .collectionView(viewController!.collectionView,
                                        itemAt: indexPathFrom,
                                        canMoveTo: indexPathTo,
                                        andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination,
                                   String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
                }
            }

            let indexPathTo = IndexPath(row: validTarget1, section: 0)
            BrickMoveManager.sharedInstance().reset()
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should not be allowed to move to line %lu.", UInt(validTarget1)))
        }

        // (2)
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        do {
            let sourceIDX: Int = 23
            let validTarget1: Int = 20
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 24, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 22, section: 0)
            let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

            for destinationIDX in 1..<addedBricks {
                if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                    let indexPathTo = IndexPath(row: destinationIDX, section: 0)
                    BrickMoveManager.sharedInstance().reset()
                    let canMoveToDestination = BrickMoveManager.sharedInstance()
                        .collectionView(viewController!.collectionView,
                                        itemAt: indexPathFrom,
                                        canMoveTo: indexPathTo,
                                        andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination,
                                   String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
                }
            }

            let indexPathTo = IndexPath(row: validTarget1, section: 0)
            BrickMoveManager.sharedInstance().reset()
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should not be allowed to move to line %lu.", UInt(validTarget1)))
        }

        // (3)
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        do {
            let sourceIDX: Int = 14
            let validTarget1: Int = 13

            let indexPathFrom = IndexPath(row: sourceIDX, section: 0)
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 15, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 12, section: 0)
            for destinationIDX in 1..<addedBricks {
                if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                    let indexPathTo = IndexPath(row: destinationIDX, section: 0)
                    BrickMoveManager.sharedInstance().reset()
                    let canMoveToDestination = BrickMoveManager.sharedInstance()
                        .collectionView(viewController!.collectionView,
                                        itemAt: indexPathFrom,
                                        canMoveTo: indexPathTo,
                                        andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination,
                                   String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
                }
            }

            let indexPathTo = IndexPath(row: validTarget1, section: 0)
            BrickMoveManager.sharedInstance().reset()
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertTrue(canMoveToDestination,
                          String(format: "Should be allowed to move to line %lu.", UInt(validTarget1)))
        }

        // (4)
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        do {
            let sourceIDX: Int = 21

            let indexPathFrom = IndexPath(row: sourceIDX, section: 0)
            for destinationIDX in 1..<addedBricks {
                let indexPathTo = IndexPath(row: destinationIDX, section: 0)
                if destinationIDX != sourceIDX {
                    BrickMoveManager.sharedInstance().reset()
                    let canMoveToDestination = BrickMoveManager.sharedInstance()
                        .collectionView(viewController!.collectionView,
                                        itemAt: indexPathFrom,
                                        canMoveTo: indexPathTo,
                                        andObject: spriteObject)
                    XCTAssertTrue(canMoveToDestination,
                                  String(format: "Should be allowed to move to line %lu.", UInt(destinationIDX)))
                }
            }

        }
    }

    func testMoveRepeatBeginToAllPossibleDestinationsNestedHigherOrder() {

        /*  Test:
             
             0 startedScript                    (1)             (2)             (3)             (4)
             1  ifBeginA
             2      reapeatBeginA              --->
             3          repeatBeginB
             4              repeatBeginC                       --->
             5                  waitA                         (valid)
             6              repeatEndC
             7          repeatEndB             (not valid)
             8      repeatEndA
             9  elseA
             10      reapeatBeginA                                              --->
             11          repeatBeginB
             12             repeatBeginC
             13                  waitA
             14              repeatEndC
             15          repeatEndB                                            (not valid)
             16      repeatEndA
             17  ifEndA
             18  reapeatBeginA
             19      repeatBeginB                                                               --->
             20          repeatBeginC
             21              waitA
             22          repeatEndC                                                            (not valid)
             23      repeatEndB
             24  repeatEndA
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // 1
        let ifLogicBeginBrickA = IfLogicBeginBrick()
        ifLogicBeginBrickA.script = startScript
        startScript!.brickList.add(ifLogicBeginBrickA as Any)
        addedBricks += 1

        // 2-8
        addedBricks += addNestedRepeatOrder3WithWaitInHighestLevel(to: startScript)

        // 9
        let ifLogicElseBrickA = IfLogicElseBrick()
        ifLogicElseBrickA.script = startScript
        ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA
        startScript!.brickList.add(ifLogicElseBrickA as Any)
        ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA
        addedBricks += 1

        // 10-16
        addedBricks += addNestedRepeatOrder3WithWaitInHighestLevel(to: startScript)

        // 17
        let ifLogicEndBrickA = IfLogicEndBrick()
        ifLogicEndBrickA.script = startScript
        ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA
        ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA
        startScript!.brickList.add(ifLogicEndBrickA as Any)
        ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA
        ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA
        addedBricks += 1

        // 18-24
        addedBricks += addNestedRepeatOrder3WithWaitInHighestLevel(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // (1)
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        do {
            // seperated Namespace for Testcases (1)-(4)
            let sourceIDX: Int = 2
            let validTarget1: Int = 7
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 3, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 1, section: 0)
            let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

            for destinationIDX in 1..<addedBricks {
                if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                    let indexPathTo = IndexPath(row: destinationIDX, section: 0)

                    let canMoveToDestination = BrickMoveManager.sharedInstance()
                        .collectionView(viewController!.collectionView,
                                        itemAt: indexPathFrom,
                                        canMoveTo: indexPathTo,
                                        andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination,
                                   String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
                }
            }

            let indexPathTo = IndexPath(row: validTarget1, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should not be allowed to move to line %lu.", UInt(validTarget1)))
        }

        // (2)
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        do {
            let sourceIDX: Int = 4
            let validTarget1: Int = 5
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 6, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 3, section: 0)
            let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

            for destinationIDX in 1..<addedBricks {
                if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                    let indexPathTo = IndexPath(row: destinationIDX, section: 0)

                    let canMoveToDestination = BrickMoveManager.sharedInstance()
                        .collectionView(viewController!.collectionView,
                                        itemAt: indexPathFrom,
                                        canMoveTo: indexPathTo,
                                        andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination,
                                   String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
                }
            }

            let indexPathTo = IndexPath(row: validTarget1, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertTrue(canMoveToDestination,
                          String(format: "Should be allowed to move to line %lu.", UInt(validTarget1)))
        }

        // (3)
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        do {
            let sourceIDX: Int = 10
            let validTarget1: Int = 15
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 11, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 9, section: 0)
            let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

            for destinationIDX in 1..<addedBricks {
                if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                    let indexPathTo = IndexPath(row: destinationIDX, section: 0)

                    let canMoveToDestination = BrickMoveManager.sharedInstance()
                        .collectionView(viewController!.collectionView,
                                        itemAt: indexPathFrom,
                                        canMoveTo: indexPathTo,
                                        andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination,
                                   String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
                }
            }

            let indexPathTo = IndexPath(row: validTarget1, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should be not allowed to move to line %lu.", UInt(validTarget1)))
        }

        // (4)
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        do {
            let sourceIDX: Int = 19
            let validTarget1: Int = 22

            let indexPathFrom = IndexPath(row: sourceIDX, section: 0)
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 20, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 18, section: 0)
            for destinationIDX in 1..<addedBricks {
                if destinationIDX != validTarget1 && destinationIDX != sourceIDX {
                    let indexPathTo = IndexPath(row: destinationIDX, section: 0)

                    let canMoveToDestination = BrickMoveManager.sharedInstance()
                        .collectionView(viewController!.collectionView,
                                        itemAt: indexPathFrom,
                                        canMoveTo: indexPathTo,
                                        andObject: spriteObject)
                    XCTAssertFalse(canMoveToDestination,
                                   String(format: "Should not be allowed to move to line %lu.", UInt(destinationIDX)))
                }
            }

            let indexPathTo = IndexPath(row: validTarget1, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should not be allowed to move to line %lu.", UInt(validTarget1)))
        }
    }

    func testMoveRepeatBricksToOtherEmptyScript() {
        viewController!.collectionView.reloadData()
        spriteObject!.scriptList.add(whenScript as Any)

        var addedBricks: Int = 1
        addedBricks += addEmptyRepeatLoop(to: startScript)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        var indexPathFrom = IndexPath(row: 1, section: 0)
        var indexPathTo = IndexPath(row: 1, section: 1)
        var canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination,
                       "Should not be allowed to move RepeatBeginBrick to another script")

        indexPathFrom = IndexPath(row: 2, section: 0)
        indexPathTo = IndexPath(row: 1, section: 1)
        canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move LoopEndBrick to another script")
    }
}
