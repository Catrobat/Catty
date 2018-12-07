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

final class BrickMoveManagerForeverTests: BrickMoveManagerAbstractTest {
    func testMoveForeverBeginBelowEndIntoAnotherForeverNested() {

        /*  Test:
             
             0 startedScript
             1  foreverBeginA    --->
             2  foreverEndA
             3  foreverBeginB    <---
             4  foreverEndB
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addEmptyForeverLoop(to: startScript)
        addedBricks += addEmptyForeverLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 1, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ForeverBrick inside other ForeverBrick")
    }

    func testMoveForeverEndToCreateInvalidNestedLoops() {

        /*  Test:
             
             0 startedScript
             1  foreverBeginA
             2  foreverEndA      --->
             3  foreverBeginB    <---
             4  foreverEndB
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addEmptyForeverLoop(to: startScript)
        addedBricks += addEmptyForeverLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 2, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)
        BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ForeverEnd-Brick inside other ForeverBrick")
    }

    func testMoveForeverEndToCreateValidNestedLoops() {

        /*  Test:
             
             0 startedScript
             1  foreverBeginA
             2  foreverEndA      --->
             3  foreverBeginB
             4  foreverEndB      <---
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addEmptyForeverLoop(to: startScript)
        addedBricks += addEmptyForeverLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 2, section: 0)
        let indexPathTo = IndexPath(row: 4, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ForeverEnd-Brick below other ForeverEnd-Brick")
    }

    func testMoveForeverBeginToCreateValidNestedLoops() {

        /*  Test:
             
             0 startedScript
             1  foreverBeginA    <---
             2  foreverEndA
             3  foreverBeginB    --->
             4  foreverEndB
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addEmptyForeverLoop(to: startScript)
        addedBricks += addEmptyForeverLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 3, section: 0)
        let indexPathTo = IndexPath(row: 1, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ForeverBegin-Brick away to leave something below foreverEnd.")
    }

    func testMoveIfBrickBeginInsideForeverBrickToOutside() {

        /*  Test:
             
             0 startedScript
             1  foreverBeginA   <---
             2      ifBegin     --->
             3      else
             4      endIf
             5 foreverEndA
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        let foreverBrick = ForeverBrick()
        foreverBrick.script = startScript
        startScript!.brickList.add(foreverBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyIfElseEndStructure(to: startScript)

        let loopEndBrick = LoopEndBrick()
        loopEndBrick.script = startScript
        loopEndBrick.loopBeginBrick = foreverBrick
        startScript!.brickList.add(loopEndBrick as Any)
        foreverBrick.loopEndBrick = loopEndBrick
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: 2, section: 0)
        let indexPathTo = IndexPath(row: 1, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move IfBrick inside forever-loop above ForeverBrick")
    }

    func testMoveWaitBrickBelowForeverBrickInsideIfBrick() {

        /*  Test:
             
             0 startScript
             1   ifBegin
             2       foreverBeginA
             3       wait               --->
             4       foreverEndA        <---
             5   else
             6       foreverBeginB
             7       foreverEndB
             8   endIf
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        startScript!.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        startScript!.brickList.add(ifLogicEndBrick as Any)
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // wait brick below forever end brick of if branch
        let indexPathFrom = IndexPath(row: 3, section: 0)
        let indexPathTo = IndexPath(row: 4, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move WaitBrick below forever-loop of if-branch")
    }

    func testMoveWaitBrickBelowForeverBrickInsideElse() {

        /*  Test:
             
             0 startScript
             1   ifBegin
             2       foreverBeginA
             3       foreverEndA
             4   else
             5       foreverBeginB
             6       wait            --->
             7       foreverEndB     <---
             8   endIf
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        startScript!.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        addedBricks += 1

        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        startScript!.brickList.add(ifLogicEndBrick as Any)
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // wait brick below forever end brick of if branch
        let indexPathFrom = IndexPath(row: 6, section: 0)
        let indexPathTo = IndexPath(row: 7, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move WaitBrick below forever-loop of else-branch")
    }

    func testMoveWaitBrickBeforeForeverBrickInsideIfBrick() {

        /*  Test:
             
             0 startScript
             1   ifBegin
             2       foreverBeginA      <---
             3       wait               --->
             4       foreverEndA
             5   else
             6       foreverBeginB
             7       foreverEndB
             8   endIf
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        startScript!.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        startScript!.brickList.add(ifLogicEndBrick as Any)
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // wait brick below forever end brick of if branch
        let indexPathFrom = IndexPath(row: 3, section: 0)
        let indexPathTo = IndexPath(row: 2, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, "Should be allowed to move WaitBrick before forever-loop of if-branch")
    }

    func testMoveWaitBrickBeforeForeverBrickInsideElse() {

        /*  Test:
             
             0 startScript
             1   ifBegin
             2       foreverBeginA
             3       foreverEndA
             4   else
             5       foreverBeginB   <---
             6       wait            --->
             7       foreverEndB
             8   endIf
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        startScript!.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        addedBricks += 1

        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        startScript!.brickList.add(ifLogicEndBrick as Any)
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // wait brick below forever end brick of if branch
        let indexPathFrom = IndexPath(row: 6, section: 0)
        let indexPathTo = IndexPath(row: 5, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, "Should be allowed to move WaitBrick before forever-loop of else-branch")
    }

    func testMoveWaitBrickFromOneForeverLoopInIfBranchToAnotherInElseBranch() {

        /*  Test:
             
             0 startScript
             1   ifBegin
             2       foreverBeginA
             3       wait               --->
             4       foreverEndA
             5   else
             6       foreverBeginB      <---
             7       foreverEndB
             8   endIf
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        startScript!.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        startScript!.brickList.add(ifLogicEndBrick as Any)
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // wait brick below forever end brick of if branch
        let indexPathFrom = IndexPath(row: 3, section: 0)
        let indexPathTo = IndexPath(row: 6, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, "Should be allowed to move WaitBrick from one ForeverLoop to another")
    }

    func testMoveWaitBrickFromOneForeverLoopInElseBranchToAnotherInIfBranch() {

        /*  Test:
             
             0 startScript
             1   ifBegin
             2       foreverBeginA
             3       foreverEndA     <---
             4   else
             5       foreverBeginB
             6       wait            --->
             7       foreverEndB
             8   endIf
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        startScript!.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        addedBricks += 1

        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        startScript!.brickList.add(ifLogicEndBrick as Any)
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // wait brick below forever end brick of if branch
        let indexPathFrom = IndexPath(row: 6, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, "Should be allowed to move WaitBrick from one ForeverLoop to another")
    }

    func testMoveWaitBrickFromOneForeverLoopInElseBranchToAnotherInIfBranchAllTogetherInForeverLoop() {

        /*  Test:
             
             0 startScript
             1   foreverBeginA
             2      ifBegin
             3          foreverBeginB
             4          foreverEndB     <---
             5      else
             6          foreverBeginC
             7          wait            --->
             8          foreverEndV
             9      endIf
            10   foreverEndA
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        let foreverBrick0 = ForeverBrick()
        foreverBrick0.script = startScript
        startScript!.brickList.add(foreverBrick0 as Any)
        addedBricks += 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        let ifLogicElseBrick = IfLogicElseBrick()
        ifLogicElseBrick.script = startScript
        ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick
        startScript!.brickList.add(ifLogicElseBrick as Any)
        ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick
        addedBricks += 1

        addedBricks += addForeverLoopWithWaitBrick(to: startScript)

        let ifLogicEndBrick = IfLogicEndBrick()
        ifLogicEndBrick.script = startScript
        ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick
        ifLogicEndBrick.ifElseBrick = ifLogicElseBrick
        startScript!.brickList.add(ifLogicEndBrick as Any)
        ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick
        ifLogicElseBrick.ifEndBrick = ifLogicEndBrick
        addedBricks += 1

        let loopEndBrick0 = LoopEndBrick()
        loopEndBrick0.script = startScript
        loopEndBrick0.loopBeginBrick = foreverBrick0
        startScript!.brickList.add(loopEndBrick0 as Any)
        foreverBrick0.loopEndBrick = loopEndBrick0
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // wait brick below forever end brick of if branch
        let indexPathFrom = IndexPath(row: 7, section: 0)
        let indexPathTo = IndexPath(row: 4, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, "Should be allowed to move WaitBrick from one ForeverLoop to another all together in ForeverLoop.")
    }

    func testMoveForeverEndBrickInNestedIfElseStructureToAllPossibleDestinations() {

        /*  Test:
             
             0 startedScript               Tested configurations:
             1  ifBeginA                        
             2      ifBeginB                    
             3          foreverBeginA           
             4              waitA               
             5          foreverEndA             
             6      elseB                       
             7          foreverBeginB           
             8              waitB               
             9          foreverEndB             
             10      ifEndB                     
             11  elseA                          
             12      ifBeginC                   
             13          foreverBeginC          
             14              waitC              
             15          foreverEndC            
             16      elseC                      
             17          foreverBeginD          
             18              waitD              
             19          foreverEndD            
             20      ifEndC                     
             21  endIfA                         
             22  ifBeginD                       
             23      ifBeginE                   
             24         foreverBeginG           
             25              waitG              
             26          foreverEndG            
             27      elseE                      
             28          foreverBeginH          
             29              waitH              
             30          foreverEndH            --->
             31      ifEndE                     
             32  elseD                          
             33      ifBeginF                   
             34          foreverBeginI          
             35              waitI              
             36          foreverEndI            
             37      elseF                      
             38          foreverBeginJ          
             39              waitJ              
             40          foreverEndJ            
             41      ifEndF                     
             42  endIfD                         
             
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1
        let sourceIDX: Int = 30
        let validTarget1: Int = 29
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 31, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 28, section: 0)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1..<addedBricks {
            if testedDestination != validTarget1 && testedDestination != sourceIDX {
                let indexPathTo = IndexPath(row: testedDestination, section: 0)
                BrickMoveManager.sharedInstance().reset()
                let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
                XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu.", UInt(testedDestination)))
            }
        }

        let indexPathTo = IndexPath(row: validTarget1, section: 0)
        BrickMoveManager.sharedInstance().reset()
        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu.", UInt(validTarget1)))

    }

    func testMoveForeverBeginBrickInNestedIfElseStructureToAllPossibleDestinations() {

        /*  Test:
             
             0 startedScript               Tested configurations:
             1  ifBeginA
             2      ifBeginB
             3          foreverBeginA
             4              waitA
             5          foreverEndA
             6      elseB
             7          foreverBeginB
             8              waitB
             9          foreverEndB
             10      ifEndB
             11  elseA
             12      ifBeginC
             13          foreverBeginC
             14              waitC
             15          foreverEndC
             16      elseC
             17          foreverBeginD
             18              waitD
             19          foreverEndD
             20      ifEndC
             21  endIfA
             22  ifBeginD
             23      ifBeginE
             24         foreverBeginG
             25              waitG
             26          foreverEndG
             27      elseE
             28          foreverBeginH          --->
             29              waitH             (valid)
             30          foreverEndH
             31      ifEndE
             32  elseD
             33      ifBeginF
             34          foreverBeginI
             35              waitI
             36          foreverEndI
             37      elseF
             38          foreverBeginJ
             39              waitJ
             40          foreverEndJ
             41      ifEndF
             42  endIfD
             
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1
        let sourceIDX: Int = 28
        let validTarget1: Int = 29
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 30, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 27, section: 0)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1..<addedBricks {
            if testedDestination != validTarget1 && testedDestination != sourceIDX {
                let indexPathTo = IndexPath(row: testedDestination, section: 0)
                BrickMoveManager.sharedInstance().reset()
                let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
                XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu.", UInt(testedDestination)))
            }
        }

        let indexPathTo = IndexPath(row: validTarget1, section: 0)
        BrickMoveManager.sharedInstance().reset()
        let canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, String(format: "Should be allowed to move to line %lu.", UInt(validTarget1)))

    }

    func testMoveForeverBricksToOtherEmptyScript() {
        viewController!.collectionView.reloadData()
        spriteObject!.scriptList.add(whenScript as Any)

        var addedBricks: Int = 1
        addedBricks += addEmptyForeverLoop(to: startScript)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        var indexPathFrom = IndexPath(row: 1, section: 0)
        var indexPathTo = IndexPath(row: 1, section: 1)
        var canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ForeverBeginBrick to another script")

        indexPathFrom = IndexPath(row: 2, section: 0)
        indexPathTo = IndexPath(row: 1, section: 1)
        canMoveToDestination = BrickMoveManager.sharedInstance().collectionView(viewController!.collectionView, itemAt: indexPathFrom, canMoveTo: indexPathTo, andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move LoopEndBrick to another script")
    }
}
