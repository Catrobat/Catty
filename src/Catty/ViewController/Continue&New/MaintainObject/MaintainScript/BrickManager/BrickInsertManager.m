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

#import "BrickInsertManager.h"
#import "Script.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "LoopEndBrick.h"
#import "ForeverBrick.h"
#import "BrickCell.h"

@interface BrickInsertManager()

@property (nonatomic, assign) BOOL moveToOtherScript;
@property (nonatomic, assign) BOOL insertionMode;
@property (nonatomic, assign) BOOL moveMode;

@end

@implementation BrickInsertManager

+ (id)sharedInstance {
    static BrickInsertManager *sharedBrickInsertManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBrickInsertManager = [[self alloc] init];
        [sharedBrickInsertManager reset];
        sharedBrickInsertManager.isInsertingScript = NO;
    });
    return sharedBrickInsertManager;
}

- (BOOL)isBrickInsertionMode{
    return self.insertionMode;
}
- (BOOL)isBrickMoveMode{
    return self.moveMode;
}

- (void)setBrickInsertionMode:(BOOL)isInserting{
    self.insertionMode = isInserting;
}

- (void)setBrickMoveMode:(BOOL)isMoving{
    self.moveMode = isMoving;
}
#pragma mark - check insert logic
- (BOOL)collectionView:(UICollectionView*)collectionView itemAtIndexPath:(NSIndexPath*)fromIndexPath
    canInsertToIndexPath:(NSIndexPath*)toIndexPath andObject:(SpriteObject*)object
{
    Script *fromScript = [object.scriptList objectAtIndex:fromIndexPath.section];
    if (fromIndexPath.item == 0 && toIndexPath.item ==0 && self.isInsertingScript) {
        return YES;
    }else if (fromIndexPath.item == 0 && toIndexPath.item !=0 && self.isInsertingScript){
        return NO;
    }
    Brick *fromBrick;
    if (fromIndexPath.item <= 0) {
        fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item];
    } else {
        fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
    }
    
    
    if (fromBrick.isAnimatedInsertBrick) {
        if (toIndexPath.item != 0) {
            Script *script;
            if (self.moveToOtherScript) {
                script = [object.scriptList objectAtIndex:toIndexPath.section];
            }else{
                script = [object.scriptList objectAtIndex:fromIndexPath.section];
            }
            Brick *toBrick;
            if (script.brickList.count > toIndexPath.item - 1) {
                toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            } else {
                return NO;
            }
            if ([toBrick isKindOfClass:[LoopEndBrick class]]) {
                LoopEndBrick* loopEndBrick = (LoopEndBrick*)toBrick;
                if ([loopEndBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                    if (script.brickList.count >=1 && ![fromBrick isKindOfClass:[LoopEndBrick class]]) {
                        NSInteger index = script.brickList.count;
                        while ([[script.brickList objectAtIndex:index-1] isKindOfClass:[LoopEndBrick class]]) {
                            LoopEndBrick* loopEndBrickCheck = (LoopEndBrick*)[script.brickList objectAtIndex:index-1];
                            if (loopEndBrick  == loopEndBrickCheck) {
                                return NO;
                            }
                            index--;
                        }
                        //from above
                        if (toIndexPath.item > fromIndexPath.item) {
                            Brick *checkafterEndBrick = [script.brickList objectAtIndex:toIndexPath.item];
                            if ([checkafterEndBrick isKindOfClass:[IfLogicElseBrick class]] ||[checkafterEndBrick isKindOfClass:[IfLogicEndBrick class]]) {
                                return NO;
                            } else if ([checkafterEndBrick isKindOfClass:[LoopEndBrick class]]){
                                LoopEndBrick *endBrickCheck = (LoopEndBrick*)checkafterEndBrick;
                                if (![endBrickCheck.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                                    return NO;
                                }
                            }
                            
                        }
                        return YES;
                    }
                    return NO;
                }
            }
            //From Below
                if (toIndexPath.item < fromIndexPath.item) {
                    if ([toBrick isKindOfClass:[IfLogicElseBrick class]]||[toBrick isKindOfClass:[IfLogicEndBrick class]]||[toBrick isKindOfClass:[LoopEndBrick class]]) { //check if repeat?!
                        Brick *checkBeforeEndBrick = [script.brickList objectAtIndex:toIndexPath.item - 2];
                        if ([checkBeforeEndBrick isKindOfClass:[LoopEndBrick class]]) {
                            return NO;
                        }
                    }
                    
                }
                
                return (toIndexPath.item != 0);
        } else {
            BrickCell *brickCell = (BrickCell*)[collectionView cellForItemAtIndexPath:toIndexPath];
            self.moveToOtherScript = YES;
            if ([brickCell.scriptOrBrick isKindOfClass:[Script class]]) {
                Script *script = (Script*)brickCell.scriptOrBrick;
                if (script.brickList.count == 0) {
                    return YES;
                } else {
                    return NO;
                }
            }
            return NO;
        }
    }
    
    return NO;
}

#pragma mark - Insert Brick Logic
-(void)insertBrick:(Brick*)brick IndexPath:(NSIndexPath*)path andObject:(SpriteObject*)object
{
    Script *targetScript = object.scriptList[path.section];
    brick.script = targetScript;
    NSInteger insertionIndex = path.row;
//    NSInteger check = [self checkForeverLoopEndBrickWithStartingIndex:insertionIndex andScript:targetScript];
//    if (check != -1) {
//        insertionIndex = check - 1;
//    }
    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
        //ELSE&END ALWAYS right after IFBEGIN
//        NSInteger insertionIndex = path.row;
        IfLogicBeginBrick *ifBeginBrick = (IfLogicBeginBrick*)brick;
        IfLogicElseBrick *ifElseBrick = [IfLogicElseBrick new];
        IfLogicEndBrick *ifEndBrick = [IfLogicEndBrick new];
        ifBeginBrick.ifElseBrick = ifElseBrick;
        ifBeginBrick.ifEndBrick = ifEndBrick;
        ifElseBrick.ifBeginBrick = ifBeginBrick;
        ifElseBrick.ifEndBrick = ifEndBrick;
        ifEndBrick.ifBeginBrick = ifBeginBrick;
        ifEndBrick.ifElseBrick = ifElseBrick;
        ifElseBrick.script = targetScript;
        ifEndBrick.script = targetScript;
        [targetScript.brickList insertObject:ifEndBrick atIndex:insertionIndex==0?1:insertionIndex];
        [targetScript.brickList insertObject:ifElseBrick atIndex:insertionIndex==0?1:insertionIndex];
    } else if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)brick;
        LoopEndBrick *loopEndBrick = [LoopEndBrick new];
        loopBeginBrick.loopEndBrick = loopEndBrick;
        loopEndBrick.loopBeginBrick = loopBeginBrick;
        loopEndBrick.script = targetScript;
        //REPEAT END just after Repeat BEGIN
        if ([loopBeginBrick isKindOfClass:[ForeverBrick class]]) { // FOREVER END always last possible position (NESTED!!)
            NSInteger index = loopBeginBrick.script.brickList.count;
            insertionIndex = index;
            if (targetScript.brickList.count >=1) {
                while ([[targetScript.brickList objectAtIndex:index-1] isKindOfClass:[LoopEndBrick class]]) {
                    LoopEndBrick *loopEndBrickCheck = (LoopEndBrick*)[targetScript.brickList objectAtIndex:index-1];
                    NSInteger loopbeginIndex = 0;
                    for (Brick *brick in targetScript.brickList) {
                        if (brick  == loopEndBrickCheck.loopBeginBrick) {
                            break;
                        }
                        loopbeginIndex++;
                    }
                    if (loopbeginIndex < path.row) {
                        insertionIndex = index-1;
                    } else if(loopbeginIndex > path.row){
                        insertionIndex = index;
                    }else{
                        //should not be possible
                        insertionIndex = index;
                        break;
                    }
                    index--;
                }
                Brick* foreverInsideBrick = [self checkForeverBrickInsideLogicBricks:targetScript andIndexPath:path];
                if (foreverInsideBrick) {
                    if ([foreverInsideBrick isKindOfClass:[IfLogicBeginBrick class]]) {
                        IfLogicBeginBrick* logicBeginBrick = (IfLogicBeginBrick*) foreverInsideBrick;
                        NSInteger counter = 0;
                        for (Brick* checkBrick in targetScript.brickList) {
                            if ([checkBrick isKindOfClass:[IfLogicElseBrick class]]) {
                                if (checkBrick == logicBeginBrick.ifElseBrick) {
                                    insertionIndex = counter;
                                }
                            }
                            counter++;
                        }
                    } else if ([foreverInsideBrick isKindOfClass:[IfLogicElseBrick class]]){
                        IfLogicElseBrick* logicBeginBrick = (IfLogicElseBrick*) foreverInsideBrick;
                        NSInteger counter = 0;
                        for (Brick* checkBrick in targetScript.brickList) {
                            if ([checkBrick isKindOfClass:[IfLogicEndBrick class]]) {
                                if (checkBrick == logicBeginBrick.ifEndBrick) {
                                    insertionIndex = counter;
                                }
                            }
                            counter++;
                        }
                    }
                }
                if (!foreverInsideBrick) {
                    foreverInsideBrick = [self checkForeverBrickInsideRepeatBricks:targetScript andIndexPath:path];
                    if (foreverInsideBrick) {
                        if ([foreverInsideBrick isKindOfClass:[LoopBeginBrick class]]) {
                            LoopBeginBrick* loopBeginBrick = (LoopBeginBrick*) foreverInsideBrick;
                            NSInteger counter = 0;
                            for (Brick* checkBrick in targetScript.brickList) {
                                if ([checkBrick isKindOfClass:[LoopEndBrick class]]) {
                                    if (checkBrick == loopBeginBrick.loopEndBrick) {
                                        insertionIndex = counter;
                                    }
                                }
                                counter++;
                            }
                        }
                    }

                }
            }
        }
        [targetScript.brickList insertObject:loopEndBrick atIndex:insertionIndex==0?1:insertionIndex];
    }
    brick.animateInsertBrick = NO;
    [object.program saveToDiskWithNotification:YES];
}

-(Brick*)checkForeverBrickInsideLogicBricks:(Script*)targetScript andIndexPath:(NSIndexPath*)path
{
    Brick* checkBrick;
    for (NSInteger counter = 0;counter<path.row;counter++) {
        Brick *brick = [targetScript.brickList objectAtIndex:counter];
        if (([brick isKindOfClass:[IfLogicBeginBrick class]])) {
            checkBrick = brick;
        } else if ([brick isKindOfClass:[IfLogicElseBrick class]]){
            checkBrick = brick;
        } else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
            checkBrick  = nil;
        }
    }
    return checkBrick;
}

-(Brick*)checkForeverBrickInsideRepeatBricks:(Script*)targetScript andIndexPath:(NSIndexPath*)path
{
    Brick* checkBrick;
    for (NSInteger counter = 0;counter<path.row;counter++) {
        Brick *brick = [targetScript.brickList objectAtIndex:counter];
        if (([brick isKindOfClass:[LoopBeginBrick class]]&&(![brick isKindOfClass:[ForeverBrick class]]))) {
            checkBrick = brick;
        }
        if ([brick isKindOfClass:[LoopEndBrick class]]) {
            LoopEndBrick* endBrick = (LoopEndBrick*)brick;
            if (![endBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                checkBrick = nil;
            }
        }
    }
    return checkBrick;
}

-(NSInteger)checkForeverLoopEndBrickWithStartingIndex:(NSInteger)counter andScript:(Script*)script
{
    //Check if there is a Forever Loop End-brick
    while (counter >= 1) {
        if ([[script.brickList objectAtIndex:counter-1] isKindOfClass:[LoopEndBrick class]]) {
            LoopEndBrick *brick = (LoopEndBrick*)[script.brickList objectAtIndex:counter-1];
            if ([brick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                return counter;
            }
        }
        counter--;
    }
    return -1;
}



-(void)reset
{
    self.moveToOtherScript = NO;
    self.insertionMode = NO;
    self.moveMode = NO;
}

@end
