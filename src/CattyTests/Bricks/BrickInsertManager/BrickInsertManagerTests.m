/**
 *  Copyright (C) 2010-2024 The Catrobat Team
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
#import "BrickManager.h"
#import "BrickInsertManager.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "IfThenLogicBeginBrick.h"
#import "IfThenLogicEndBrick.h"

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

- (void)testCopyIfThenLogicBeginBrick {
    [self.viewController.collectionView reloadData];
    
    IfThenLogicBeginBrick *ifThenLogicBeginBrick = [IfThenLogicBeginBrick new];
    ifThenLogicBeginBrick.ifCondition = [[Formula alloc] initWithFloat:3];
    ifThenLogicBeginBrick.script = self.startScript;
    
    IfThenLogicEndBrick *ifThenLogicEndBrick = [IfThenLogicEndBrick new];
    ifThenLogicEndBrick.script = self.startScript;
    ifThenLogicEndBrick.ifBeginBrick = ifThenLogicBeginBrick;
    ifThenLogicBeginBrick.ifEndBrick = ifThenLogicEndBrick;
    
    [self.startScript.brickList addObject:ifThenLogicBeginBrick];
    [self.startScript.brickList addObject:ifThenLogicEndBrick];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(3, [self.viewController.collectionView numberOfItemsInSection:0]);
    XCTAssertEqual(2, [self.startScript.brickList count]);
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    
    NSArray<NSIndexPath*> *copiedBricksIndexPaths = [[BrickManager sharedBrickManager] scriptCollectionCopyBrickWithIndexPath:indexPath andBrick:ifThenLogicBeginBrick];
    
    XCTAssertEqual(2, [copiedBricksIndexPaths count]);
    XCTAssertEqual(indexPath.section, copiedBricksIndexPaths[0].section);
    XCTAssertEqual(indexPath.row, copiedBricksIndexPaths[0].row);
    XCTAssertEqual(indexPath.section, copiedBricksIndexPaths[1].section);
    XCTAssertEqual(indexPath.row + 1, copiedBricksIndexPaths[1].row);
    XCTAssertEqual(4, [self.startScript.brickList count]);
}

@end
