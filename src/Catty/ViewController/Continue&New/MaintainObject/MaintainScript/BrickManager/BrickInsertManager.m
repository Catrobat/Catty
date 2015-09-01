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

@end

@implementation BrickInsertManager

+ (id)sharedInstance {
    static BrickInsertManager *sharedBrickInsertManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBrickInsertManager = [[self alloc] init];
    });
    return sharedBrickInsertManager;
}

#pragma mark - check insert logic
- (BOOL)collectionView:(UICollectionView*)collectionView itemAtIndexPath:(NSIndexPath*)fromIndexPath
    canInsertToIndexPath:(NSIndexPath*)toIndexPath andObject:(SpriteObject*)object
{
    Script *fromScript = [object.scriptList objectAtIndex:fromIndexPath.section];
    Brick *fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
    
    if (fromBrick.isAnimatedInsertBrick) {
        if (toIndexPath.item != 0) {
            Script *script;
            if (self.moveToOtherScript) {
                script = [object.scriptList objectAtIndex:toIndexPath.section];
            }else{
                script = [object.scriptList objectAtIndex:fromIndexPath.section];
            }
            Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            if ([toBrick isKindOfClass:[LoopEndBrick class]]) {
                LoopEndBrick* loopEndBrick = (LoopEndBrick*) toBrick;
                if ([loopEndBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                    NSInteger counter = fromScript.brickList.count;
                    while ([[fromScript.brickList objectAtIndex:counter-1] isKindOfClass:[LoopEndBrick class]]) {
                        counter--;
                    }
                    if (toIndexPath.item < counter) {
                        return YES;
                    }
                    return NO;
                }
            }

            return YES;
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
    NSInteger check = [self checkForeverLoopEndBrickWithStartingIndex:insertionIndex andScript:targetScript];
    if (check != -1) {
        insertionIndex = check - 1;
    }
    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
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
        ifElseBrick.animate = YES;
        ifEndBrick.animate = YES;
        [targetScript.brickList insertObject:ifEndBrick atIndex:insertionIndex];
        [targetScript.brickList insertObject:ifElseBrick atIndex:insertionIndex];
    } else if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *loopBeginBrick = (LoopBeginBrick*)brick;
        LoopEndBrick *loopEndBrick = [LoopEndBrick new];
        loopBeginBrick.loopEndBrick = loopEndBrick;
        loopEndBrick.loopBeginBrick = loopBeginBrick;
        loopEndBrick.script = targetScript;
        loopEndBrick.animate = YES;
        if ([loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
            NSInteger index = loopBeginBrick.script.brickList.count;
            insertionIndex = index;
            if (targetScript.brickList.count >=1) {
                while ([[targetScript.brickList objectAtIndex:index-1] isKindOfClass:[LoopEndBrick class]]) {
                    LoopEndBrick* loopEndBrickCheck = [targetScript.brickList objectAtIndex:index-1];
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
                    }
                    index--;
                }
                if ([self checkForeverBrickInsideLogicBricks:targetScript andIndexPath:path]) {
                    insertionIndex = path.row;
                }
                if ([self checkForeverBrickInsideRepeatBricks:targetScript andIndexPath:path]) {
                    insertionIndex = path.row;
                }
            }
        }
        [targetScript.brickList insertObject:loopEndBrick atIndex:insertionIndex];
        
    }
    brick.animateInsertBrick = NO;
    [object.program saveToDisk];
}

-(BOOL)checkForeverBrickInsideLogicBricks:(Script*)targetScript andIndexPath:(NSIndexPath*)path
{
    NSInteger logicBrickCounter = 0;
    for (NSInteger counter = 0;counter<path.row;counter++) {
        Brick *brick = [targetScript.brickList objectAtIndex:counter];
        if (([brick isKindOfClass:[IfLogicBeginBrick class]]||[brick isKindOfClass:[IfLogicElseBrick class]])) {
            logicBrickCounter++;
        }
        if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
            logicBrickCounter -= 2;
        }
    }
    if (logicBrickCounter != 0) {
        switch (logicBrickCounter) {
            case 1:
            case 2:
                return YES;
                break;
            default:
                break;
        }
    }
    return NO;
}

-(BOOL)checkForeverBrickInsideRepeatBricks:(Script*)targetScript andIndexPath:(NSIndexPath*)path
{
    NSInteger repeatBrickCounter = 0;
    for (NSInteger counter = 0;counter<path.row;counter++) {
        Brick *brick = [targetScript.brickList objectAtIndex:counter];
        if (([brick isKindOfClass:[LoopBeginBrick class]]&&(![brick isKindOfClass:[ForeverBrick class]]))) {
            repeatBrickCounter++;
        }
        if ([brick isKindOfClass:[LoopEndBrick class]]) {
            LoopEndBrick* endBrick = (LoopEndBrick*)brick;
            if (![endBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                repeatBrickCounter -= 1;
            }
        }
    }
    if (repeatBrickCounter != 0) {
        switch (repeatBrickCounter) {
            case 1:
                return YES;
                break;
            default:
                break;
        }
    }
    return NO;
}

-(NSInteger)checkForeverLoopEndBrickWithStartingIndex:(NSInteger)counter andScript:(Script*)script
{
    //Check if there is a Forever Loop End-brick
    while (counter >= 1) {
        if ([[script.brickList objectAtIndex:counter-1] isKindOfClass:[LoopEndBrick class]]) {
            LoopEndBrick *brick =[script.brickList objectAtIndex:counter-1];
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
}

@end
