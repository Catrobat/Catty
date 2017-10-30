/**
 *  Copyright (C) 2010-2018 The Catrobat Team
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
#import "SetXBrick.h"
#import "SetYBrick.h"
#import "PlaceAtBrick.h"

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
    self.whenScript = [[WhenScript alloc] init];
    self.whenScript.object = self.spriteObject;
    
    [self.spriteObject.scriptList addObject:self.startScript];
    
    XCTAssertEqual(1, [self.viewController.collectionView numberOfSections]);
    XCTAssertEqual(1, [self.viewController.collectionView numberOfItemsInSection:0]);
    
    [[BrickMoveManager sharedInstance] getReadyForNewBrickMovement];
}

- (NSUInteger)addForeverLoopWithWaitBrickToScript:(Script*)script
{

    /* Setup:
    
     0  foreverBeginA
     1      waitA
     2  foreverEndA
    */
    NSUInteger addedBricks = 0;

    ForeverBrick *foreverBrickA = [[ForeverBrick alloc] init];
    foreverBrickA.script = script;
    [script.brickList addObject:foreverBrickA];
    addedBricks++;
    
    WaitBrick *waitBrickA = [[WaitBrick alloc] init];
    [script.brickList addObject:waitBrickA];
    addedBricks++;
    
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = script;
    loopEndBrickA.loopBeginBrick = foreverBrickA;
    [script.brickList addObject:loopEndBrickA];
    foreverBrickA.loopEndBrick = loopEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addRepeatLoopWithWaitBrickToScript:(Script*)script
{
    
    /* Setup:
     
     0  foreverBeginA
     1      waitA
     2  foreverEndA
     */
    NSUInteger addedBricks = 0;
    
    RepeatBrick *repeatBrickA = [[RepeatBrick alloc] init];
    repeatBrickA.script = script;
    [script.brickList addObject:repeatBrickA];
    addedBricks++;
    
    WaitBrick *waitBrickA = [[WaitBrick alloc] init];
    [script.brickList addObject:waitBrickA];
    addedBricks++;
    
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = script;
    loopEndBrickA.loopBeginBrick = repeatBrickA;
    [script.brickList addObject:loopEndBrickA];
    repeatBrickA.loopEndBrick = loopEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addEmptyIfElseEndStructureToScript:(Script*)script
{
    /*  Setup:
     
     0  ifBegin
     1  else
     2  ifEnd
     */
    
    NSUInteger addedBricks = 0;

    IfLogicBeginBrick *ifLogicBeginBrick = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrick.script = script;
    [script.brickList addObject:ifLogicBeginBrick];
    addedBricks++;
    
    IfLogicElseBrick *ifLogicElseBrick = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrick.script = script;
    ifLogicElseBrick.ifBeginBrick = ifLogicBeginBrick;
    [script.brickList addObject:ifLogicElseBrick];
    ifLogicBeginBrick.ifElseBrick = ifLogicElseBrick;
    addedBricks++;
    
    IfLogicEndBrick *ifLogicEndBrick = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrick.script = script;
    ifLogicEndBrick.ifBeginBrick = ifLogicBeginBrick;
    ifLogicEndBrick.ifElseBrick = ifLogicElseBrick;
    [script.brickList addObject:ifLogicEndBrick];
    ifLogicBeginBrick.ifEndBrick = ifLogicEndBrick;
    ifLogicElseBrick.ifEndBrick = ifLogicEndBrick;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addEmptyForeverLoopToScript:(Script*)script
{
    /*  Setup:
     
     0  foreverBegin
     1  foreverEnd
     */
    
    NSUInteger addedBricks = 0;
    
    ForeverBrick *foreverBrick = [[ForeverBrick alloc] init];
    foreverBrick.script = script;
    [script.brickList addObject:foreverBrick];
    addedBricks++;
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = script;
    loopEndBrick.loopBeginBrick = foreverBrick;
    [script.brickList addObject:loopEndBrick];
    foreverBrick.loopEndBrick = loopEndBrick;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addEmptyRepeatLoopToScript:(Script*)script
{
    /*  Setup:
     
     0  repeatBegin
     1  repeatEnd
     */
    
    NSUInteger addedBricks = 0;
    
    RepeatBrick *repeatBrick = [[RepeatBrick alloc] init];
    repeatBrick.script = script;
    [script.brickList addObject:repeatBrick];
    addedBricks++;
    
    LoopEndBrick *loopEndBrick = [[LoopEndBrick alloc] init];
    loopEndBrick.script = script;
    loopEndBrick.loopBeginBrick = repeatBrick;
    [script.brickList addObject:loopEndBrick];
    repeatBrick.loopEndBrick = loopEndBrick;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addNestedIfElseOfOrder1WithForeverLoopsWithWaitBricksToScript:(Script*)script
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
    ifLogicBeginBrickA.script = script;
    [script.brickList addObject:ifLogicBeginBrickA];
    addedBricks++;
    
    // 2
    IfLogicBeginBrick *ifLogicBeginBrickB = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickB.script = script;
    [script.brickList addObject:ifLogicBeginBrickB];
    addedBricks++;
    
    // 3, 4, 5
    addedBricks += [self addForeverLoopWithWaitBrickToScript:script];
    
    // 6
    IfLogicElseBrick *ifLogicElseBrickB = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickB.script = script;
    ifLogicElseBrickB.ifBeginBrick = ifLogicBeginBrickB;
    [script.brickList addObject:ifLogicElseBrickB];
    ifLogicBeginBrickB.ifElseBrick = ifLogicElseBrickB;
    addedBricks++;
    
    // 7, 8, 9
    addedBricks += [self addForeverLoopWithWaitBrickToScript:script];
    
    //10
    IfLogicEndBrick *ifLogicEndBrickB = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickB.script = script;
    ifLogicEndBrickB.ifBeginBrick = ifLogicBeginBrickB;
    ifLogicEndBrickB.ifElseBrick = ifLogicElseBrickB;
    [script.brickList addObject:ifLogicEndBrickB];
    ifLogicBeginBrickB.ifEndBrick = ifLogicEndBrickB;
    ifLogicElseBrickB.ifEndBrick = ifLogicEndBrickB;
    addedBricks++;
    
    // 11
    IfLogicElseBrick *ifLogicElseBrickA = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickA.script = script;
    ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA;
    [script.brickList addObject:ifLogicElseBrickA];
    ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA;
    addedBricks++;
    
    // 12
    IfLogicBeginBrick *ifLogicBeginBrickC = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickC.script = script;
    [script.brickList addObject:ifLogicBeginBrickC];
    addedBricks++;
    
    // 13, 14, 15
    addedBricks += [self addForeverLoopWithWaitBrickToScript:script];
    
    // 16
    IfLogicElseBrick *ifLogicElseBrickC = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickC.script = script;
    ifLogicElseBrickC.ifBeginBrick = ifLogicBeginBrickC;
    [script.brickList addObject:ifLogicElseBrickC];
    ifLogicBeginBrickC.ifElseBrick = ifLogicElseBrickC;
    addedBricks++;
    
    // 17, 18, 19
    addedBricks += [self addForeverLoopWithWaitBrickToScript:script];
    
    // 20
    IfLogicEndBrick *ifLogicEndBrickC = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickC.script = script;
    ifLogicEndBrickC.ifBeginBrick = ifLogicBeginBrickC;
    ifLogicEndBrickC.ifElseBrick = ifLogicElseBrickC;
    [script.brickList addObject:ifLogicEndBrickC];
    ifLogicBeginBrickC.ifEndBrick = ifLogicEndBrickC;
    ifLogicElseBrickC.ifEndBrick = ifLogicEndBrickC;
    addedBricks++;
    
    // 21
    IfLogicEndBrick *ifLogicEndBrickA = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickA.script = script;
    ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA;
    ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA;
    [script.brickList addObject:ifLogicEndBrickA];
    ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA;
    ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

- (NSUInteger)addNestedIfElseOfOrder1WithRepeatLoopsWithWaitBricksToScript:(Script*)script
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
    ifLogicBeginBrickA.script = script;
    [script.brickList addObject:ifLogicBeginBrickA];
    addedBricks++;
    
    // 2
    IfLogicBeginBrick *ifLogicBeginBrickB = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickB.script = script;
    [script.brickList addObject:ifLogicBeginBrickB];
    addedBricks++;
    
    // 3, 4, 5
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:script];
    
    // 6
    IfLogicElseBrick *ifLogicElseBrickB = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickB.script = script;
    ifLogicElseBrickB.ifBeginBrick = ifLogicBeginBrickB;
    [script.brickList addObject:ifLogicElseBrickB];
    ifLogicBeginBrickB.ifElseBrick = ifLogicElseBrickB;
    addedBricks++;
    
    // 7, 8, 9
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:script];
    
    //10
    IfLogicEndBrick *ifLogicEndBrickB = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickB.script = script;
    ifLogicEndBrickB.ifBeginBrick = ifLogicBeginBrickB;
    ifLogicEndBrickB.ifElseBrick = ifLogicElseBrickB;
    [script.brickList addObject:ifLogicEndBrickB];
    ifLogicBeginBrickB.ifEndBrick = ifLogicEndBrickB;
    ifLogicElseBrickB.ifEndBrick = ifLogicEndBrickB;
    addedBricks++;
    
    // 11
    IfLogicElseBrick *ifLogicElseBrickA = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickA.script = script;
    ifLogicElseBrickA.ifBeginBrick = ifLogicBeginBrickA;
    [script.brickList addObject:ifLogicElseBrickA];
    ifLogicBeginBrickA.ifElseBrick = ifLogicElseBrickA;
    addedBricks++;
    
    // 12
    IfLogicBeginBrick *ifLogicBeginBrickC = [[IfLogicBeginBrick alloc] init];
    ifLogicBeginBrickC.script = script;
    [script.brickList addObject:ifLogicBeginBrickC];
    addedBricks++;
    
    // 13, 14, 15
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:script];
    
    // 16
    IfLogicElseBrick *ifLogicElseBrickC = [[IfLogicElseBrick alloc] init];
    ifLogicElseBrickC.script = script;
    ifLogicElseBrickC.ifBeginBrick = ifLogicBeginBrickC;
    [script.brickList addObject:ifLogicElseBrickC];
    ifLogicBeginBrickC.ifElseBrick = ifLogicElseBrickC;
    addedBricks++;
    
    // 17, 18, 19
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:script];
    
    // 20
    IfLogicEndBrick *ifLogicEndBrickC = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickC.script = script;
    ifLogicEndBrickC.ifBeginBrick = ifLogicBeginBrickC;
    ifLogicEndBrickC.ifElseBrick = ifLogicElseBrickC;
    [script.brickList addObject:ifLogicEndBrickC];
    ifLogicBeginBrickC.ifEndBrick = ifLogicEndBrickC;
    ifLogicElseBrickC.ifEndBrick = ifLogicEndBrickC;
    addedBricks++;
    
    // 21
    IfLogicEndBrick *ifLogicEndBrickA = [[IfLogicEndBrick alloc] init];
    ifLogicEndBrickA.script = script;
    ifLogicEndBrickA.ifBeginBrick = ifLogicBeginBrickA;
    ifLogicEndBrickA.ifElseBrick = ifLogicElseBrickA;
    [script.brickList addObject:ifLogicEndBrickA];
    ifLogicBeginBrickA.ifEndBrick = ifLogicEndBrickA;
    ifLogicElseBrickA.ifEndBrick = ifLogicEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

-(NSUInteger)addNestedRepeatOrder3WithWaitInHighestLevelToScript:(Script*)script
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
    repeatBrickA.script = script;
    [script.brickList addObject:repeatBrickA];
    addedBricks++;
    
    // 1
    RepeatBrick *repeatBrickB = [[RepeatBrick alloc] init];
    repeatBrickB.script = script;
    [script.brickList addObject:repeatBrickB];
    addedBricks++;
    
    // 2, 3, 4
    addedBricks += [self addRepeatLoopWithWaitBrickToScript:script];
    
    // 5
    LoopEndBrick *loopEndBrickB = [[LoopEndBrick alloc] init];
    loopEndBrickB.script = script;
    loopEndBrickB.loopBeginBrick = repeatBrickB;
    [script.brickList addObject:loopEndBrickB];
    repeatBrickB.loopEndBrick = loopEndBrickB;
    addedBricks++;
    
    // 6
    LoopEndBrick *loopEndBrickA = [[LoopEndBrick alloc] init];
    loopEndBrickA.script = script;
    loopEndBrickA.loopBeginBrick = repeatBrickA;
    [script.brickList addObject:loopEndBrickA];
    repeatBrickA.loopEndBrick = loopEndBrickA;
    addedBricks++;
    
    return addedBricks;
}

-(NSUInteger)addWaitSetXSetYWaitPlaceAtWaitBricksToScript:(Script*)script
{
    /*  Setup:
     
     0  waitBrickA
     1  setXBrickA
     2  setYBrickA
     3  waitBrickB
     4  placeAtXYA
     5  waitBrickC
     
     */
    
    NSUInteger addedBricks = 0;

    // 0
    WaitBrick *waitBrickA = [[WaitBrick alloc] init];
    [script.brickList addObject:waitBrickA];
    addedBricks++;
    
    // 1
    Formula *position = [[Formula alloc] init];
    FormulaElement *formulaTree = [[FormulaElement alloc] init];
    formulaTree.type = NUMBER;
    formulaTree.value = @"20";
    position.formulaTree = formulaTree;
    
    SetXBrick *setXBrickA = [[SetXBrick alloc] init];
    setXBrickA.script = script;
    setXBrickA.xPosition = position;
    [script.brickList addObject:setXBrickA];
    addedBricks++;
    
    // 2
    SetYBrick *setYBrickA = [[SetYBrick alloc] init];
    setYBrickA.script = script;
    setYBrickA.yPosition = position;
    [script.brickList addObject:setYBrickA];
    addedBricks++;

    // 3
    WaitBrick *waitBrickB = [[WaitBrick alloc] init];
    [script.brickList addObject:waitBrickB];
    addedBricks++;
    
    // 4
    Formula* yPosition =[[Formula alloc] init];
    FormulaElement* formulaTree0  = [[FormulaElement alloc] init];
    formulaTree0.type = NUMBER;
    formulaTree0.value = @"20";
    yPosition.formulaTree = formulaTree0;
    
    Formula* xPosition =[[Formula alloc] init];
    FormulaElement* formulaTree1  = [[FormulaElement alloc] init];
    formulaTree1.type = NUMBER;
    formulaTree1.value = @"20";
    xPosition.formulaTree = formulaTree1;
    
    PlaceAtBrick* placeAtXYA = [[PlaceAtBrick alloc]init];
    placeAtXYA.script = script;
    placeAtXYA.yPosition = yPosition;
    placeAtXYA.xPosition = xPosition;
    [script.brickList addObject:placeAtXYA];
    addedBricks++;
    
    // 5
    WaitBrick *waitBrickC = [[WaitBrick alloc] init];
    [script.brickList addObject:waitBrickC];
    addedBricks++;
    

    return addedBricks;
}


@end
