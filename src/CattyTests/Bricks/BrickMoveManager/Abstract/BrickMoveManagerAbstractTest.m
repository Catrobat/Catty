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
#import "BrickMoveManager.h"
#import "WaitBrick.h"
#import "ForeverBrick.h"
#import "RepeatBrick.h"
#import "LoopEndBrick.h"
#import "SetVariableBrick.h"
#import "WhenScript.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"

@implementation BrickMoveManagerAbstractTest

- (void)setUp
{
    [super setUp];
    self.spriteObject = [[SpriteObject alloc] init];
    self.spriteObject.name = @"SpriteObject";
    
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = CGSizeMake(100, 100);
    
    self.viewController = [[ScriptCollectionViewController alloc] initWithCollectionViewLayout:layout];
    
    XCTAssertNotNil(self.viewController, @"ScriptCollectionViewController must not be nil");
    
    self.viewController.object = self.spriteObject;
    
    self.startScript = [[StartScript alloc] init];
    self.startScript.object = self.spriteObject;
    
    [self.spriteObject.scriptList addObject:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(1, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    [[BrickMoveManager sharedInstance] reset];
}

- (NSUInteger)addForeverLoopWithWaitBrick
{

    /* Setup:
    
     0  foreverBeginA
     1      waitA
     2  foreverEndA
    */
    NSUInteger addedBricks = 0;

    ForeverBrick *foreverBrickA = [[ForeverBrick alloc] init];
    foreverBrickA.script = self.startScript;
    [self.startScript.brickList addObject:foreverBrickA];
    addedBricks++;
    
    WaitBrick *waitBrickA = [[WaitBrick alloc] init];
    [self.startScript.brickList addObject:waitBrickA];
    addedBricks++;
    
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = self.startScript;
    loopEndBrickA.loopBeginBrick = foreverBrickA;
    [self.startScript.brickList addObject:loopEndBrickA];
    foreverBrickA.loopEndBrick = loopEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addRepeatLoopWithWaitBrick
{
    
    /* Setup:
     
     0  foreverBeginA
     1      waitA
     2  foreverEndA
     */
    NSUInteger addedBricks = 0;
    
    RepeatBrick *repeatBrickA = [[RepeatBrick alloc] init];
    repeatBrickA.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrickA];
    addedBricks++;
    
    WaitBrick *waitBrickA = [[WaitBrick alloc] init];
    [self.startScript.brickList addObject:waitBrickA];
    addedBricks++;
    
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = self.startScript;
    loopEndBrickA.loopBeginBrick = repeatBrickA;
    [self.startScript.brickList addObject:loopEndBrickA];
    repeatBrickA.loopEndBrick = loopEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addEmptyIfElseEndStructure
{
    /*  Setup:
     
     0  ifBegin
     1  else
     2  ifEnd
     */
    
    NSUInteger addedBricks = 0;

    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    IfLogicElseBrick *ifLogicElseBrick = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick.script = self.startScript;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    [self.startScript.brickList addObject:ifLogicElseBrick];
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    addedBricks++;
    
    IfLogicEndBrick *ifLogicEndBrick = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick.script = self.startScript;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    [self.startScript.brickList addObject:ifLogicEndBrick];
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addEmptyForeverLoop
{
    /*  Setup:
     
     0  foreverBegin
     1  foreverEnd
     */
    
    NSUInteger addedBricks = 0;
    
    ForeverBrick *foreverBrick = [[ForeverBrick alloc] init];
    foreverBrick.script = self.startScript;
    [self.startScript.brickList addObject:foreverBrick];
    addedBricks++;
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = self.startScript;
    loopEndBrick.loopBeginBrick = foreverBrick;
    [self.startScript.brickList addObject:loopEndBrick];
    foreverBrick.loopEndBrick = loopEndBrick;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addEmptyRepeatLoop
{
    /*  Setup:
     
     0  repeatBegin
     1  repeatEnd
     */
    
    NSUInteger addedBricks = 0;
    
    RepeatBrick *repeatBrick = [[RepeatBrick alloc] init];
    repeatBrick.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrick];
    addedBricks++;
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = self.startScript;
    loopEndBrick.loopBeginBrick = repeatBrick;
    [self.startScript.brickList addObject:loopEndBrick];
    repeatBrick.loopEndBrick = loopEndBrick;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricks
{
    /*  Setup:
     
     0  ifBeginA
     1      ifBeginB
     2          foreverBeginA
     3              waitA
     4          foreverEndA
     5      elseB
     6          foreverBeginB
     7              waitB
     8          foreverEndB
     9      ifEndB
     10  elseA
     11      ifBeginC
     12          foreverBeginC
     13              waitC
     14          foreverEndC
     15      elseC
     16          foreverBeginD
     17              waitD
     18          foreverEndD
     19      ifEndC
     20  endIfA
     
     */

    NSUInteger addedBricks = 0;

    
    // 1
    IfLogicBeginBrick *ifLogicBeginBrickA = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickA.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickA];
    addedBricks++;
    
    // 2
    IfLogicBeginBrick *ifLogicBeginBrickB = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickB.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickB];
    addedBricks++;
    
    // 3, 4, 5
    addedBricks += [self addForeverLoopWithWaitBrick];
    
    // 6
    IfLogicElseBrick *ifLogicElseBrickB = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickB.script = self.startScript;
    ifLogicElseBrickB.ifBeginBrick = ifLogicBeginBrickB;
    [self.startScript.brickList addObject:ifLogicElseBrickB];
    ifLogicBeginBrickB.ifElseBrick = ifLogicElseBrickB;
    addedBricks++;
    
    // 7, 8, 9
    addedBricks += [self addForeverLoopWithWaitBrick];
    
    //10
    IfLogicEndBrick *ifLogicEndBrickB = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickB.script = self.startScript;
    ifLogicEndBrickB.ifBeginBrick = ifLogicBeginBrickB;
    ifLogicEndBrickB.ifElseBrick = ifLogicElseBrickB;
    [self.startScript.brickList addObject:ifLogicEndBrickB];
    ifLogicBeginBrickB.ifEndBrick = ifLogicEndBrickB;
    ifLogicElseBrickB.ifEndBrick = ifLogicEndBrickB;
    addedBricks++;
    
    // 11
    IfLogicElseBrick *ifLogicElseBrickA = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickA.script = self.startScript;
    ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA;
    [self.startScript.brickList addObject:ifLogicElseBrickA];
    ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA;
    addedBricks++;
    
    // 12
    IfLogicBeginBrick *ifLogicBeginBrickC = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickC.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickC];
    addedBricks++;
    
    // 13, 14, 15
    addedBricks += [self addForeverLoopWithWaitBrick];
    
    // 16
    IfLogicElseBrick *ifLogicElseBrickC = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickC.script = self.startScript;
    ifLogicElseBrickC.ifBeginBrick = ifLogicBeginBrickC;
    [self.startScript.brickList addObject:ifLogicElseBrickC];
    ifLogicBeginBrickC.ifElseBrick = ifLogicElseBrickC;
    addedBricks++;
    
    // 17, 18, 19
    addedBricks += [self addForeverLoopWithWaitBrick];
    
    // 20
    IfLogicEndBrick *ifLogicEndBrickC = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickC.script = self.startScript;
    ifLogicEndBrickC.ifBeginBrick = ifLogicBeginBrickC;
    ifLogicEndBrickC.ifElseBrick = ifLogicElseBrickC;
    [self.startScript.brickList addObject:ifLogicEndBrickC];
    ifLogicBeginBrickC.ifEndBrick = ifLogicEndBrickC;
    ifLogicElseBrickC.ifEndBrick = ifLogicEndBrickC;
    addedBricks++;
    
    // 21
    IfLogicEndBrick *ifLogicEndBrickA = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickA.script = self.startScript;
    ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA;
    ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA;
    [self.startScript.brickList addObject:ifLogicEndBrickA];
    ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA;
    ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricks
{
    /*  Setup:
     
     0  ifBeginA
     1      ifBeginB
     2          repeatBeginA
     3              waitA
     4          repeatEndA
     5      elseB
     6          repeatBeginB
     7              waitB
     8          repeatEndB
     9      ifEndB
     10  elseA
     11      ifBeginC
     12          repeatBeginC
     13              waitC
     14          repeatEndC
     15      elseC
     16          repeatBeginD
     17              waitD
     18          repeatEndD
     19      ifEndC
     20  endIfA
     
     */
    
    NSUInteger addedBricks = 0;
    
    
    // 1
    IfLogicBeginBrick *ifLogicBeginBrickA = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickA.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickA];
    addedBricks++;
    
    // 2
    IfLogicBeginBrick *ifLogicBeginBrickB = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickB.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickB];
    addedBricks++;
    
    // 3, 4, 5
    addedBricks += [self addRepeatLoopWithWaitBrick];
    
    // 6
    IfLogicElseBrick *ifLogicElseBrickB = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickB.script = self.startScript;
    ifLogicElseBrickB.ifBeginBrick = ifLogicBeginBrickB;
    [self.startScript.brickList addObject:ifLogicElseBrickB];
    ifLogicBeginBrickB.ifElseBrick = ifLogicElseBrickB;
    addedBricks++;
    
    // 7, 8, 9
    addedBricks += [self addRepeatLoopWithWaitBrick];
    
    //10
    IfLogicEndBrick *ifLogicEndBrickB = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickB.script = self.startScript;
    ifLogicEndBrickB.ifBeginBrick = ifLogicBeginBrickB;
    ifLogicEndBrickB.ifElseBrick = ifLogicElseBrickB;
    [self.startScript.brickList addObject:ifLogicEndBrickB];
    ifLogicBeginBrickB.ifEndBrick = ifLogicEndBrickB;
    ifLogicElseBrickB.ifEndBrick = ifLogicEndBrickB;
    addedBricks++;
    
    // 11
    IfLogicElseBrick *ifLogicElseBrickA = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickA.script = self.startScript;
    ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA;
    [self.startScript.brickList addObject:ifLogicElseBrickA];
    ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA;
    addedBricks++;
    
    // 12
    IfLogicBeginBrick *ifLogicBeginBrickC = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickC.script = self.startScript;
    [self.startScript.brickList addObject:ifLogicBeginBrickC];
    addedBricks++;
    
    // 13, 14, 15
    addedBricks += [self addRepeatLoopWithWaitBrick];
    
    // 16
    IfLogicElseBrick *ifLogicElseBrickC = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickC.script = self.startScript;
    ifLogicElseBrickC.ifBeginBrick = ifLogicBeginBrickC;
    [self.startScript.brickList addObject:ifLogicElseBrickC];
    ifLogicBeginBrickC.ifElseBrick = ifLogicElseBrickC;
    addedBricks++;
    
    // 17, 18, 19
    addedBricks += [self addRepeatLoopWithWaitBrick];
    
    // 20
    IfLogicEndBrick *ifLogicEndBrickC = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickC.script = self.startScript;
    ifLogicEndBrickC.ifBeginBrick = ifLogicBeginBrickC;
    ifLogicEndBrickC.ifElseBrick = ifLogicElseBrickC;
    [self.startScript.brickList addObject:ifLogicEndBrickC];
    ifLogicBeginBrickC.ifEndBrick = ifLogicEndBrickC;
    ifLogicElseBrickC.ifEndBrick = ifLogicEndBrickC;
    addedBricks++;
    
    // 21
    IfLogicEndBrick *ifLogicEndBrickA = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickA.script = self.startScript;
    ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA;
    ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA;
    [self.startScript.brickList addObject:ifLogicEndBrickA];
    ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA;
    ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

-(NSUInteger)addNestedRepeatOrder3WithWaitInHighestLevel
{
    /*  Setup:
     
     0  reapeatBeginA
     1      repeatBeginB
     2          repeatBeginC
     3              waitA
     4          repeatEndC
     5      repeatEndB
     6  repeatEndA
     
     */
    
    NSUInteger addedBricks = 0;
    
    // 0
    RepeatBrick *repeatBrickA = [[RepeatBrick alloc] init];
    repeatBrickA.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrickA];
    addedBricks++;
    
    // 1
    RepeatBrick *repeatBrickB = [[RepeatBrick alloc] init];
    repeatBrickB.script = self.startScript;
    [self.startScript.brickList addObject:repeatBrickB];
    addedBricks++;
    
    // 2, 3, 4
    addedBricks += [self addRepeatLoopWithWaitBrick];
    
    // 5
    LoopEndBrick *loopEndBrickB = [[LoopEndBrick alloc] init];
    loopEndBrickB.script = self.startScript;
    loopEndBrickB.loopBeginBrick = repeatBrickB;
    [self.startScript.brickList addObject:loopEndBrickB];
    repeatBrickB.loopEndBrick = loopEndBrickB;
    addedBricks++;
    
    // 6
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = self.startScript;
    loopEndBrickA.loopBeginBrick = repeatBrickA;
    [self.startScript.brickList addObject:loopEndBrickA];
    repeatBrickA.loopEndBrick = loopEndBrickA;
    addedBricks++;
    
    return addedBricks;
}




@end
