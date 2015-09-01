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

#import "BrickMoveManager.h"
#import "Script.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "LoopEndBrick.h"
#import "ForeverBrick.h"
#import "BrickCell.h"

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
    });
    return sharedBrickMoveManager;
}

#pragma mark - check move logic
- (BOOL)checkLoopBeginToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick andObject:(SpriteObject*)object
{
    if (((toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil) && (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil))||(toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil && self.lowerRankBrick == nil) || (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil && self.higherRankBrick == nil)||(self.higherRankBrick==nil && self.lowerRankBrick==nil))  {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *toScript = [object.scriptList objectAtIndex:toIndexPath.section];
            Brick *toBrick = [toScript.brickList objectAtIndex:toIndexPath.item - 1];
            
            if([toBrick isKindOfClass:[IfLogicBeginBrick class]]||[toBrick isKindOfClass:[IfLogicElseBrick class]]||[toBrick isKindOfClass:[IfLogicEndBrick class]]||[toBrick isKindOfClass:[LoopBeginBrick class]]||[toBrick isKindOfClass:[LoopEndBrick class]]){
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                } else {
                    self.lowerRankBrick = toIndexPath;
                }
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)checkLoopEndToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick andObject:(SpriteObject*)object
{
    // FIXME: YUMMI, SPAGHETTI CODE!!!
    LoopEndBrick *endbrick = (LoopEndBrick*) fromBrick;
    if ([endbrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
        return NO;
    }
    if (((toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil) && (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil))||(toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil && self.lowerRankBrick == nil) || (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil && self.higherRankBrick == nil)||(self.higherRankBrick==nil && self.lowerRankBrick==nil)) {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *script = [object.scriptList objectAtIndex:fromIndexPath.section];
            Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            
            if([toBrick isKindOfClass:[IfLogicBeginBrick class]]||[toBrick isKindOfClass:[IfLogicElseBrick class]]||[toBrick isKindOfClass:[IfLogicEndBrick class]]||[toBrick isKindOfClass:[LoopBeginBrick class]]||[toBrick isKindOfClass:[LoopEndBrick class]]){
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                } else {
                    self.lowerRankBrick = toIndexPath;
                }
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)checkIfBeginToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick andObject:(SpriteObject*)object
{
    if (((toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil) && (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil))||(toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil && self.lowerRankBrick == nil) || (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil && self.higherRankBrick == nil)||(self.higherRankBrick==nil && self.lowerRankBrick==nil))  {
        
        if (fromIndexPath.section == toIndexPath.section) {
            Script *toScript = [object.scriptList objectAtIndex:toIndexPath.section];
            Brick *toBrick = [toScript.brickList objectAtIndex:toIndexPath.item - 1];
            
            if([toBrick isKindOfClass:[LoopBeginBrick class]] || [toBrick isKindOfClass:[LoopEndBrick class]] || [toBrick isKindOfClass:[IfLogicBeginBrick class]] || [toBrick isKindOfClass:[IfLogicElseBrick class]] || [toBrick isKindOfClass:[IfLogicEndBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                } else {
                    self.lowerRankBrick = toIndexPath;
                }
                return NO;
            } else {
                return YES;
            }
            
        }
    }
    return NO;
}

- (BOOL)checkIfElseToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick andObject:(SpriteObject*)object
{
    if (((toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil) && (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil))||(toIndexPath.item > self.higherRankBrick.item && self.higherRankBrick != nil && self.lowerRankBrick == nil) || (toIndexPath.item < self.lowerRankBrick.item && self.lowerRankBrick != nil && self.higherRankBrick == nil)||(self.higherRankBrick==nil && self.lowerRankBrick==nil)) {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *script = [object.scriptList objectAtIndex:fromIndexPath.section];
            Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            
            if([toBrick isKindOfClass:[LoopBeginBrick class]] || [toBrick isKindOfClass:[LoopEndBrick class]] || [toBrick isKindOfClass:[IfLogicBeginBrick class]] || [toBrick isKindOfClass:[IfLogicElseBrick class]] || [toBrick isKindOfClass:[IfLogicEndBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                } else {
                    self.lowerRankBrick = toIndexPath;
                }
                return NO;
            } else {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL)checkIfEndToIndex:(NSIndexPath *)toIndexPath FromIndex:(NSIndexPath*)fromIndexPath andFromBrick:(Brick*)fromBrick andObject:(SpriteObject*)object
{
    if (toIndexPath.item > self.higherRankBrick.item || self.higherRankBrick==nil) {
        if (fromIndexPath.section == toIndexPath.section) {
            Script *script = [object.scriptList objectAtIndex:fromIndexPath.section];
            Brick *toBrick = [script.brickList objectAtIndex:toIndexPath.item - 1];
            if([toBrick isKindOfClass:[LoopBeginBrick class]] || [toBrick isKindOfClass:[LoopEndBrick class]] || [toBrick isKindOfClass:[IfLogicBeginBrick class]] || [toBrick isKindOfClass:[IfLogicElseBrick class]] || [toBrick isKindOfClass:[IfLogicEndBrick class]]) {
                if (toIndexPath.item < fromIndexPath.item) {
                    self.higherRankBrick = toIndexPath;
                } else {
                    self.lowerRankBrick = toIndexPath;
                }
                return NO;
            } else {
                return YES;
            }
            
        }
    }
    return NO;
}

- (BOOL)collectionView:(UICollectionView*)collectionView itemAtIndexPath:(NSIndexPath*)fromIndexPath
    canMoveToIndexPath:(NSIndexPath*)toIndexPath andObject:(SpriteObject*)object
{
    Script *fromScript = [object.scriptList objectAtIndex:fromIndexPath.section];
    Brick *fromBrick = [fromScript.brickList objectAtIndex:fromIndexPath.item - 1];
    
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
                return NO;
            }
        }
        if ([fromBrick isKindOfClass:[LoopBeginBrick class]]){
            return [self checkLoopBeginToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick andObject:object];
        } else if ([fromBrick isKindOfClass:[LoopEndBrick class]]) {
            return [self checkLoopEndToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick andObject:object];
        } else if ([fromBrick isKindOfClass:[IfLogicBeginBrick class]]){
            return [self checkIfBeginToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick andObject:object];
        } else if ([fromBrick isKindOfClass:[IfLogicElseBrick class]]){
            return [self checkIfElseToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick andObject:object];
        } else if ([fromBrick isKindOfClass:[IfLogicEndBrick class]]){
            return [self checkIfEndToIndex:toIndexPath FromIndex:fromIndexPath andFromBrick:fromBrick andObject:object];
        } else {
            return (toIndexPath.item != 0);
        }
    } else {
        Script *toScript = [object.scriptList objectAtIndex:toIndexPath.section];
        self.moveToOtherScript = YES;
        if ([toScript.brickList count] == 0) {
            return YES;
        } else {
            return NO;
        }
        
    }
}


-(void)reset
{
    self.higherRankBrick = nil;
    self.lowerRankBrick = nil;
    self.moveToOtherScript = NO;
}

@end
