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

    /*  Test:
     
     0 startedScript
     1  wait            --->
     2  setVariable     <---
     */

    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    WaitBrick *waitBrick = [[WaitBrick alloc] init];
    waitBrick.script = self.startScript;
    [self.startScript.brickList addObject:waitBrick];
    addedBricks++;
    
    SetVariableBrick *setVariableBrick = [[SetVariableBrick alloc] init];
    setVariableBrick.script = self.startScript;
    [self.startScript.brickList addObject:setVariableBrick];
    addedBricks++;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
    
    BOOL canMove = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                             itemAtIndexPath:indexPathFrom
                                                          canMoveToIndexPath:indexPathTo
                                                                   andObject:self.spriteObject];
    
    XCTAssertTrue(canMove, @"Should be allowed to move WaitBrick behind SetVariableBrick");
}

- (void)testMoveWaitBehindForeverBrick {

    /*  Test:
     
     0 startedScript      (1)        (2)
     1  wait             --->       --->
     2  foreverBeginA    <---
     3  foreverEndA                 <---
     */

    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    WaitBrick *waitBrick = [[WaitBrick alloc] init];
    waitBrick.script = self.startScript;
    [self.startScript.brickList addObject:waitBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyForeverLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    
    {
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:2 inSection:0];
        
        BOOL canMoveWaitBrickInsideForeverBrick = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                 itemAtIndexPath:indexPathFrom
                                                              canMoveToIndexPath:indexPathTo
                                                                       andObject:self.spriteObject];
        XCTAssertTrue(canMoveWaitBrickInsideForeverBrick, @"Should be allowed to move WaitBrick inside ForeverBrick");
    }
    
    {
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
        BOOL canMoveWaitBrickBehindForeverBrick = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                   itemAtIndexPath:indexPathFrom
                                                                                canMoveToIndexPath:indexPathTo
                                                                                         andObject:self.spriteObject];
        XCTAssertFalse(canMoveWaitBrickBehindForeverBrick, @"Should not be allowed to move WaitBrick behind ForeverBrick");
    }
    
}

- (void)testMoveWaitBehindRepeatBrick {

    /*  Test:
     
     0 startedScript
     1  wait            --->
     2  repeatBeginA
     3  repeatEndA      <---
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    WaitBrick *waitBrick = [[WaitBrick alloc] init];
    waitBrick.script = self.startScript;
    [self.startScript.brickList addObject:waitBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyRepeatLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    BOOL canMoveWaitBrickBehindRepeatBrick = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                        itemAtIndexPath:indexPathFrom
                                                                                     canMoveToIndexPath:indexPathTo
                                                                                              andObject:self.spriteObject];
    XCTAssertTrue(canMoveWaitBrickBehindRepeatBrick, @"Should be allowed to move WaitBrick behind RepeatBrick");
}

- (void)testMoveWaitBrickIntoOtherScript {

    /*  Test:
     
     0 startedScript
     1  wait            --->
     
     0 whenScript
     1                   <---
     */

    [self.viewController.collectionView reloadData];
    
    NSUInteger addedSections = 1;
    NSUInteger addedBricksStart = 1;
    
    WaitBrick *waitBrick = [[WaitBrick alloc] init];
    waitBrick.script = self.startScript;
    [self.startScript.brickList addObject:waitBrick];
    addedBricksStart++;
    
    WhenScript *whenScript = [[WhenScript alloc] init];
    whenScript.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScript];
    NSUInteger addedBricksWhen = 1;
    addedSections++;
    
    XCTAssertEqual(addedSections, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricksStart, [self.viewController.collectionView numberOfItemsInSection:0]);
    XCTAssertEqual(addedBricksWhen, [self.viewController.collectionView numberOfItemsInSection:1]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:0 inSection:1];
    
    BOOL canMoveWaitInOtherScript = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                        itemAtIndexPath:indexPathFrom
                                                                                     canMoveToIndexPath:indexPathTo
                                                                                              andObject:self.spriteObject];
    XCTAssertTrue(canMoveWaitInOtherScript, @"Should be allowed to move WaitBrick into other Script");
}

- (void)testMoveForeverBeginBrickWithMultipleScripts
{
    /*  Test:
     
     0 startedScript
     1  foreverBeginA
     2      waitA
     3  foreverEndA
     
     0 whenScript
     1  foreverBeginB            --->
     2      waitB              (valid)
     3  foreverEndB
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedSections = 1;
    NSUInteger addedBricksStart = 1;
    
    NSUInteger validRow = 2;
    NSUInteger validSection = 1;
    NSIndexPath* validTarget = [NSIndexPath indexPathForRow:validRow inSection:validSection];
    
    addedBricksStart += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    WhenScript *whenScript = [[WhenScript alloc] init];
    whenScript.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScript];
    NSUInteger addedBricksWhen = 1;
    addedSections++;
    
    addedBricksWhen += [self addForeverLoopWithWaitBrickToScript:whenScript];
    
    XCTAssertEqual(addedSections, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricksStart, [self.viewController.collectionView numberOfItemsInSection:0]);
    XCTAssertEqual(addedBricksWhen, [self.viewController.collectionView numberOfItemsInSection:1]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:1];
    
    for(NSUInteger section = 0; section < addedSections; section++) {
        for(NSUInteger destinationIDX = 1; destinationIDX < addedBricksStart; destinationIDX++) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:section];
            
            if(![indexPathTo isEqual:validTarget]) {
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to idx %lu in section %lu", destinationIDX, section);
            }
        }
    }
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:validTarget
                                                                            andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to idx %lu in section %lu", validRow, validSection);
    
}

- (void)testMoveForeverEndBrickWithMultipleScripts
{
    /*  Test:
     
     0 startedScript
     1  foreverBeginA
     2      waitA
     3  foreverEndA
     
     0 whenScript
     1  foreverBeginB
     2      waitB
     3  foreverEndB             --->
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedSections = 1;
    NSUInteger addedBricksStart = 1;
    
    addedBricksStart += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    WhenScript *whenScript = [[WhenScript alloc] init];
    whenScript.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScript];
    NSUInteger addedBricksWhen = 1;
    addedSections++;
    
    addedBricksWhen += [self addForeverLoopWithWaitBrickToScript:whenScript];
    
    XCTAssertEqual(addedBricksWhen, addedBricksStart);
    XCTAssertEqual(addedSections, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricksStart, [self.viewController.collectionView numberOfItemsInSection:0]);
    XCTAssertEqual(addedBricksWhen, [self.viewController.collectionView numberOfItemsInSection:1]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:1];
    
    for(NSUInteger section = 0; section < addedSections; section++) {
        for(NSUInteger destinationIDX = 1; destinationIDX < addedBricksStart; destinationIDX++) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:section];
            
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to idx %lu in section %lu", destinationIDX, section);
        }
    }
}

- (void)testMoveRepeatBeginBrickWithMultipleScripts
{
    /*  Test:
     
     0 startedScript
     1  repeatBeginA
     2      waitA
     3  repeatEndA
     
     0 whenScript
     1  repeatBeginB            --->
     2      waitB              (valid)
     3  repeatEndB
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedSections = 1;
    NSUInteger addedBricksStart = 1;
    
    NSUInteger validRow = 2;
    NSUInteger validSection = 1;
    NSIndexPath* validTarget = [NSIndexPath indexPathForRow:validRow inSection:validSection];
    
    addedBricksStart += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    WhenScript *whenScript = [[WhenScript alloc] init];
    whenScript.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScript];
    NSUInteger addedBricksWhen = 1;
    addedSections++;
    
    addedBricksWhen += [self addRepeatLoopWithWaitBrickToScript:whenScript];
    
    XCTAssertEqual(addedSections, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricksStart, [self.viewController.collectionView numberOfItemsInSection:0]);
    XCTAssertEqual(addedBricksWhen, [self.viewController.collectionView numberOfItemsInSection:1]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:1];
    
    for(NSUInteger section = 0; section < addedSections; section++) {
        for(NSUInteger destinationIDX = 1; destinationIDX < addedBricksStart; destinationIDX++) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:section];
            
            if(![indexPathTo isEqual:validTarget]) {
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                  itemAtIndexPath:indexPathFrom
                                                                               canMoveToIndexPath:indexPathTo
                                                                                        andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to idx %lu in section %lu", destinationIDX, section);
            }
        }
    }
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:validTarget
                                                                            andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to idx %lu in section %lu", validRow, validSection);
    
}

- (void)testMoveRepeatEndBrickWithMultipleScripts
{
    /*  Test:
     
     0 startedScript
     1  repeatBeginA
     2      waitA
     3  repeatEndA
     
     0 whenScript
     1  repeatBeginB
     2      waitB              (valid)
     3  repeatEndB              --->
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedSections = 1;
    NSUInteger addedBricksStart = 1;
    
    NSUInteger validRow = 2;
    NSUInteger validSection = 1;
    NSIndexPath* validTarget = [NSIndexPath indexPathForRow:validRow inSection:validSection];
    
    addedBricksStart += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    WhenScript *whenScript = [[WhenScript alloc] init];
    whenScript.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScript];
    NSUInteger addedBricksWhen = 1;
    addedSections++;
    
    addedBricksWhen += [self addRepeatLoopWithWaitBrickToScript:whenScript];
    
    XCTAssertEqual(addedSections, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricksStart, [self.viewController.collectionView numberOfItemsInSection:0]);
    XCTAssertEqual(addedBricksWhen, [self.viewController.collectionView numberOfItemsInSection:1]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:3 inSection:1];
    
    for(NSUInteger section = 0; section < addedSections; section++) {
        for(NSUInteger destinationIDX = 1; destinationIDX < addedBricksStart; destinationIDX++) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:section];
            
            if(![indexPathTo isEqual:validTarget]) {
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                  itemAtIndexPath:indexPathFrom
                                                                               canMoveToIndexPath:indexPathTo
                                                                                        andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to idx %lu in section %lu", destinationIDX, section);
            }
        }
    }
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:validTarget
                                                                            andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to idx %lu in section %lu", validRow, validSection);
    
}

- (void)testMoveMoveableBricksAround
{
    /*  Test:
     
     0 startedScript
     1  waitBrickA
     2  setXBrickA
     3  setYBrickA
     4  waitBrickB
     5  placeAtXYA
     6  waitBrickC
     
     0 whenScriptA
     1  waitBrickA
     2  setXBrickA
     3  setYBrickA
     4  waitBrickB
     5  placeAtXYA
     6  waitBrickC
     
     0 whenScriptB
     1  waitBrickA
     2  setXBrickA
     3  setYBrickA
     4  waitBrickB
     5  placeAtXYA
     6  waitBrickC
     
     0 whenScriptC
     1  waitBrickA
     2  setXBrickA
     3  setYBrickA
     4  waitBrickB
     5  placeAtXYA
     6  waitBrickC
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedSections = 1;
    NSUInteger addedBricksStart = 1;
    
    addedBricksStart += [self addWaitSetXSetYWaitPlaceAtWaitBricksToScript:self.startScript];
    
    WhenScript *whenScriptA = [[WhenScript alloc] init];
    whenScriptA.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScriptA];
    NSUInteger addedBricksWhenA = 1;
    addedSections++;
    addedBricksWhenA += [self addWaitSetXSetYWaitPlaceAtWaitBricksToScript:whenScriptA];
    
    WhenScript *whenScriptB = [[WhenScript alloc] init];
    whenScriptB.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScriptB];
    NSUInteger addedBricksWhenB = 1;
    addedSections++;
    addedBricksWhenB += [self addWaitSetXSetYWaitPlaceAtWaitBricksToScript:whenScriptB];
    
    WhenScript *whenScriptC = [[WhenScript alloc] init];
    whenScriptC.object = self.spriteObject;
    [self.spriteObject.scriptList addObject:whenScriptC];
    NSUInteger addedBricksWhenC = 1;
    addedSections++;
    addedBricksWhenC += [self addWaitSetXSetYWaitPlaceAtWaitBricksToScript:whenScriptC];
    
    
    
    XCTAssertTrue((addedBricksWhenA == addedBricksWhenB) && (addedBricksWhenB == addedBricksWhenC));
    XCTAssertEqual(addedSections, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricksStart, [self.viewController.collectionView numberOfItemsInSection:0]);
    XCTAssertEqual(addedBricksWhenA, [self.viewController.collectionView numberOfItemsInSection:1]);
    XCTAssertEqual(addedBricksWhenB, [self.viewController.collectionView numberOfItemsInSection:2]);
    XCTAssertEqual(addedBricksWhenC, [self.viewController.collectionView numberOfItemsInSection:3]);
    
    for(NSUInteger sourceSection = 0; sourceSection < addedSections; sourceSection++) {
        for(NSUInteger sourceIDX = 1; sourceIDX < addedBricksStart; sourceIDX++) {
            
            NSIndexPath* indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:sourceSection];
            
            for(NSUInteger destinationSection = 0; destinationSection < addedSections; destinationSection++) {
                for(NSUInteger destinationIDX = 1; destinationIDX < addedBricksStart; destinationIDX++) {
                    
                    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:destinationSection];
                    
                    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                      itemAtIndexPath:indexPathFrom
                                                                                   canMoveToIndexPath:indexPathTo
                                                                                            andObject:self.spriteObject];
                    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move from section %lu, row %lu to section %lu, row %lu", sourceSection, sourceIDX, destinationSection, destinationIDX);
                    
                }
            }
        }
    }
}


@end
