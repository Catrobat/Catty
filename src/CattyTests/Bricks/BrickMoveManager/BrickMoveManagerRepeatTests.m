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
    
    addedBricks += [self addEmptyRepeatLoop];
    
    addedBricks += [self addEmptyRepeatLoop];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:1 inSection:0];
    NSIndexPath *indexPathTo = [NSIndexPath indexPathForRow:3 inSection:0];
    
    BOOL canMoveInsideRepeatBrickEditMode = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                              itemAtIndexPath:indexPathFrom
                                                                           canMoveToIndexPath:indexPathTo
                                                                                    andObject:self.spriteObject];
    XCTAssertFalse(canMoveInsideRepeatBrickEditMode, @"Should not be allowed to move RepeatBrick inside other RepeatBrick");
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
    
    addedBricks += [self addEmptyIfElseEndStructure];
    
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
    
    BOOL canMoveAboveRepeatBrickEditMode = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                                      itemAtIndexPath:indexPathFrom
                                                                                   canMoveToIndexPath:indexPathTo
                                                                                            andObject:self.spriteObject];
    XCTAssertFalse(canMoveAboveRepeatBrickEditMode, @"Should not be allowed to move IfBrick inside repeat-loop above RepeatBrick");    
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
    
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    
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
    18  repeatEndF                 (valid)
    19  repeatBeginG
    20      waitG
    21  repeatEndG                 (valid)
     */
    
    [self.viewController.collectionView reloadData];
    
    NSUInteger addedBricks = 1;
    NSUInteger sourceIDX = 11;
    NSUInteger validTarget1 = 14;
    NSUInteger validTarget2 = 18;
    NSUInteger validTarget3 = 21;
    
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    for(NSUInteger destinationIDX = 1; destinationIDX<=21; destinationIDX++) {
        if( (destinationIDX != validTarget1) && (destinationIDX != validTarget2) && (destinationIDX != validTarget3) ) {
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
    
    indexPathTo = [NSIndexPath indexPathForRow:validTarget2 inSection:0];
    
    canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                                  itemAtIndexPath:indexPathFrom
                                                               canMoveToIndexPath:indexPathTo
                                                                        andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget2);
    
    indexPathTo = [NSIndexPath indexPathForRow:validTarget3 inSection:0];
    
    canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                             itemAtIndexPath:indexPathFrom
                                                          canMoveToIndexPath:indexPathTo
                                                                   andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget3);
}

- (void)testMoveRepeatBeginToAllPossibleDestinations {
    
    /*  Test:
     
     0 startedScript
     1  repeatBeginA                (valid)
     2      waitA
     3  repeatEndA
     4  repeatBeginB                (valid)
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
    NSUInteger validTarget1 = 1;
    NSUInteger validTarget2 = 4;
    NSUInteger validTarget3 = 8;
    
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    addedBricks += [self addRepeatLoopWithWaitBrick];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(addedBricks, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    NSIndexPath *indexPathFrom = [NSIndexPath indexPathForRow:sourceIDX inSection:0];
    
    for(NSUInteger destinationIDX = 1; destinationIDX<=21; destinationIDX++) {
        if( (destinationIDX != validTarget1) && (destinationIDX != validTarget2) && (destinationIDX != validTarget3) ) {
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
    
    indexPathTo = [NSIndexPath indexPathForRow:validTarget2 inSection:0];
    
    canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                             itemAtIndexPath:indexPathFrom
                                                          canMoveToIndexPath:indexPathTo
                                                                   andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget2);
    
    indexPathTo = [NSIndexPath indexPathForRow:validTarget3 inSection:0];
    
    canMoveToDestination = [[BrickMoveManager sharedInstance] collectionView:self.viewController.collectionView
                                                             itemAtIndexPath:indexPathFrom
                                                          canMoveToIndexPath:indexPathTo
                                                                   andObject:self.spriteObject];
    XCTAssertTrue(canMoveToDestination, @"Should be allowed to move to line %lu.", (unsigned long)validTarget3);
}

@end
