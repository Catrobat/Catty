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

@import Foundation;

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

@interface BrickMoveManagerForeverTests : BrickMoveManagerAbstractTest

@end

@implementation BrickMoveManagerForeverTests

- (void)testMoveForeverBeginBelowEndIntoAnotherForeverNested {
    
    /*  Test:
     
     0 startedScript
     1  foreverBeginA    --->
     2  foreverEndA
     3  foreverBeginB    <---
     4  foreverEndB
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                               itemAtIndexPath:indexPathFrom
                                                                            canMoveToIndexPath:indexPathTo
                                                                                     andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move ForeverBrick inside other ForeverBrick");
}

- (void)testMoveForeverEndToCreateInvalidNestedLoops {
    
    /*  Test:
     
     0 startedScript
     1  foreverBeginA
     2  foreverEndA      --->
     3  foreverBeginB    <---
     4  foreverEndB
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                               itemAtIndexPath:indexPathFrom
                                                                            canMoveToIndexPath:indexPathTo
                                                                                     andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move ForeverEnd-Brick inside other ForeverBrick");
}

- (void)testMoveForeverEndToCreateValidNestedLoops {
    
    /*  Test:
     
     0 startedScript
     1  foreverBeginA
     2  foreverEndA      --->
     3  foreverBeginB
     4  foreverEndB      <---
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:4 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                               itemAtIndexPath:indexPathFrom
                                                                            canMoveToIndexPath:indexPathTo
                                                                                     andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move ForeverEnd-Brick below other ForeverEnd-Brick");
}

- (void)testMoveForeverBeginToCreateValidNestedLoops {
    
    /*  Test:
     
     0 startedScript
     1  foreverBeginA    <---
     2  foreverEndA
     3  foreverBeginB    --->
     4  foreverEndB
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:1 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                               itemAtIndexPath:indexPathFrom
                                                                            canMoveToIndexPath:indexPathTo
                                                                                     andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move ForeverBegin-Brick away to leave something below foreverEnd.");
}

- (void)testMoveIfBrickBeginInsideForeverBrickToOutside {
    
    /*  Test:
     
     0 startedScript
     1  foreverBeginA   <---
     2      ifBegin     --->
     3      else
     4      endIf
     5 foreverEndA
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    ForeverBrick *foreverBrick = [[ForeverBrick alloc] init];
    foreverBrick.script = self.startScript;
    [self.startScript.brickList addObject:foreverBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyIfElseEndStructureToScript:self.startScript];
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = self.startScript;
    loopEndBrick.loopBeginBrick = foreverBrick;
    [self.startScript.brickList addObject:loopEndBrick];
    foreverBrick.loopEndBrick = loopEndBrick;
    addedBricks++;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:1 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move IfBrick inside forever-loop above ForeverBrick");
}

- (void)testMoveWaitBrickBelowForeverBrickInsideIfBrick {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    IfLogicElseBrick *ifLogicElseBrick = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick.script = self.startScript;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    [self.startScript.brickList addObject:ifLogicElseBrick];
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    IfLogicEndBrick *ifLogicEndBrick = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick.script = self.startScript;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    [self.startScript.brickList addObject:ifLogicEndBrick];
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    addedBricks++;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // wait brick below forever end brick of if branch
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:4 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                 itemAtIndexPath:indexPathFrom
                                                                              canMoveToIndexPath:indexPathTo
                                                                                       andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move WaitBrick below forever-loop of if-branch");
}

- (void)testMoveWaitBrickBelowForeverBrickInsideElse {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
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
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // wait brick below forever end brick of if branch
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:6 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:7 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                 itemAtIndexPath:indexPathFrom
                                                                              canMoveToIndexPath:indexPathTo
                                                                                       andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move WaitBrick below forever-loop of else-branch");
}

- (void)testMoveWaitBrickBeforeForeverBrickInsideIfBrick {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    IfLogicElseBrick *ifLogicElseBrick = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick.script = self.startScript;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    [self.startScript.brickList addObject:ifLogicElseBrick];
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    IfLogicEndBrick *ifLogicEndBrick = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick.script = self.startScript;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    [self.startScript.brickList addObject:ifLogicEndBrick];
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    addedBricks++;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // wait brick below forever end brick of if branch
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                 itemAtIndexPath:indexPathFrom
                                                                              canMoveToIndexPath:indexPathTo
                                                                                       andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move WaitBrick before forever-loop of if-branch");
}

- (void)testMoveWaitBrickBeforeForeverBrickInsideElse {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
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
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // wait brick below forever end brick of if branch
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:6 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:5 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                 itemAtIndexPath:indexPathFrom
                                                                              canMoveToIndexPath:indexPathTo
                                                                                       andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move WaitBrick before forever-loop of else-branch");
}

- (void)testMoveWaitBrickFromOneForeverLoopInIfBranchToAnotherInElseBranch {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    IfLogicElseBrick *ifLogicElseBrick = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick.script = self.startScript;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    [self.startScript.brickList addObject:ifLogicElseBrick];
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    IfLogicEndBrick *ifLogicEndBrick = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick.script = self.startScript;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    [self.startScript.brickList addObject:ifLogicEndBrick];
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    addedBricks++;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // wait brick below forever end brick of if branch
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:6 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                    itemAtIndexPath:indexPathFrom
                                                                                 canMoveToIndexPath:indexPathTo
                                                                                          andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move WaitBrick from one ForeverLoop to another");
}

- (void)testMoveWaitBrickFromOneForeverLoopInElseBranchToAnotherInIfBranch {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
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
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // wait brick below forever end brick of if branch
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:6 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                               itemAtIndexPath:indexPathFrom
                                                                            canMoveToIndexPath:indexPathTo
                                                                                     andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move WaitBrick from one ForeverLoop to another");
}

- (void)testMoveWaitBrickFromOneForeverLoopInElseBranchToAnotherInIfBranchAllTogetherInForeverLoop {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    ForeverBrick *foreverBrick0 = [[ForeverBrick alloc] init];
    foreverBrick0.script = self.startScript;
    [self.startScript.brickList addObject:foreverBrick0];
    addedBricks++;
    
    // start if
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
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
    
    LoopEndBrick *loopEndBrick0 = [[LoopEndBrick alloc] init];
    loopEndBrick0.script = self.startScript;
    loopEndBrick0.loopBeginBrick = foreverBrick0;
    [self.startScript.brickList addObject:loopEndBrick0];
    foreverBrick0.loopEndBrick = loopEndBrick0;
    addedBricks++;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // wait brick below forever end brick of if branch
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:7 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:4 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                        itemAtIndexPath:indexPathFrom
                                                                                     canMoveToIndexPath:indexPathTo
                                                                                              andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move WaitBrick from one ForeverLoop to another all together in ForeverLoop.");
}

- (void)testMoveForeverEndBrickInNestedIfElseStructureToAllPossibleDestinations {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    NSUInteger sourceIDX = 30;
    NSUInteger validTarget1 = 29;
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:31 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:28 inSection:0]];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    
    for(NSUInteger testedDestination = 1; testedDestination < addedBricks; testedDestination++) {
        if(testedDestination != validTarget1 && testedDestination != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:testedDestination inSection:0];
            [[BrickMoveManager sharedInstance] reset];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)testedDestination);
        }
    }
    
    NSIndexPath* indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
    [[BrickMoveManager sharedInstance] reset];
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                  itemAtIndexPath:indexPathFrom
                                                               canMoveToIndexPath:indexPathTo
                                                                        andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget1);

}

- (void)testMoveForeverBeginBrickInNestedIfElseStructureToAllPossibleDestinations {
    
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
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    NSUInteger sourceIDX = 28;
    NSUInteger validTarget1 = 29;
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:30 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:27 inSection:0]];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    addedBricks += [self addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above forever brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    
    for(NSUInteger testedDestination = 1; testedDestination < addedBricks; testedDestination++) {
        if(testedDestination != validTarget1 && testedDestination != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:testedDestination inSection:0];
            [[BrickMoveManager sharedInstance] reset];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)testedDestination);
        }
    }
    
    
    NSIndexPath* indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
    [[BrickMoveManager sharedInstance] reset];
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                  itemAtIndexPath:indexPathFrom
                                                               canMoveToIndexPath:indexPathTo
                                                                        andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget1);
    
}


@end
