/**
 *  Copyright (C) 2010-2015 The Catrobat Team
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

#import "BrickMoveManagerAbstractTest.h"
#import "WaitBrick.h"
#import "SetVariableBrick.h"
#import "ForeverBrick.h"
#import "LoopEndBrick.h"
#import "RepeatBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "WhenScript.h"
#import "BrickMoveManager.h"

@interface BrickMoveManagerLogicTests : BrickMoveManagerAbstractTest

@end

@implementation BrickMoveManagerLogicTests

- (void)testMoveForeverBrickInsideIfBranch {
    
    /*  Test:
     
     0 startedScript
     1  ifBegin
     2  else            <---
     3  ifEnd
     4  foreverBegin    --->
     5  foreverEnd
     */

    [self.viewController.collectionView reloadData];
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:5 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:3 inSection:0]];
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addEmptyIfElseEndStructureToScript:self.startScript];
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:4 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                       itemAtIndexPath:indexPathFrom
                                                                                    canMoveToIndexPath:indexPathTo
                                                                                             andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move ForeverBrick inside if-branch of IfLogicBeginBrick");
}

- (void)testMoveForeverBrickInsideElseBranch {
    
    /*  Test:
     
     0 startedScript
     1  ifBegin
     2  else
     3  ifEnd            <---
     4  foreverBegin     --->
     5  foreverEnd
     */
    
    [self.viewController.collectionView reloadData];
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:5 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:3 inSection:0]];
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addEmptyIfElseEndStructureToScript:self.startScript];
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);

    NSIndexPath* indexPathFrom = [NSIndexPath indexPathForRow:4 inSection:0];
    NSIndexPath* indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                     itemAtIndexPath:indexPathFrom
                                                                  canMoveToIndexPath:indexPathTo
                                                                           andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move ForeverBrick inside else-branch of IfLogicBeginBrick");
}

- (void)testMoveIfBrickAboveOuterIfBrick {

    /*  Test:
     
     0 startedScript
     1  ifBeginA            <---
     2      ifBeginB        --->
     3      elseB
     4      ifEndB
     5  elseA
     6  ifEndA
     */

    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    IfLogicBeginBrick *ifLogicBeginBrick1 = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick1.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick1];
    addedBricks++;
    
    addedBricks += [self addEmptyIfElseEndStructureToScript:self.startScript];
    
    IfLogicElseBrick *ifLogicElseBrick1 = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick1.script = self.startScript;
    ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1;
    [self.startScript.brickList addObject:ifLogicElseBrick1];
    ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1;
    addedBricks++;
    
    IfLogicEndBrick *ifLogicEndBrick1 = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick1.script = self.startScript;
    ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1;
    ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1;
    [self.startScript.brickList addObject:ifLogicEndBrick1];
    ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1;
    ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1;
    addedBricks++;
    
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:1 inSection:0];
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:3 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:1 inSection:0]];
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                  itemAtIndexPath:indexPathFrom
                                                                               canMoveToIndexPath:indexPathTo
                                                                                        andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move nested IfLogicBeginBrick above main IfLogicBeginBrick");
}

- (void)testMoveIfLogicBeginBricksInsideElseBranch {

    /*  Test:
     
     0 startedScript        (1)         (2)
     1  ifBeginA
     2  elseA              <---        --->
     3      ifBeginB       --->        <---
     4      elseB
     5      ifEndB
     6  ifEndA
     */

    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    IfLogicBeginBrick *ifLogicBeginBrick1 = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick1.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick1];
    addedBricks++;
    
    IfLogicElseBrick *ifLogicElseBrick1 = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick1.script = self.startScript;
    ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1;
    [self.startScript.brickList addObject:ifLogicElseBrick1];
    ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1;
    addedBricks++;
    
    addedBricks += [self addEmptyIfElseEndStructureToScript:self.startScript];
    
    IfLogicEndBrick *ifLogicEndBrick1 = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick1.script = self.startScript;
    ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1;
    ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1;
    [self.startScript.brickList addObject:ifLogicEndBrick1];
    ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1;
    ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1;
    addedBricks++;
    
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    {
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:0];
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                     itemAtIndexPath:indexPathFrom
                                                                                  canMoveToIndexPath:indexPathTo
                                                                                           andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move nested IfLogicBeginBrick above main IfLogicElseBrick");
    }
    
    {
        // main else brick
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                     itemAtIndexPath:indexPathFrom
                                                                                  canMoveToIndexPath:indexPathTo
                                                                                           andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move main IfLogicElseBrick below nested IfLogicElseBrick");
    }
}

- (void)testMoveIfBeginBrickInvalidBeforeIfEndBrickOfOtherIfBrick {

    /*  Test:
     
     0 startedScript        (1)         (2)
     1  ifBeginA
     2  elseA
     3  endA               <---         --->
     4  ifBeginB           --->         <---
     5  elseB
     6  ifEndB
     */

    [self.viewController.collectionView reloadData];

    NSUInteger addedBricks = 1;
    
    addedBricks += [self addEmptyIfElseEndStructureToScript:self.startScript];
    addedBricks += [self addEmptyIfElseEndStructureToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    {
        // second if brick (move up)
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:4 inSection:0];
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:5 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:3 inSection:0]];
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                      itemAtIndexPath:indexPathFrom
                                                                                   canMoveToIndexPath:indexPathTo
                                                                                            andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move IfLogicBeginBrick above IfLogicEndBrick");
    }
    
    {
        // first end brick (move down)
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:0];
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:4 inSection:0];
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:4 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:2 inSection:0]];
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                          itemAtIndexPath:indexPathFrom
                                                                                       canMoveToIndexPath:indexPathTo
                                                                                                andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move IfLogicEndBrick below IfLogicBeginBrick");
    }
}

- (void)testMoveWaitBrickInsideForeverBrickOfIfLogicBeginBrick {

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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    // start else
    IfLogicElseBrick *ifLogicElseBrick = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick.script = self.startScript;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    [self.startScript.brickList addObject:ifLogicElseBrick];
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    addedBricks++;
    
    addedBricks += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    IfLogicEndBrick *ifLogicEndBrick = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick.script = self.startScript;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    [self.startScript.brickList addObject:ifLogicEndBrick];
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    addedBricks++;
    // end if
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:6 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move WaitBrick inside ForeverBrick of if-branch");
}

- (void)testMoveWaitBrickAfterForeverLoopOfIfLogicBeginBrick {

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

    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    // start else
    IfLogicElseBrick *ifLogicElseBrick = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick.script = self.startScript;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    [self.startScript.brickList addObject:ifLogicElseBrick];
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    addedBricks++;
    
    addedBricks += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    IfLogicEndBrick *ifLogicEndBrick = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick.script = self.startScript;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    [self.startScript.brickList addObject:ifLogicEndBrick];
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    addedBricks++;
    // end if
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:6 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:4 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                       itemAtIndexPath:indexPathFrom
                                                                    canMoveToIndexPath:indexPathTo
                                                                             andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move WaitBrick after LoopEndBrick of ForeverBrick of if-branch");
}

- (void)testMoveWaitBrickFromNestedIfStructureWithForeverLoopsToAnother {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:18 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:4 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move WaitBrick from one if-else structure to another");
}

- (void)testMoveWaitBrickFromNestedIfStructureWithForeverLoopsToAnotherIndependentIfStructure {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:39 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:4 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move WaitBrick from one if-else structure to another");
}

- (void)testMoveIfBeginInNestedIfElseStructWithForeverLoopsToInvalidDestination {
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:12 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:5 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move IfBegin to here!");
}

- (void)testMoveIfBrickInNestedIfElseStructureWithForeverLoopsToAllPossiblePlaces {
    
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
    
    [self.viewController.collectionView reloadData];
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:13 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:11 inSection:0]];
    
    NSUInteger sourceIDX = 12;
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    
    for(NSUInteger testedDestination = 1; testedDestination <= 42; testedDestination++) {
        if(testedDestination != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:testedDestination inSection:0];
            [[BrickMoveManager sharedInstance] reset];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
            
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu", (unsigned long)testedDestination);
        }
    }
}

- (void)testMoveElseBrickInNestedIfElseStructureWithForeverLoopsToAllPossiblePlaces {
    
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
    
    [self.viewController.collectionView reloadData];
    
    
    NSUInteger sourceIDX = 27;
    NSUInteger addedBricks = 1;
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:28 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:26 inSection:0]];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    
    for(NSUInteger testedDestination = 1; testedDestination <= 42; testedDestination++) {
        if(testedDestination != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:testedDestination inSection:0];
            [[BrickMoveManager sharedInstance] reset];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
        
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu", (unsigned long)testedDestination);
        }
    }
}

- (void)testMoveIfBrickInNestedIfElseStructureWithRepeatLoopsToAllPossiblePlaces {
    
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
    
    [self.viewController.collectionView reloadData];
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:13 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:11 inSection:0]];
    NSUInteger sourceIDX = 12;
    NSUInteger validIDX = 15;
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricksToScript:self.startScript];
    addedBricks += [self addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    
    for(NSUInteger testedDestination = 1; testedDestination <= 42; testedDestination++) {
        if(testedDestination != validIDX && testedDestination != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:testedDestination inSection:0];
            [[BrickMoveManager sharedInstance] reset];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
            
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu", (unsigned long)testedDestination);
        }
    }
    
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validIDX inSection:0];
    [[BrickMoveManager sharedInstance] reset];
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                  itemAtIndexPath:indexPathFrom
                                                               canMoveToIndexPath:indexPathTo
                                                                        andObject:self.spriteObject];
    
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu", (unsigned long)validIDX);
}

- (void)testMoveElseBrickInNestedIfElseStructureWithRepeatLoopsToAllPossiblePlaces {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger sourceIDX = 27;
    NSUInteger validIDX1 = 24;
    NSUInteger validIDX2 = 30;
    NSUInteger addedBricks = 1;
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:28 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:26 inSection:0]];
    addedBricks += [self addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricksToScript:self.startScript];
    addedBricks += [self addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    
    for(NSUInteger testedDestination = 1; testedDestination <= 42; testedDestination++) {
        if( (testedDestination != validIDX1)  && (testedDestination != validIDX2) && testedDestination != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:testedDestination inSection:0];
            
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
            
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu", (unsigned long)testedDestination);
        }
    }
    
    {
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validIDX1 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu", (unsigned long)validIDX1);
    }
    
    {
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validIDX2 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu", (unsigned long)validIDX2);
    }
    
}






@end
