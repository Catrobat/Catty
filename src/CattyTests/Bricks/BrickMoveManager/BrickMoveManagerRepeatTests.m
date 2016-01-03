/**
 *  Copyright (C) 2010-2016 The Catrobat Team
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

@interface BrickMoveManagerRepeatTests : BrickMoveManagerAbstractTest

@end

@implementation BrickMoveManagerRepeatTests

- (void)testMoveNestedRepeatBricks {

    /*  Test:
     
     0 startedScript
     1  repeatBeginA    --->
     2  repeatEndA
     3  repeatBeginB    <---
     4  repeatEndB
     */

    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    addedBricks += [self addEmptyRepeatLoopToScript:self.startScript];
    
    addedBricks += [self addEmptyRepeatLoopToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:2 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move RepeatBrick inside other RepeatBrick");
}

- (void)testMoveIfBrickInsideRepeatBrick {

    /*  Test:
     
     0 startedScript
     1  repeatBeginA    <---
     2      ifBeginA    --->
     3      elseA
     4      ifEndA
     5  repeatEndA
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    RepeatBrick *repeatBrick = [[RepeatBrick alloc] init];
    repeatBrick.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrick];
    addedBricks++;
    
    addedBricks += [self addEmptyIfElseEndStructureToScript:self.startScript];
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = self.startScript;
    loopEndBrick.loopBeginBrick = repeatBrick;
    [self.startScript.brickList addObject:loopEndBrick];
    repeatBrick.loopEndBrick = loopEndBrick;
    addedBricks++;
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    // if brick above repeat brick
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:2 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:1 inSection:0];
    
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                      itemAtIndexPath:indexPathFrom
                                                                                   canMoveToIndexPath:indexPathTo
                                                                                            andObject:self.spriteObject];
    XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move IfBrick inside repeat-loop above RepeatBrick");    
}

- (void)testMoveWaitBrickToAllPossibleDestinations {
    
    /*  Test:
     
     0 startedScript
     1  repeatBeginA
     2      waitA
     3  repeatEndA
     4  repeatBeginB
     5      waitB
     6  repeatEndB
     7  repeatBeginC
     8      waitC
     9  repeatEndC
    10  repeatBeginD
    11      waitD               --->
    12  repeatEndD
    13  repeatBeginE
    14      waitE
    15  repeatEndE
    16  repeatBeginF
    17      waitF
    18  repeatEndF
    19  repeatBeginG
    20      waitG
    21  repeatEndG
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    NSUInteger sourceIDX = 11;
    
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    for(NSUInteger destinationIDX = 1; destinationIDX<=21; destinationIDX++) {
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                  itemAtIndexPath:indexPathFrom
                                                                               canMoveToIndexPath:indexPathTo
                                                                                        andObject:self.spriteObject];
        XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)destinationIDX);
    }
}

- (void)testMoveRepeatEndToAllPossibleDestinations {
    
    /*  Test:
     
     0 startedScript
     1  repeatBeginA
     2      waitA
     3  repeatEndA
     4  repeatBeginB
     5      waitB
     6  repeatEndB
     7  repeatBeginC
     8      waitC
     9  repeatEndC
    10  repeatBeginD
    11      waitD
    12  repeatEndD
    13  repeatBeginE
    14      waitE                  (valid)
    15  repeatEndE         --->
    16  repeatBeginF
    17      waitF
    18  repeatEndF
    19  repeatBeginG
    20      waitG
    21  repeatEndG
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    NSUInteger sourceIDX = 15;
    NSUInteger validTarget1 = 14;
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:16 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:13 inSection:0]];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];

    for(NSUInteger destinationIDX = 1; destinationIDX < addedBricks; destinationIDX++) {
        if((destinationIDX != validTarget1)&& destinationIDX != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
            [[BrickMoveManager sharedInstance] reset];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
        }
    }
    
    {
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget1);
    }
}

- (void)testMoveRepeatBeginToAllPossibleDestinations {
    
    /*  Test:
     
     0 startedScript
     1  repeatBeginA
     2      waitA
     3  repeatEndA
     4  repeatBeginB
     5      waitB
     6  repeatEndB
     7  repeatBeginC        --->
     8      waitC                   (valid)
     9  repeatEndC
     10  repeatBeginD
     11      waitD
     12  repeatEndD
     13  repeatBeginE
     14      waitE
     15  repeatEndE
     16  repeatBeginF
     17      waitF
     18  repeatEndF
     19  repeatBeginG
     20      waitG
     21  repeatEndG
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    NSUInteger sourceIDX = 7;
    NSUInteger validTarget3 = 8;
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:9 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:6 inSection:0]];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    for(NSUInteger destinationIDX = 1; destinationIDX<=21; destinationIDX++) {
        if((destinationIDX != validTarget3)&& destinationIDX != sourceIDX ) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
        }
    }
    
    {
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget3 inSection:0];
        [[BrickMoveManager sharedInstance] reset];
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                 itemAtIndexPath:indexPathFrom
                                                              canMoveToIndexPath:indexPathTo
                                                                       andObject:self.spriteObject];
        XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget3);
    }
    
}

- (void)testMoveRepeatBeginToAllPossibleDestinationsNested {
    
    /*  Test:
     
     0 startedScript
     1  repeatBeginA
     2      waitA
     3  repeatEndA
     4  repeatBeginB
     5      ifBeginA
     6          foreverBeginA
     7              waitA
     8          foreverEndA
     9      elseA
    10          repeatBeginC        --->
    11              waitB                   (valid)
    12          repeatEndC
    13      ifEndA
    14  repeatEndC
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    NSUInteger validTarget1 = 11;
    NSUInteger sourceIDX = 10;
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:12 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:9 inSection:0]];
    // 1, 2, 3
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    // 4
    RepeatBrick *repeatBrickA = [[RepeatBrick alloc] init];
    repeatBrickA.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrickA];
    addedBricks++;
    
    // 5
    IfLogicBeginBrick *ifLogicBeginBrickA = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickA.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickA];
    addedBricks++;
    
    // 6, 7, 8
    addedBricks += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    // 9
    IfLogicElseBrick *ifLogicElseBrickA = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickA.script = self.startScript;
    ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA;
    [self.startScript.brickList addObject:ifLogicElseBrickA];
    ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA;
    addedBricks++;
    
    // 10, 11, 12
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    // 13
    IfLogicEndBrick *ifLogicEndBrickA = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickA.script = self.startScript;
    ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA;
    ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA;
    [self.startScript.brickList addObject:ifLogicEndBrickA];
    ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA;
    ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA;
    addedBricks++;
    
    
    // 14
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = self.startScript;
    loopEndBrickA.loopBeginBrick = repeatBrickA;
    [self.startScript.brickList addObject:loopEndBrickA];
    repeatBrickA.loopEndBrick = loopEndBrickA;
    addedBricks++;
    
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
        if( destinationIDX != validTarget1 && destinationIDX != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
            [[BrickMoveManager sharedInstance] reset];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
        }
    }
    
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
    [[BrickMoveManager sharedInstance] reset];
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                  itemAtIndexPath:indexPathFrom
                                                               canMoveToIndexPath:indexPathTo
                                                                        andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget1);
}

- (void)testMoveRepeatEndToAllPossibleDestinationsNested {
    
    /*  Test:
     
     0 startedScript
     1  repeatBeginA
     2      waitA
     3  repeatEndA
     4  repeatBeginB
     5      ifBeginA
     6          foreverBeginA
     7              waitA
     8          foreverEndA
     9      elseA
     10          repeatBeginC
     11              waitB                   (valid)
     12          repeatEndC         --->
     13      ifEndA
     14  repeatEndC
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    NSUInteger validTarget1 = 11;
    NSUInteger sourceIDX = 12;
    [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:13 inSection:0]];
    [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:10 inSection:0]];
    // 1, 2, 3
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    // 4
    RepeatBrick *repeatBrickA = [[RepeatBrick alloc] init];
    repeatBrickA.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrickA];
    addedBricks++;
    
    // 5
    IfLogicBeginBrick *ifLogicBeginBrickA = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickA.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickA];
    addedBricks++;
    
    // 6, 7, 8
    addedBricks += [self addForeverLoopWithWaitBrickToScript:self.startScript];
    
    // 9
    IfLogicElseBrick *ifLogicElseBrickA = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickA.script = self.startScript;
    ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA;
    [self.startScript.brickList addObject:ifLogicElseBrickA];
    ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA;
    addedBricks++;
    
    // 10, 11, 12
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:self.startScript];
    
    // 13
    IfLogicEndBrick *ifLogicEndBrickA = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickA.script = self.startScript;
    ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA;
    ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA;
    [self.startScript.brickList addObject:ifLogicEndBrickA];
    ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA;
    ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA;
    addedBricks++;
    
    
    // 14
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = self.startScript;
    loopEndBrickA.loopBeginBrick = repeatBrickA;
    [self.startScript.brickList addObject:loopEndBrickA];
    repeatBrickA.loopEndBrick = loopEndBrickA;
    addedBricks++;
    
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
        if( destinationIDX != validTarget1 && destinationIDX != sourceIDX) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
            [[BrickMoveManager sharedInstance] reset];
            BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                          itemAtIndexPath:indexPathFrom
                                                                       canMoveToIndexPath:indexPathTo
                                                                                andObject:self.spriteObject];
            XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
        }
    }
    
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
    [[BrickMoveManager sharedInstance] reset];
    BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                  itemAtIndexPath:indexPathFrom
                                                               canMoveToIndexPath:indexPathTo
                                                                        andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget1);
}

- (void)testMoveRepeatEndToAllPossibleDestinationsNestedHigherOrder {
    
    /*  Test:
     
     0 startedScript                    (1)             (2)             (3)             (4)
     1  ifBeginA
     2      reapeatBeginA
     3          repeatBeginB
     4              repeatBeginC
     5                  waitA
     6              repeatEndC
     7          repeatEndB
     8      repeatEndA
     9  elseA
    10      reapeatBeginA
    11          repeatBeginB
    12             repeatBeginC
    13                  waitA                                          (valid)
    14              repeatEndC                                          --->
    15          repeatEndB
    16      repeatEndA
    17  ifEndA
    18  reapeatBeginA
    19      repeatBeginB            (not valid)
    20          repeatBeginC                           (not valid)                       (all valid)
    21              waitA                                                               --->
    22          repeatEndC
    23      repeatEndB                                  --->
    24  repeatEndA                     --->
     */
    
    [self.viewController.collectionView reloadData];
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    NSUInteger addedBricks = 1;
    
    // 1
    IfLogicBeginBrick *ifLogicBeginBrickA = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickA.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickA];
    addedBricks++;
    
    // 2-8
    addedBricks += [self addNestedRepeatOrder3WithWaitInHighestLevelToScript:self.startScript];
    
    // 9
    IfLogicElseBrick *ifLogicElseBrickA = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickA.script = self.startScript;
    ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA;
    [self.startScript.brickList addObject:ifLogicElseBrickA];
    ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA;
    addedBricks++;
    
    // 10-16
    addedBricks += [self addNestedRepeatOrder3WithWaitInHighestLevelToScript:self.startScript];
    
    // 17
    IfLogicEndBrick *ifLogicEndBrickA = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickA.script = self.startScript;
    ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA;
    ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA;
    [self.startScript.brickList addObject:ifLogicEndBrickA];
    ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA;
    ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA;
    addedBricks++;
    
    // 18-24
    addedBricks += [self addNestedRepeatOrder3WithWaitInHighestLevelToScript:self.startScript];
    
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    
    
    // (1)
    {   // seperated Namespace for Testcases (1)-(4)
        NSUInteger sourceIDX = 24;
        NSUInteger validTarget1 = 19;
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:24 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:23 inSection:0]];
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
        
        for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
            if( destinationIDX != validTarget1 && destinationIDX != sourceIDX) {
                NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
                [[BrickMoveManager sharedInstance] reset];
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
            }
        }
        
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
        [[BrickMoveManager sharedInstance] reset];
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)validTarget1);
    }
    
    // (2)
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    {
        NSUInteger sourceIDX = 23;
        NSUInteger validTarget1 = 20;
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:24 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:22 inSection:0]];
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
        
        for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
            if( destinationIDX != validTarget1 && destinationIDX != sourceIDX ) {
                NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
                [[BrickMoveManager sharedInstance] reset];
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
            }
        }
        
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
        [[BrickMoveManager sharedInstance] reset];
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)validTarget1);
    }
    
    // (3)
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    {
        NSUInteger sourceIDX = 14;
        NSUInteger validTarget1 = 13;
        
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:15 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:12 inSection:0]];
        for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
            if( destinationIDX != validTarget1 && destinationIDX != sourceIDX ) {
                NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
                [[BrickMoveManager sharedInstance] reset];
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
            }
        }
        
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
        [[BrickMoveManager sharedInstance] reset];
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget1);
    }
    
    // (4)
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    {
        NSUInteger sourceIDX = 21;
        
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
        for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
            NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
            if (destinationIDX != sourceIDX) {
                [[BrickMoveManager sharedInstance] reset];
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
                XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)destinationIDX);
            }
            
        }
        
    }
}

- (void)testMoveRepeatBeginToAllPossibleDestinationsNestedHigherOrder {
    
    /*  Test:
     
     0 startedScript                    (1)             (2)             (3)             (4)
     1  ifBeginA
     2      reapeatBeginA              --->
     3          repeatBeginB
     4              repeatBeginC                       --->
     5                  waitA                         (valid)
     6              repeatEndC
     7          repeatEndB             (not valid)
     8      repeatEndA
     9  elseA
     10      reapeatBeginA                                              --->
     11          repeatBeginB
     12             repeatBeginC
     13                  waitA
     14              repeatEndC
     15          repeatEndB                                            (not valid)
     16      repeatEndA
     17  ifEndA
     18  reapeatBeginA
     19      repeatBeginB                                                               --->
     20          repeatBeginC
     21              waitA
     22          repeatEndC                                                            (not valid)
     23      repeatEndB
     24  repeatEndA
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    
    // 1
    IfLogicBeginBrick *ifLogicBeginBrickA = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickA.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickA];
    addedBricks++;
    
    // 2-8
    addedBricks += [self addNestedRepeatOrder3WithWaitInHighestLevelToScript:self.startScript];
    
    // 9
    IfLogicElseBrick *ifLogicElseBrickA = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickA.script = self.startScript;
    ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA;
    [self.startScript.brickList addObject:ifLogicElseBrickA];
    ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA;
    addedBricks++;
    
    // 10-16
    addedBricks += [self addNestedRepeatOrder3WithWaitInHighestLevelToScript:self.startScript];
    
    // 17
    IfLogicEndBrick *ifLogicEndBrickA = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickA.script = self.startScript;
    ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA;
    ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA;
    [self.startScript.brickList addObject:ifLogicEndBrickA];
    ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA;
    ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA;
    addedBricks++;
    
    // 18-24
    addedBricks += [self addNestedRepeatOrder3WithWaitInHighestLevelToScript:self.startScript];
    
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    
    
    // (1)
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    {   // seperated Namespace for Testcases (1)-(4)
        NSUInteger sourceIDX = 2;
        NSUInteger validTarget1 = 7;
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:3 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:1 inSection:0]];
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
        
        for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
            if( destinationIDX != validTarget1 && destinationIDX != sourceIDX) {
                NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
                
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
            }
        }
        
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)validTarget1);
    }
    
    // (2)
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    {
        NSUInteger sourceIDX = 4;
        NSUInteger validTarget1 = 5;
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:6 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:3 inSection:0]];
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
        
        for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
            if( destinationIDX != validTarget1 && destinationIDX != sourceIDX) {
                NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
                
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
            }
        }
        
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget1);
    }
    
    // (3)
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    {
        NSUInteger sourceIDX = 10;
        NSUInteger validTarget1 = 15;
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:11 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:9 inSection:0]];
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
        
        for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
            if( destinationIDX != validTarget1 && destinationIDX != sourceIDX) {
                NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
                
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
            }
        }
        
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should be not allowed to move to line %lu.", (unsigned long)validTarget1);
    }
    
    // (4)
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
    {
        NSUInteger sourceIDX = 19;
        NSUInteger validTarget1 = 22;
        
        NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
        [[BrickMoveManager sharedInstance] setLowerBorder:[NSIndexPath indexPathForRow:20 inSection:0]];
        [[BrickMoveManager sharedInstance] setUpperBorder:[NSIndexPath indexPathForRow:18 inSection:0]];
        for(NSUInteger destinationIDX = 1; destinationIDX<addedBricks; destinationIDX++) {
            if( destinationIDX != validTarget1 && destinationIDX != sourceIDX) {
                NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:destinationIDX inSection:0];
                
                BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
                XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)destinationIDX);
            }
        }
        
        NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:validTarget1 inSection:0];
        
        BOOL canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                      itemAtIndexPath:indexPathFrom
                                                                   canMoveToIndexPath:indexPathTo
                                                                            andObject:self.spriteObject];
        XCTAssertFalse(canMoveToDestination, @"Should not be allowed to move to line %lu.", (unsigned long)validTarget1);
    }
}


@end
