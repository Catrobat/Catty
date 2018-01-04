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

#import "BrickMoveManager.h"
#import "Script.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "ForeverBrick.h"

@interface BrickMoveManager()

@property (nonatomic, strong) NSIndexPath *higherRankBrick;
@property (nonatomic, strong) NSIndexPath *lowerRankBrick;
@property (nonatomic, assign) BOOL moveToOtherScript;

@end

@implementation BrickMoveManager

+ (id)sharedInstance {
    static BrickMoveManager *sharedBrickMoveManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedBrickMoveManager = [[self alloc] init];
        [sharedBrickMoveManager getReadyForNewBrickMovement];
    });
    return sharedBrickMoveManager;
}



- (BOOL)collectionView:(UICollectionView*)collectionView itemAtIndexPath:(NSIndexPath*)fromIndexPath
    canMoveToIndexPath:(NSIndexPath*)toIndexPath andObject:(SpriteObject*)object
{
    Script *fromScript = [object.scriptList objectAtIndex:fromIndexPath.section];
    Brick *fromBrick;
    if (fromIndexPath.item == 0) {
        fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item];
    } else{
        fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
    }
    
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
            LoopEndBrick* loopEndBrick = (LoopEndBrick*) toBrick;
            if ([loopEndBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                return [self handleMovementToForeverBrick:loopEndBrick fromIndexPath:fromIndexPath toIndexPath:toIndexPath fromBrick:fromBrick andScript:script];
            }
        }
        if ([fromBrick isKindOfClass:[LoopBeginBrick class]] || [fromBrick isKindOfClass:[LoopEndBrick class]] || [fromBrick isKindOfClass:[IfLogicBeginBrick class]] || [fromBrick isKindOfClass:[IfLogicElseBrick class]] || [fromBrick isKindOfClass:[IfLogicEndBrick class]]){
            return [self checkNestedBrickToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick andObject:object];
        } else {
            //From Below
            if (toIndexPath.item < fromIndexPath.item) {
                if ([toBrick isKindOfClass:[IfLogicElseBrick class]]||[toBrick isKindOfClass:[IfLogicEndBrick class]]||[toBrick isKindOfClass:[LoopEndBrick class]]) { //check if repeat?!
                    Brick *checkBeforeEndBrick = [script.brickList objectAtIndex:toIndexPath.item - 2];
                    if ([checkBeforeEndBrick isKindOfClass:[LoopEndBrick class]]) {
                        LoopEndBrick *endBrick = (LoopEndBrick*)checkBeforeEndBrick;
                        if ([endBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
                            return NO;
                        }
                    }
                }

            }
            
            return (toIndexPath.item != 0);
        }
    } else {
        return [self handleMovementToOtherScriptwithIndexPath:toIndexPath fromBrick:fromBrick andObject:object];
    }
}

#pragma mark - check move logic

-(BOOL)checkMoveToForeverLoopEndBrickfromBrick:(Brick*)fromBrick fromIndexPath:(NSIndexPath*)fromIndexPath andToIndexPath:(NSIndexPath*)toIndexPath
{
    if ([fromBrick isKindOfClass:[IfLogicBeginBrick class]]||[fromBrick isKindOfClass:[IfLogicElseBrick class]]||[fromBrick isKindOfClass:[IfLogicEndBrick class]]||[fromBrick isKindOfClass:[LoopEndBrick class]]||[fromBrick isKindOfClass:[LoopBeginBrick class]]) {
        if (toIndexPath.item < fromIndexPath.item) {
            self.higherRankBrick = toIndexPath;
        } else {
            self.lowerRankBrick = toIndexPath;
        }

        return NO;
    }
    return YES;
}

-(BOOL)handleMovementToOtherScriptwithIndexPath:(NSIndexPath*)toIndexPath fromBrick:(Brick*)brick andObject:(SpriteObject*)object
{
    if ([brick isKindOfClass:[IfLogicBeginBrick class]] || [brick isKindOfClass:[IfLogicElseBrick class]] || [brick isKindOfClass:[IfLogicEndBrick class]] || [brick isKindOfClass:[LoopBeginBrick class]] || [brick isKindOfClass:[LoopEndBrick class]]) {
        return NO;
    }
    Script *toScript = [object.scriptList objectAtIndex:toIndexPath.section];
    self.moveToOtherScript = YES;
    if ([toScript.brickList count] == 0) {
        return YES;
    } else {
        return NO;
    }
    
}

-(BOOL)handleMovementToForeverBrick:(LoopEndBrick*)loopEndBrick fromIndexPath:(NSIndexPath*)fromIndexPath toIndexPath:(NSIndexPath*)toIndexPath fromBrick:(Brick*)fromBrick andScript:(Script*)script
{
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
        if (![self checkMoveToForeverLoopEndBrickfromBrick:fromBrick fromIndexPath:fromIndexPath andToIndexPath:toIndexPath]) {
            return NO;
        }
        return YES;
    }
    return NO;
 
}


- (BOOL)checkNestedBrickToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick andObject:(SpriteObject*)object
{
    if ([fromBrick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *endBrick = (LoopEndBrick*)fromBrick;
        if ([endBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
            return NO;
        }
    }
    if (fromIndexPath.section == toIndexPath.section) {
        if (toIndexPath.item < fromIndexPath.item) {
            if (self.upperBorder == nil) {
                Script *toScript = [object.scriptList objectAtIndex:toIndexPath.section];
                Brick *toBrick = [toScript.brickList objectAtIndex:toIndexPath.item - 1];
                if([toBrick isKindOfClass:[LoopBeginBrick class]] || [toBrick isKindOfClass:[LoopEndBrick class]] || [toBrick isKindOfClass:[IfLogicBeginBrick class]] || [toBrick isKindOfClass:[IfLogicElseBrick class]] || [toBrick isKindOfClass:[IfLogicEndBrick class]]) {
                    self.upperBorder = toIndexPath;
                    return NO;
                } else {
                    return YES;
                }
            } else if (self.upperBorder.item > toIndexPath.item){
                return NO;
            } else if (self.upperBorder.item < toIndexPath.item){
                return YES;
            }
        } else {
            if (self.lowerBorder == nil) {
                Script *toScript = [object.scriptList objectAtIndex:toIndexPath.section];
                Brick *toBrick = [toScript.brickList objectAtIndex:toIndexPath.item - 1];
                if([toBrick isKindOfClass:[LoopBeginBrick class]] || [toBrick isKindOfClass:[LoopEndBrick class]] || [toBrick isKindOfClass:[IfLogicBeginBrick class]] || [toBrick isKindOfClass:[IfLogicElseBrick class]] || [toBrick isKindOfClass:[IfLogicEndBrick class]]) {
                    self.lowerBorder = toIndexPath;
                    return NO;
                } else {
                    return YES;
                }
            } else if (self.lowerBorder.item > toIndexPath.item){
                return YES;
            } else if (self.lowerBorder.item < toIndexPath.item){
                return NO;
            }
        }
    }
    return NO;
}

-(void)getReadyForNewBrickMovement
{
    self.upperBorder = nil;
    self.lowerBorder = nil;
    [self reset];
}


-(void)reset
{
    NSLog(@"reset");

    self.higherRankBrick = nil;
    self.lowerRankBrick = nil;
    self.moveToOtherScript = NO;
}


@end
