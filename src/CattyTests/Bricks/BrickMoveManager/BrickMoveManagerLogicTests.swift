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

final class BrickMoveManagerLogicTests: BrickMoveManagerAbstractTest {
    func testMoveForeverBrickInsideIfBranch() {

        /*  Test:
             
             0 startedScript
             1  ifBegin
             2  else            <---
             3  ifEnd
             4  foreverBegin    --->
             5  foreverEnd
             */

        viewController!.collectionView.reloadData()
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 5, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 3, section: 0)
        var addedBricks: Int = 1

        addedBricks += addEmptyIfElseEndStructure(to: startScript)
        addedBricks += addEmptyForeverLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 4, section: 0)
        let indexPathTo = IndexPath(row: 2, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ForeverBrick inside if-branch of IfLogicBeginBrick")
    }

    func testMoveForeverBrickInsideElseBranch() {

        /*  Test:
             
             0 startedScript
             1  ifBegin
             2  else
             3  ifEnd            <---
             4  foreverBegin     --->
             5  foreverEnd
             */

        viewController!.collectionView.reloadData()
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 5, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 3, section: 0)
        var addedBricks: Int = 1

        addedBricks += addEmptyIfElseEndStructure(to: startScript)
        addedBricks += addEmptyForeverLoop(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 4, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ForeverBrick inside else-branch of IfLogicBeginBrick")
    }

    func testMoveIfBrickAboveOuterIfBrick() {

        /*  Test:
             
             0 startedScript
             1  ifBeginA            <---
             2      ifBeginB        --->
             3      elseB
             4      ifEndB
             5  elseA
             6  ifEndA
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        let ifLogicBeginBrick1 = IfLogicBeginBrick()
        ifLogicBeginBrick1.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick1 as Any)
        addedBricks += 1

        addedBricks += addEmptyIfElseEndStructure(to: startScript)

        let ifLogicElseBrick1 = IfLogicElseBrick()
        ifLogicElseBrick1.script = startScript
        ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1
        startScript!.brickList.add(ifLogicElseBrick1 as Any)
        ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1
        addedBricks += 1

        let ifLogicEndBrick1 = IfLogicEndBrick()
        ifLogicEndBrick1.script = startScript
        ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1
        ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1
        startScript!.brickList.add(ifLogicEndBrick1 as Any)
        ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1
        ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 2, section: 0)
        let indexPathTo = IndexPath(row: 1, section: 0)
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 3, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 1, section: 0)
        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move nested IfLogicBeginBrick above main IfLogicBeginBrick")
    }

    func testMoveIfLogicBeginBricksInsideElseBranch() {

        /*  Test:
             
             0 startedScript        (1)         (2)
             1  ifBeginA
             2  elseA              <---        --->
             3      ifBeginB       --->        <---
             4      elseB
             5      ifEndB
             6  ifEndA
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        let ifLogicBeginBrick1 = IfLogicBeginBrick()
        ifLogicBeginBrick1.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick1 as Any)
        addedBricks += 1

        let ifLogicElseBrick1 = IfLogicElseBrick()
        ifLogicElseBrick1.script = startScript
        ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1
        startScript!.brickList.add(ifLogicElseBrick1 as Any)
        ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1
        addedBricks += 1

        addedBricks += addEmptyIfElseEndStructure(to: startScript)

        let ifLogicEndBrick1 = IfLogicEndBrick()
        ifLogicEndBrick1.script = startScript
        ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1
        ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1
        startScript!.brickList.add(ifLogicEndBrick1 as Any)
        ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1
        ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1
        addedBricks += 1

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        do {
            let indexPathFrom = IndexPath(row: 3, section: 0)
            let indexPathTo = IndexPath(row: 2, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination, "Should not be allowed to move nested IfLogicBeginBrick above main IfLogicElseBrick")
        }

        do {
            BrickMoveManager.sharedInstance().getReadyForNewBrickMovement()
            // main else brick
            let indexPathFrom = IndexPath(row: 2, section: 0)
            let indexPathTo = IndexPath(row: 3, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination, "Should not be allowed to move main IfLogicElseBrick below nested IfLogicElseBrick")
        }
    }

    func testMoveIfBeginBrickInvalidBeforeIfEndBrickOfOtherIfBrick() {

        /*  Test:
             
             0 startedScript        (1)         (2)
             1  ifBeginA
             2  elseA
             3  endA               <---         --->
             4  ifBeginB           --->         <---
             5  elseB
             6  ifEndB
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addEmptyIfElseEndStructure(to: startScript)
        addedBricks += addEmptyIfElseEndStructure(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        do {
            // second if brick (move up)
            let indexPathFrom = IndexPath(row: 4, section: 0)
            let indexPathTo = IndexPath(row: 3, section: 0)
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 5, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 3, section: 0)
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination, "Should not be allowed to move IfLogicBeginBrick above IfLogicEndBrick")
        }

        do {
            // first end brick (move down)
            let indexPathFrom = IndexPath(row: 3, section: 0)
            let indexPathTo = IndexPath(row: 4, section: 0)
            BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 4, section: 0)
            BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 2, section: 0)
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)
            XCTAssertFalse(canMoveToDestination, "Should not be allowed to move IfLogicEndBrick below IfLogicBeginBrick")
        }
    }

    func testMoveWaitBrickInsideForeverBrickOfIfLogicBeginBrick() {

        /*  Test:
             
             0 startedScript
             1  ifBeginA
             2      foreverBeginA
             3      foreverEndA     <---
             4  elseA
             5      foreverBeginB
             6      wait            --->
             7      foreverEndB
             8  ifEndA
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        // start else
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
        // end if

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: 6, section: 0)
        let indexPathTo = IndexPath(row: 3, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, "Should be allowed to move WaitBrick inside ForeverBrick of if-branch")
    }

    func testMoveWaitBrickAfterForeverLoopOfIfLogicBeginBrick() {

        /*  Test:
             
             0 startedScript
             1  ifBeginA
             2      foreverBeginA
             3      foreverEndA
             4  elseA               <---
             5      foreverBeginB
             6      wait            --->
             7      foreverBeginB
             8  ifEndA
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        // start if
        let ifLogicBeginBrick = IfLogicBeginBrick()
        ifLogicBeginBrick.script = startScript
        startScript!.brickList.add(ifLogicBeginBrick as Any)
        addedBricks += 1

        addedBricks += addEmptyForeverLoop(to: startScript)

        // start else
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
        // end if

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: 6, section: 0)
        let indexPathTo = IndexPath(row: 4, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move WaitBrick after LoopEndBrick of ForeverBrick of if-branch")
    }

    func testMoveWaitBrickFromNestedIfStructureWithForeverLoopsToAnother() {

        /*  Test:
             
             0 startedScript
             1  ifBeginA
             2      ifBeginB
             3          foreverBeginA
             4              waitA           <---
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
            18              waitD           --->
            19          foreverEndD
            20      ifEndC
            21  endIfA
            
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: 18, section: 0)
        let indexPathTo = IndexPath(row: 4, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, "Should be allowed to move WaitBrick from one if-else structure to another")
    }

    func testMoveWaitBrickFromNestedIfStructureWithForeverLoopsToAnotherIndependentIfStructure() {

        /*  Test:
             
             0 startedScript
             1  ifBeginA
             2      ifBeginB
             3          foreverBeginA
             4              waitA          <---
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
             30          foreverEndH
             31      ifEndE
             32  elseD
             33      ifBeginF
             34          foreverBeginI
             35              waitI
             36          foreverEndI
             37      elseF
             38          foreverBeginJ
             39              waitJ          --->
             40          foreverEndJ
             41      ifEndF
             42  endIfD
             
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: 39, section: 0)
        let indexPathTo = IndexPath(row: 4, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination,
                      "Should be allowed to move WaitBrick from one if-else structure to another")
    }

    func testMoveIfBeginInNestedIfElseStructWithForeverLoopsToInvalidDestination() {
        //DUPLICATE: Only one case of failing from test below!!!
        /*  Test:
             
             0 startedScript
             1  ifBeginA
             2      ifBeginB
             3          foreverBeginA
             4              waitA
             5          foreverEndA        <---
             6      elseB
             7          foreverBeginB
             8              waitB
             9          foreverEndB
             10      ifEndB
             11  elseA
             12      ifBeginC               --->
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

        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 12, section: 0)
        let indexPathTo = IndexPath(row: 5, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move IfBegin to here!")
    }

    func testMoveIfBrickInNestedIfElseStructureWithForeverLoopsToAllPossiblePlaces() {

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
             12      ifBeginC                   --->
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
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 13, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 11, section: 0)

        let sourceIDX: Int = 12
        var addedBricks: Int = 1

        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1...42 where testedDestination != sourceIDX {
            let indexPathTo = IndexPath(row: testedDestination, section: 0)
            BrickMoveManager.sharedInstance().reset()
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)

            XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(testedDestination)))
        }
    }

    func testMoveElseBrickInNestedIfElseStructureWithForeverLoopsToAllPossiblePlaces() {

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
             27      elseE                      --->
             28          foreverBeginH          
             29              waitH              
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

        let sourceIDX: Int = 27
        var addedBricks: Int = 1
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 28, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 26, section: 0)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1...42 where testedDestination != sourceIDX {
            let indexPathTo = IndexPath(row: testedDestination, section: 0)
            BrickMoveManager.sharedInstance().reset()
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)

            XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(testedDestination)))
        }
    }

    func testMoveIfBrickInNestedIfElseStructureWithRepeatLoopsToAllPossiblePlaces() {

        /*  Test:
             
             0 startedScript               Tested configurations:
             1  ifBeginA                        
             2      ifBeginB                    
             3          repeatBeginA            
             4              waitA               
             5          repeatEndA              
             6      elseB                       
             7          repeatBeginB            
             8              waitB               
             9          repeatEndB              
             10      ifEndB                     
             11  elseA                          
             12      ifBeginC                   --->
             13          repeatBeginC           
             14              waitC              
             15          repeatEndC                 (not valid)
             16      elseC                      
             17          repeatBeginD           
             18              waitD              
             19          repeatEndD             
             20      ifEndC                     
             21  endIfA                         
             22  ifBeginD                       
             23      ifBeginE                   
             24         repeatBeginG            
             25              waitG              
             26          repeatEndG             
             27      elseE                      
             28          repeatBeginH           
             29              waitH              
             30          repeatEndH             
             31      ifEndE                     
             32  elseD                          
             33      ifBeginF                   
             34          repeatBeginI           
             35              waitI              
             36          repeatEndI             
             37      elseF                      
             38          repeatBeginJ           
             39              waitJ              
             40          repeatEndJ             
             41      ifEndF                     
             42  endIfD                         
             
             */

        viewController!.collectionView.reloadData()
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 13, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 11, section: 0)
        let sourceIDX: Int = 12
        let validIDX: Int = 15
        var addedBricks: Int = 1

        addedBricks += addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1...42 {
            if testedDestination != validIDX && testedDestination != sourceIDX {
                let indexPathTo = IndexPath(row: testedDestination, section: 0)
                BrickMoveManager.sharedInstance().reset()
                let canMoveToDestination = BrickMoveManager.sharedInstance()
                    .collectionView(viewController!.collectionView,
                                    itemAt: indexPathFrom,
                                    canMoveTo: indexPathTo,
                                    andObject: spriteObject)

                XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(testedDestination)))
            }
        }

        let indexPathTo = IndexPath(row: validIDX, section: 0)
        BrickMoveManager.sharedInstance().reset()
        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)

        XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(validIDX)))
    }

    func testMoveElseBrickInNestedIfElseStructureWithRepeatLoopsToAllPossiblePlaces() {

        /*  Test:
             
             0 startedScript               Tested configurations:
             1  ifBeginA                        
             2      ifBeginB                    
             3          repeatBeginA            
             4              waitA               
             5          repeatEndA              
             6      elseB                       
             7          repeatBeginB            
             8              waitB               
             9          repeatEndB              
             10      ifEndB                     
             11  elseA                          
             12      ifBeginC                   
             13          repeatBeginC           
             14              waitC              
             15          repeatEndC             
             16      elseC                      
             17          repeatBeginD           
             18              waitD              
             19          repeatEndD             
             20      ifEndC                     
             21  endIfA                         
             22  ifBeginD                       
             23      ifBeginE                   
             24         repeatBeginG                ( not valid)
             25              waitG              
             26          repeatEndG             
             27      elseE                      --->
             28          repeatBeginH           
             29              waitH              
             30          repeatEndH                 ( not valid)
             31      ifEndE                     
             32  elseD                          
             33      ifBeginF                   
             34          repeatBeginI           
             35              waitI              
             36          repeatEndI             
             37      elseF                      
             38          repeatBeginJ           
             39              waitJ              
             40          repeatEndJ             
             41      ifEndF                     
             42  endIfD                         
             
             */

        viewController!.collectionView.reloadData()

        let sourceIDX: Int = 27
        let validIDX1: Int = 24
        let validIDX2: Int = 30
        var addedBricks: Int = 1
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 28, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 26, section: 0)
        addedBricks += addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1...42 {
            if (testedDestination != validIDX1) && (testedDestination != validIDX2) && testedDestination != sourceIDX {
                let indexPathTo = IndexPath(row: testedDestination, section: 0)

                let canMoveToDestination = BrickMoveManager.sharedInstance()
                    .collectionView(viewController!.collectionView,
                                    itemAt: indexPathFrom,
                                    canMoveTo: indexPathTo,
                                    andObject: spriteObject)

                XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(testedDestination)))
            }
        }

        do {
            let indexPathTo = IndexPath(row: validIDX1, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)

            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should not be allowed to move to line %lu", UInt(validIDX1)))
        }

        do {
            let indexPathTo = IndexPath(row: validIDX2, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)

            XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(validIDX2)))
        }

    }

    func testMoveWaitBrickFromNestedIfThenStructureWithForeverLoopsToAnother() {

        /*  Test:
             
             0 startedScript
             1  ifBeginA
             2      ifBeginB
             3          foreverBeginA
             4              waitA           <---
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
             18              waitD           --->
             19          foreverEndD
             20      ifEndC
             21  endIfA
             
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: 18, section: 0)
        let indexPathTo = IndexPath(row: 4, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination, "Should be allowed to move WaitBrick from one if-else structure to another")
    }

    func testMoveWaitBrickFromNestedIfThenStructureWithForeverLoopsToAnotherIndependentIfThenStructure() {

        /*  Test:
             
             0 startedScript
             1  ifBeginA
             2      ifBeginB
             3          foreverBeginA
             4              waitA          <---
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
             30          foreverEndH
             31      ifEndE
             32  elseD
             33      ifBeginF
             34          foreverBeginI
             35              waitI
             36          foreverEndI
             37      elseF
             38          foreverBeginJ
             39              waitJ          --->
             40          foreverEndJ
             41      ifEndF
             42  endIfD
             
             */

        viewController!.collectionView.reloadData()

        var addedBricks: Int = 1

        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: 39, section: 0)
        let indexPathTo = IndexPath(row: 4, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertTrue(canMoveToDestination,
                      "Should be allowed to move WaitBrick from one if-else structure to another")
    }

    func testMoveIfBeginInNestedIfThenStructWithForeverLoopsToInvalidDestination() {
        //DUPLICATE: Only one case of failing from test below!!!
        /*  Test:
             
             0 startedScript
             1  ifBeginA
             2      ifBeginB
             3          foreverBeginA
             4              waitA
             5          foreverEndA        <---
             6      elseB
             7          foreverBeginB
             8              waitB
             9          foreverEndB
             10      ifEndB
             11  elseA
             12      ifBeginC               --->
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

        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: 12, section: 0)
        let indexPathTo = IndexPath(row: 5, section: 0)

        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination,
                       "Should not be allowed to move IfBegin to here!")
    }

    func testMoveIfBrickInNestedIfThenStructureWithForeverLoopsToAllPossiblePlaces() {

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
             12      ifBeginC                   --->
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
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 13, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 11, section: 0)

        let sourceIDX: Int = 12
        var addedBricks: Int = 1

        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1...42 where testedDestination != sourceIDX {
            let indexPathTo = IndexPath(row: testedDestination, section: 0)
            BrickMoveManager.sharedInstance().reset()
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)

            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should not be allowed to move to line %lu", UInt(testedDestination)))
        }
    }

    func testMoveElseBrickInNestedIfThenStructureWithForeverLoopsToAllPossiblePlaces() {

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
             27      elseE                      --->
             28          foreverBeginH
             29              waitH
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

        let sourceIDX: Int = 27
        var addedBricks: Int = 1
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 28, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 26, section: 0)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1...42 where testedDestination != sourceIDX {
            let indexPathTo = IndexPath(row: testedDestination, section: 0)
            BrickMoveManager.sharedInstance().reset()
            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)

            XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(testedDestination)))
        }
    }

    func testMoveIfBrickInNestedIfThenStructureWithRepeatLoopsToAllPossiblePlaces() {

        /*  Test:
             
             0 startedScript               Tested configurations:
             1  ifBeginA
             2      ifBeginB
             3          repeatBeginA
             4              waitA
             5          repeatEndA
             6      elseB
             7          repeatBeginB
             8              waitB
             9          repeatEndB
             10      ifEndB
             11  elseA
             12      ifBeginC                   --->
             13          repeatBeginC
             14              waitC
             15          repeatEndC                 (not valid)
             16      elseC
             17          repeatBeginD
             18              waitD
             19          repeatEndD
             20      ifEndC
             21  endIfA
             22  ifBeginD
             23      ifBeginE
             24         repeatBeginG
             25              waitG
             26          repeatEndG
             27      elseE
             28          repeatBeginH
             29              waitH
             30          repeatEndH
             31      ifEndE
             32  elseD
             33      ifBeginF
             34          repeatBeginI
             35              waitI
             36          repeatEndI
             37      elseF
             38          repeatBeginJ
             39              waitJ
             40          repeatEndJ
             41      ifEndF
             42  endIfD
             
             */

        viewController!.collectionView.reloadData()
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 13, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 11, section: 0)
        let sourceIDX: Int = 12
        let validIDX: Int = 15
        var addedBricks: Int = 1

        addedBricks += addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1...42 {
            if testedDestination != validIDX && testedDestination != sourceIDX {
                let indexPathTo = IndexPath(row: testedDestination, section: 0)
                BrickMoveManager.sharedInstance().reset()
                let canMoveToDestination = BrickMoveManager.sharedInstance()
                    .collectionView(viewController!.collectionView,
                                    itemAt: indexPathFrom,
                                    canMoveTo: indexPathTo,
                                    andObject: spriteObject)

                XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(testedDestination)))
            }
        }

        let indexPathTo = IndexPath(row: validIDX, section: 0)
        BrickMoveManager.sharedInstance().reset()
        let canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)

        XCTAssertFalse(canMoveToDestination, String(format: "Should not be allowed to move to line %lu", UInt(validIDX)))
    }

    func testMoveElseBrickInNestedIfThenStructureWithRepeatLoopsToAllPossiblePlaces() {

        /*  Test:
             
             0 startedScript               Tested configurations:
             1  ifBeginA
             2      ifBeginB
             3          repeatBeginA
             4              waitA
             5          repeatEndA
             6      elseB
             7          repeatBeginB
             8              waitB
             9          repeatEndB
             10      ifEndB
             11  elseA
             12      ifBeginC
             13          repeatBeginC
             14              waitC
             15          repeatEndC
             16      elseC
             17          repeatBeginD
             18              waitD
             19          repeatEndD
             20      ifEndC
             21  endIfA
             22  ifBeginD
             23      ifBeginE
             24         repeatBeginG                ( not valid)
             25              waitG
             26          repeatEndG
             27      elseE                      --->
             28          repeatBeginH
             29              waitH
             30          repeatEndH                 ( not valid)
             31      ifEndE
             32  elseD
             33      ifBeginF
             34          repeatBeginI
             35              waitI
             36          repeatEndI
             37      elseF
             38          repeatBeginJ
             39              waitJ
             40          repeatEndJ
             41      ifEndF
             42  endIfD
             
             */

        viewController!.collectionView.reloadData()

        let sourceIDX: Int = 27
        let validIDX1: Int = 24
        let validIDX2: Int = 30
        var addedBricks: Int = 1
        BrickMoveManager.sharedInstance()?.lowerBorder = IndexPath(row: 28, section: 0)
        BrickMoveManager.sharedInstance()?.upperBorder = IndexPath(row: 26, section: 0)
        addedBricks += addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to: startScript)
        addedBricks += addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks(to: startScript)

        XCTAssertEqual(1, viewController!.collectionView.numberOfSections)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        // if brick above forever brick
        let indexPathFrom = IndexPath(row: sourceIDX, section: 0)

        for testedDestination in 1...42 {
            if (testedDestination != validIDX1) && (testedDestination != validIDX2) && testedDestination != sourceIDX {
                let indexPathTo = IndexPath(row: testedDestination, section: 0)

                let canMoveToDestination = BrickMoveManager.sharedInstance()
                    .collectionView(viewController!.collectionView,
                                    itemAt: indexPathFrom,
                                    canMoveTo: indexPathTo,
                                    andObject: spriteObject)

                XCTAssertFalse(canMoveToDestination,
                               String(format: "Should not be allowed to move to line %lu", UInt(testedDestination)))
            }
        }

        do {
            let indexPathTo = IndexPath(row: validIDX1, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)

            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should not be allowed to move to line %lu", UInt(validIDX1)))
        }

        do {
            let indexPathTo = IndexPath(row: validIDX2, section: 0)

            let canMoveToDestination = BrickMoveManager.sharedInstance()
                .collectionView(viewController!.collectionView,
                                itemAt: indexPathFrom,
                                canMoveTo: indexPathTo,
                                andObject: spriteObject)

            XCTAssertFalse(canMoveToDestination,
                           String(format: "Should not be allowed to move to line %lu", UInt(validIDX2)))
        }

    }

    func testMoveIfBricksToOtherEmptyScript() {
        viewController!.collectionView.reloadData()
        spriteObject!.scriptList.add(whenScript as Any)

        var addedBricks: Int = 1
        addedBricks += addEmptyIfElseEndStructure(to: startScript)
        XCTAssertEqual(addedBricks, viewController!.collectionView.numberOfItems(inSection: 0))

        var indexPathFrom = IndexPath(row: 1, section: 0)
        var indexPathTo = IndexPath(row: 1, section: 1)
        var canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move IfBeginBrick to another script")

        indexPathFrom = IndexPath(row: 2, section: 0)
        indexPathTo = IndexPath(row: 1, section: 1)
        canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ThenBrick to another script")

        indexPathFrom = IndexPath(row: 3, section: 0)
        indexPathTo = IndexPath(row: 1, section: 1)
        canMoveToDestination = BrickMoveManager.sharedInstance()
            .collectionView(viewController!.collectionView,
                            itemAt: indexPathFrom,
                            canMoveTo: indexPathTo,
                            andObject: spriteObject)
        XCTAssertFalse(canMoveToDestination, "Should not be allowed to move ElseBrick to another script")
    }
}
