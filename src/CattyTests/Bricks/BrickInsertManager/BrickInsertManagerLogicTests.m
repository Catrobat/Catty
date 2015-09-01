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

#import "BrickInsertManagerAbstractTest.h"
#import "WaitBrick.h"
#import "SetVariableBrick.h"
#import "ForeverBrick.h"
#import "LoopEndBrick.h"
#import "RepeatBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "WhenScript.h"
#import "BrickInsertManager.h"

@interface BrickInsertManagerLogicTests : BrickInsertManagerAbstractTest

@end

@implementation BrickInsertManagerLogicTests

- (void)testInsertForeverBrickInsideIfBrick {
    [self.viewController.collectionView reloadData];
    
    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    
    IfLogicElseBrick *ifLogicElseBrick = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick.script = self.startScript;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    [self.startScript.brickList addObject:ifLogicElseBrick];
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;

    IfLogicEndBrick *ifLogicEndBrick = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick.script = self.startScript;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    [self.startScript.brickList addObject:ifLogicEndBrick];
    
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    
    ForeverBrick *foreverBrick = [[ForeverBrick alloc] init];
    foreverBrick.script = self.startScript;
    [self.startScript.brickList addObject:foreverBrick];
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = self.startScript;
    loopEndBrick.loopBeginBrick = foreverBrick;
    [self.startScript.brickList addObject:loopEndBrick];
    foreverBrick.loopEndBrick = loopEndBrick;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(6, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if-branch
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:4 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
    
    foreverBrick.animateInsertBrick = YES;
    BOOL canMoveInsideIfBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                         itemAtIndexPath:indexPathFrom
                                                                                      canInsertToIndexPath:indexPathTo
                                                                                               andObject:self.spriteObject];
    XCTAssertTrue(canMoveInsideIfBrickInsertMode, @"Should be allowed to move ForeverBrick inside if-branch IfLogicBeginBrick");
    
    // else-branch
    indexPathFrom = [NSIndexPath indexPathForRow:4 inSection:0];
    indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    foreverBrick.animateInsertBrick = YES;
    canMoveInsideIfBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                               itemAtIndexPath:indexPathFrom
                                                                            canInsertToIndexPath:indexPathTo
                                                                                     andObject:self.spriteObject];
    XCTAssertTrue(canMoveInsideIfBrickInsertMode, @"Should be allowed to move ForeverBrick inside else-branch of IfLogicBeginBrick");
}

- (void)testInsertIfBrickAboveIfBrick {
    [self.viewController.collectionView reloadData];
    
    IfLogicBeginBrick *ifLogicBeginBrick1 = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick1.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick1];
    
    // begin nested if
    IfLogicBeginBrick *ifLogicBeginBrick2 = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick2.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick2];
    
    IfLogicElseBrick *ifLogicElseBrick2 = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick2.script = self.startScript;
    ifLogicElseBrick2.ifBeginBrick = ifLogicBeginBrick2;
    [self.startScript.brickList addObject:ifLogicElseBrick2];
    ifLogicBeginBrick2.ifElseBrick = ifLogicElseBrick2;
    
    IfLogicEndBrick *ifLogicEndBrick2 = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick2.script = self.startScript;
    ifLogicEndBrick2.ifBeginBrick = ifLogicBeginBrick2;
    ifLogicEndBrick2.ifElseBrick = ifLogicElseBrick2;
    [self.startScript.brickList addObject:ifLogicEndBrick2];
    
    ifLogicBeginBrick2.ifEndBrick = ifLogicEndBrick2;
    ifLogicElseBrick2.ifEndBrick = ifLogicEndBrick2;
    // end nested if
    
    IfLogicElseBrick *ifLogicElseBrick1 = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick1.script = self.startScript;
    ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1;
    [self.startScript.brickList addObject:ifLogicElseBrick1];
    ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1;
    
    IfLogicEndBrick *ifLogicEndBrick1 = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick1.script = self.startScript;
    ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1;
    ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1;
    [self.startScript.brickList addObject:ifLogicEndBrick1];
    
    ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1;
    ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1;
    
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(7, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // nested if brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:1 inSection:0];
    
    ifLogicBeginBrick2.animateInsertBrick = YES;
    BOOL canInsertAboveIfBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                    itemAtIndexPath:indexPathFrom
                                                                                 canInsertToIndexPath:indexPathTo
                                                                                          andObject:self.spriteObject];
    XCTAssertTrue(canInsertAboveIfBrickInsertMode, @"Should be allowed to insert nested IfLogicBeginBrick above main IfLogicBeginBrick");
}

- (void)testInsertIfLogicBeginBricksInsideElseBranch {
    [self.viewController.collectionView reloadData];
    
    IfLogicBeginBrick *ifLogicBeginBrick1 = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick1.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick1];
    
    IfLogicElseBrick *ifLogicElseBrick1 = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick1.script = self.startScript;
    ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1;
    [self.startScript.brickList addObject:ifLogicElseBrick1];
    ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1;
    
    // begin nested if
    IfLogicBeginBrick *ifLogicBeginBrick2 = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick2.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick2];
    
    IfLogicElseBrick *ifLogicElseBrick2 = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick2.script = self.startScript;
    ifLogicElseBrick2.ifBeginBrick = ifLogicBeginBrick2;
    [self.startScript.brickList addObject:ifLogicElseBrick2];
    ifLogicBeginBrick2.ifElseBrick = ifLogicElseBrick2;
    
    IfLogicEndBrick *ifLogicEndBrick2 = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick2.script = self.startScript;
    ifLogicEndBrick2.ifBeginBrick = ifLogicBeginBrick2;
    ifLogicEndBrick2.ifElseBrick = ifLogicElseBrick2;
    [self.startScript.brickList addObject:ifLogicEndBrick2];
    
    ifLogicBeginBrick2.ifEndBrick = ifLogicEndBrick2;
    ifLogicElseBrick2.ifEndBrick = ifLogicEndBrick2;
    // end nested if
    
    IfLogicEndBrick *ifLogicEndBrick1 = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick1.script = self.startScript;
    ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1;
    ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1;
    [self.startScript.brickList addObject:ifLogicEndBrick1];
    
    ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1;
    ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1;
    
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(7, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // nested if brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
    
    ifLogicBeginBrick2.animateInsertBrick = YES;
    BOOL canInsertAboveIfBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                   itemAtIndexPath:indexPathFrom
                                                                                canInsertToIndexPath:indexPathTo
                                                                                         andObject:self.spriteObject];
    XCTAssertTrue(canInsertAboveIfBrickInsertMode, @"Should be allowed to insert nested IfLogicBeginBrick above main IfLogicElseBrick");
    
    // main else brick
    ifLogicBeginBrick2.animateInsertBrick = NO;
    indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
    indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    ifLogicElseBrick1.animateInsertBrick = YES;
    BOOL canInsertBelowIfBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                   itemAtIndexPath:indexPathFrom
                                                                                canInsertToIndexPath:indexPathTo
                                                                                         andObject:self.spriteObject];
    XCTAssertTrue(canInsertBelowIfBrickInsertMode, @"Should be allowed to insert main IfLogicElseBrick below nested IfLogicElseBrick");
}

- (void)testInsertMoveLogicBricks {
    [self.viewController.collectionView reloadData];
    
    IfLogicBeginBrick *ifLogicBeginBrick1 = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick1.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick1];
    
    IfLogicElseBrick *ifLogicElseBrick1 = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick1.script = self.startScript;
    ifLogicElseBrick1.ifBeginBrick = ifLogicBeginBrick1;
    [self.startScript.brickList addObject:ifLogicElseBrick1];
    ifLogicBeginBrick1.ifElseBrick = ifLogicElseBrick1;
    
    IfLogicEndBrick *ifLogicEndBrick1 = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick1.script = self.startScript;
    ifLogicEndBrick1.ifBeginBrick = ifLogicBeginBrick1;
    ifLogicEndBrick1.ifElseBrick = ifLogicElseBrick1;
    [self.startScript.brickList addObject:ifLogicEndBrick1];
    
    ifLogicBeginBrick1.ifEndBrick = ifLogicEndBrick1;
    ifLogicElseBrick1.ifEndBrick = ifLogicEndBrick1;
    
    IfLogicBeginBrick *ifLogicBeginBrick2 = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick2.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick2];
    
    IfLogicElseBrick *ifLogicElseBrick2 = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick2.script = self.startScript;
    ifLogicElseBrick2.ifBeginBrick = ifLogicBeginBrick2;
    [self.startScript.brickList addObject:ifLogicElseBrick2];
    ifLogicBeginBrick2.ifElseBrick = ifLogicElseBrick2;
    
    IfLogicEndBrick *ifLogicEndBrick2 = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick2.script = self.startScript;
    ifLogicEndBrick2.ifBeginBrick = ifLogicBeginBrick2;
    ifLogicEndBrick2.ifElseBrick = ifLogicElseBrick2;
    [self.startScript.brickList addObject:ifLogicEndBrick2];
    
    ifLogicBeginBrick2.ifEndBrick = ifLogicEndBrick2;
    ifLogicElseBrick2.ifEndBrick = ifLogicEndBrick2;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(7, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // second if brick (move up)
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:4 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    ifLogicBeginBrick2.animateInsertBrick = YES;
    BOOL canInsertAboveEndBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                    itemAtIndexPath:indexPathFrom
                                                                                 canInsertToIndexPath:indexPathTo
                                                                                          andObject:self.spriteObject];
    XCTAssertTrue(canInsertAboveEndBrickInsertMode, @"Should be allowed to insert IfLogicBeginBrick above IfLogicEndBrick");
    
    
    // first end brick (move down)
    ifLogicBeginBrick2.animateInsertBrick = NO;
    indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:0];
    indexPathTo = [NSIndexPath indexPathForRow:4 inSection:0];
    
    ifLogicEndBrick1.animateInsertBrick = YES;
    BOOL canInsertBelowIfBeginBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                        itemAtIndexPath:indexPathFrom
                                                                                     canInsertToIndexPath:indexPathTo
                                                                                              andObject:self.spriteObject];
    XCTAssertTrue(canInsertBelowIfBeginBrickInsertMode, @"Should not allowed to insert IfLogicEndBrick below IfLogicBeginBrick");
}

@end
