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

@interface BrickInsertManagerRepeatTests : BrickInsertManagerAbstractTest

@end

@implementation BrickInsertManagerRepeatTests

- (void)testInsertNestedRepeatBricks {
    [self.viewController.collectionView reloadData];
    
    RepeatBrick *repeatBrickA = [[RepeatBrick alloc] init];
    repeatBrickA.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrickA];
    
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = self.startScript;
    loopEndBrickA.loopBeginBrick = repeatBrickA;
    [self.startScript.brickList addObject:loopEndBrickA];
    repeatBrickA.loopEndBrick = loopEndBrickA;
    
    RepeatBrick *repeatBrickB = [[RepeatBrick alloc] init];
    repeatBrickB.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrickB];
    
    LoopEndBrick *loopEndBrickB = [[LoopEndBrick alloc] init];
    loopEndBrickB.script = self.startScript;
    loopEndBrickB.loopBeginBrick = repeatBrickB;
    [self.startScript.brickList addObject:loopEndBrickB];
    repeatBrickB.loopEndBrick = loopEndBrickB;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(5, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    repeatBrickA.animateInsertBrick = YES;
    BOOL canMoveInsideRepeatBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                      itemAtIndexPath:indexPathFrom
                                                                                   canInsertToIndexPath:indexPathTo
                                                                                            andObject:self.spriteObject];
    XCTAssertTrue(canMoveInsideRepeatBrickInsertMode, @"Should be allowed to insert RepeatBrick inside other RepeatBrick");
}

- (void)testInsertIfBrickInsideRepeatBrick {
    [self.viewController.collectionView reloadData];
    
    RepeatBrick *repeatBrick = [[RepeatBrick alloc] init];
    repeatBrick.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrick];
    
    // start if
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
    // end if
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = self.startScript;
    loopEndBrick.loopBeginBrick = repeatBrick;
    [self.startScript.brickList addObject:loopEndBrick];
    repeatBrick.loopEndBrick = loopEndBrick;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(6, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above repeat brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:1 inSection:0];
    
    ifLogicBeginBrick.animateInsertBrick = YES;
    BOOL canMoveAboveRepeatBrickInsertMode = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                        itemAtIndexPath:indexPathFrom
                                                                                     canInsertToIndexPath:indexPathTo
                                                                                              andObject:self.spriteObject];
    XCTAssertTrue(canMoveAboveRepeatBrickInsertMode, @"Should be allowed to move IfBrick inside repeat-loop above RepeatBrick");
}

@end
