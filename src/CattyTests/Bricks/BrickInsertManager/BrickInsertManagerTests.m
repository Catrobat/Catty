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
#import "WhenScript.h"
#import "BrickInsertManager.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"

@interface BrickInsertManagerTests : BrickInsertManagerAbstractTest

@end

@implementation BrickInsertManagerTests

- (void)testInsertWaitBehindSetVariableBrick {
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
    
    waitBrick.animateInsertBrick = YES;
    BOOL canInsert = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                             itemAtIndexPath:indexPathFrom
                                                          canInsertToIndexPath:indexPathTo
                                                                   andObject:self.spriteObject];
    
    XCTAssertTrue(canInsert, @"Should be allowed to insert WaitBrick behind SetVariableBrick");
}

- (void)testInsertWaitBehindForeverBrick {
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
    
    waitBrick.animateInsertBrick = YES;
    BOOL canInsertWaitBrickInsideForeverBrick = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                             itemAtIndexPath:indexPathFrom
                                                          canInsertToIndexPath:indexPathTo
                                                                   andObject:self.spriteObject];
    XCTAssertTrue(canInsertWaitBrickInsideForeverBrick, @"Should be allowed to insert WaitBrick inside ForeverBrick");
    
    indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    BOOL canMoveWaitBrickBehindForeverBrick = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                               itemAtIndexPath:indexPathFrom
                                                                            canInsertToIndexPath:indexPathTo
                                                                                     andObject:self.spriteObject];
    XCTAssertFalse(canMoveWaitBrickBehindForeverBrick, @"Should not be allowed to insert WaitBrick behind ForeverBrick");
}

- (void)testInsertWaitBehindRepeatBrick {
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
    
    waitBrick.animateInsertBrick = YES;
    BOOL canInsertWaitBrickBehindRepeatBrick = [[BrickInsertManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                        itemAtIndexPath:indexPathFrom
                                                                                     canInsertToIndexPath:indexPathTo
                                                                                              andObject:self.spriteObject];
    XCTAssertTrue(canInsertWaitBrickBehindRepeatBrick, @"Should be allowed to insert WaitBrick behind RepeatBrick");
}

@end
