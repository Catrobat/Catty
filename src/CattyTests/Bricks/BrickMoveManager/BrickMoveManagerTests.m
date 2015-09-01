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
#import "WhenScript.h"
#import "BrickMoveManager.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"

@interface BrickMoveManagerTests : BrickMoveManagerAbstractTest

@end

@implementation BrickMoveManagerTests

- (void)testMoveWaitBehindSetVariableBrick {
    [self.viewController.collectionView reloadData];
    
    WaitBrick *waitBrick = [[WaitBrick alloc] init];
    waitBrick.script = self.startScript;
    [self.startScript.brickList addObject:waitBrick];
    
    SetVariableBrick *setVariableBrick = [[SetVariableBrick alloc] init];
    setVariableBrick.script = self.startScript;
    [self.startScript.brickList addObject:setVariableBrick];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(3, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
    
    BOOL canMove = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                             itemAtIndexPath:indexPathFrom
                                                          canMoveToIndexPath:indexPathTo
                                                                   andObject:self.spriteObject];
    
    XCTAssertTrue(canMove, @"Should be allowed to move WaitBrick behind SetVariableBrick");
}

- (void)testMoveWaitBehindForeverBrick {
    [self.viewController.collectionView reloadData];
    
    WaitBrick *waitBrick = [[WaitBrick alloc] init];
    waitBrick.script = self.startScript;
    [self.startScript.brickList addObject:waitBrick];
    
    ForeverBrick *foreverBrick = [[ForeverBrick alloc] init];
    foreverBrick.script = self.startScript;
    [self.startScript.brickList addObject:foreverBrick];
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = self.startScript;
    loopEndBrick.loopBeginBrick = foreverBrick;
    [self.startScript.brickList addObject:loopEndBrick];
    foreverBrick.loopEndBrick = loopEndBrick;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(4, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
    
    BOOL canMoveWaitBrickInsideForeverBrick = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                             itemAtIndexPath:indexPathFrom
                                                          canMoveToIndexPath:indexPathTo
                                                                   andObject:self.spriteObject];
    XCTAssertTrue(canMoveWaitBrickInsideForeverBrick, @"Should be allowed to move WaitBrick inside ForeverBrick");
    
    indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    BOOL canMoveWaitBrickBehindForeverBrick = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                               itemAtIndexPath:indexPathFrom
                                                                            canMoveToIndexPath:indexPathTo
                                                                                     andObject:self.spriteObject];
    XCTAssertFalse(canMoveWaitBrickBehindForeverBrick, @"Should not be allowed to move WaitBrick behind ForeverBrick");
}

- (void)testMoveWaitBehindRepeatBrick {
    [self.viewController.collectionView reloadData];
    
    WaitBrick *waitBrick = [[WaitBrick alloc] init];
    waitBrick.script = self.startScript;
    [self.startScript.brickList addObject:waitBrick];
    
    RepeatBrick *repeatBrick = [[RepeatBrick alloc] init];
    repeatBrick.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrick];
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = self.startScript;
    loopEndBrick.loopBeginBrick = repeatBrick;
    [self.startScript.brickList addObject:loopEndBrick];
    repeatBrick.loopEndBrick = loopEndBrick;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(4, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    BOOL canMoveWaitBrickBehindRepeatBrick = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                        itemAtIndexPath:indexPathFrom
                                                                                     canMoveToIndexPath:indexPathTo
                                                                                              andObject:self.spriteObject];
    XCTAssertTrue(canMoveWaitBrickBehindRepeatBrick, @"Should be allowed to move WaitBrick behind RepeatBrick");
}

- (void)testMoveWaitBrickIntoOtherScript {
    [self.viewController.collectionView reloadData];
    
    WaitBrick *waitBrick = [[WaitBrick alloc] init];
    waitBrick.script = self.startScript;
    [self.startScript.brickList addObject:waitBrick];
    
    WhenScript *whenScript = [[WhenScript alloc] init];
    whenScript.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScript];
    
    XCTAssertEqual(2, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(2, [self.viewController.collectionView numberOfItemsInSection:0]);
    XCTAssertEqual(1, [self.viewController.collectionView numberOfItemsInSection:1]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:0 inSection:1];
    
    BOOL canMoveWaitInOtherScript = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                        itemAtIndexPath:indexPathFrom
                                                                                     canMoveToIndexPath:indexPathTo
                                                                                              andObject:self.spriteObject];
    XCTAssertTrue(canMoveWaitInOtherScript, @"Should be allowed to move WaitBrick into other Script");
}

@end
