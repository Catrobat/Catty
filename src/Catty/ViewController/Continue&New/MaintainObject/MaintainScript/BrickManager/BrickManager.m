/**
 *  Copyright (C) 2010-2021 The Catrobat Team
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

#import "BrickManager.h"
#import "BrickProtocol.h"
#import "BrickFormulaProtocol.h"
#import "WhenScript.h"
#import "LoopEndBrick.h"
#import "LoopBeginBrick.h"
#import "IfLogicBeginBrick.h"
#import "IfThenLogicEndBrick.h"
#import "IfThenLogicBeginBrick.h"
#import "IfLogicElseBrick.h"
#import "IfLogicEndBrick.h"
#import "CBMutableCopyContext.h"
#import "ForeverBrick.h"
#import "BrickCellProtocol.h"
#import "Pocket_Code-Swift.h"

@interface BrickManager()
@property(nonatomic, strong) NSArray<id<BrickProtocol>> *bricks;
@end

@implementation BrickManager

#pragma mark - construction methods
+ (instancetype)sharedBrickManager
{
    static BrickManager *_sharedCattyBrickManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedCattyBrickManager = [BrickManager new];
        _sharedCattyBrickManager.bricks = [[CatrobatSetup class] registeredBricks];
        
    });
    return _sharedCattyBrickManager;
}

#pragma mark - helpers
- (NSArray*)selectableBricks
{
    NSMutableArray *selectableBricksMutableArray = [NSMutableArray arrayWithCapacity:[self.bricks count]];
        
    for (id brick in self.bricks) {
        if ([brick isKindOfClass:[Brick class]] && ((Brick*)brick).isSelectableForObject) {
            [selectableBricksMutableArray addObject:brick];
        }
        if ([brick isKindOfClass:[Script class]]) {
            [selectableBricksMutableArray addObject:brick];
        }
    }
    return selectableBricksMutableArray;
}

- (NSArray*)selectableBricksForCategoryType:(kBrickCategoryType)categoryType {
    return [self selectableBricksForCategoryType:categoryType inBackground:false];
}

- (NSArray*)selectableBricksForCategoryType:(kBrickCategoryType)categoryType inBackground:(BOOL)inBackground
{
    NSArray *selectableBricks = [self selectableBricks];
    NSMutableArray *selectableBricksForCategoryMutable = [NSMutableArray arrayWithCapacity:[selectableBricks count]];
    
    if (categoryType == kFavouriteBricks) {
        NSArray *favouriteBricks = [Util getSubsetOfTheMostFavoriteChosenBricks:kMaxFavouriteBrickSize];
        
        for(NSString* favouriteBrick in favouriteBricks) {
            for(id<BrickProtocol> scriptOrBrick in selectableBricks) {
                NSString *wrappedBrickType = NSStringFromClass([scriptOrBrick class]);
                if([wrappedBrickType isEqualToString:favouriteBrick] && !([scriptOrBrick isDisabledForBackground] && inBackground)) {
                    [selectableBricksForCategoryMutable addObject:scriptOrBrick];
                }
            }
        }
        return (NSArray*)selectableBricksForCategoryMutable;
    }
    for (id<BrickProtocol> brick in selectableBricks) {
        if (inBackground && brick.isDisabledForBackground) {
            continue;
        } else if (brick.category == categoryType) {
            [selectableBricksForCategoryMutable addObject:brick];
        }
    }

    return (NSArray*)selectableBricksForCategoryMutable;
}

- (BrickCategory*)categoryForType:(kBrickCategoryType)categoryType {
    NSArray<BrickCategory*> *categories = [[CatrobatSetup class] registeredBrickCategories];
    
    for (BrickCategory *category in categories) {
        if (category.type == categoryType) {
            return category;
        }
    }
    return nil;
}

- (CGSize)sizeForBrick:(id<BrickProtocol>)brick
{
    Class<BrickCellProtocol> brickCell = [brick brickCell];
    if (brickCell) {
        return CGSizeMake(UIScreen.mainScreen.bounds.size.width, [brickCell cellHeight]);
    }
    
    return CGSizeZero;
}

- (NSInteger)checkEndLoopBrickTypeForDrawing:(BrickCell*)cell
{
    LoopEndBrick *brick = (LoopEndBrick*)cell.scriptOrBrick;
    if ([brick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
        NSInteger count;
        BOOL before = YES;
        BOOL after = NO;
        for (count = 0; count < brick.script.brickList.count; count++) {
            Brick* equalBrick = brick.script.brickList[count];
            if (equalBrick == brick) {
                if (count-1 >= 0) {
                    //CheckBrick before
                    before = [self checkBrickbeforeBrick:brick andIndex:count-1];
                }
                if (count+1 < brick.script.brickList.count) {
                    //CheckBrick after
                    after = [self checkBrickafterBrick:brick andIndex:count+1];
                }
            }
        }
        if (after && before) {
            return 0;
        } else if (!after && !before){
            return 2;
        } else if (!after && before){
            return 1;
        } else if (after && !before){
            return 3;
        }
      
    }
    return 0;
}

- (BOOL)checkBrickafterBrick:(Brick*)brick andIndex:(NSInteger)index
{
    Brick* afterBrick = brick.script.brickList[index];
    if ([afterBrick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *afterLoopEndBrick = (LoopEndBrick*)afterBrick;
        if (![afterLoopEndBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

- (BOOL)checkBrickbeforeBrick:(Brick*)brick andIndex:(NSInteger)index
{
    Brick* beforeBrick = brick.script.brickList[index];
    if ([beforeBrick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *beforeLoopEndBrick = (LoopEndBrick*)beforeBrick;
        if (![beforeLoopEndBrick.loopBeginBrick isKindOfClass:[ForeverBrick class]]) {
            return YES;
        }
        return NO;
    }
    return YES;
}

#pragma mark Animation
- (NSArray*)animateWithIndexPath:(NSIndexPath*)path Script:(Script*)script andBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[LoopBeginBrick class]] || [brick isKindOfClass:[LoopEndBrick class]]) {
        return [self loopBrickForAnimationIndexPath:path Script:script andBrick:brick];
    } else if ([brick isKindOfClass:[IfLogicBeginBrick class]] || [brick isKindOfClass:[IfThenLogicBeginBrick class]] || [brick isKindOfClass:[IfLogicElseBrick class]] || [brick isKindOfClass:[IfLogicEndBrick class]]  || [brick isKindOfClass:[IfThenLogicEndBrick class]]) {
        return [self ifBrickForAnimationIndexPath:path Script:script andBrick:brick];
    } else {
        return nil;
    }
}
- (NSArray*)loopBrickForAnimationIndexPath:(NSIndexPath*)indexPath Script:(Script*)script andBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        LoopBeginBrick *begin = (LoopBeginBrick*)brick;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:begin.loopEndBrick]) {
                break;
            }
            ++count;
        }
        begin.animate = YES;
        begin.loopEndBrick.animate = YES;
        return @[[NSNumber numberWithInteger:count+1]];
    } else if ([brick isKindOfClass:[LoopEndBrick class]]) {
        LoopEndBrick *endBrick = (LoopEndBrick *)brick;
        NSInteger count = 0;
        for (Brick *check in script.brickList) {
            if ([check isEqual:endBrick.loopBeginBrick]) {
                break;
            }
            ++count;
        }
        endBrick.animate = YES;
        endBrick.loopBeginBrick.animate = YES;
        return @[[NSNumber numberWithInteger:count+1]];
    }
    return nil;
}

- (NSArray*)ifBrickForAnimationIndexPath:(NSIndexPath*)indexPath Script:(Script*)script andBrick:(Brick *)brick
{
    if ([brick isKindOfClass:[IfThenLogicBeginBrick class]]) {
        IfThenLogicBeginBrick *begin = (IfThenLogicBeginBrick*)brick;
        NSInteger endcount = 0;
        for (Brick *checkBrick in script.brickList) {
            if ([checkBrick isEqual:begin.ifEndBrick]) {
                break;
            } else {
                ++endcount;
            }
            
        }
        begin.animate = YES;
        begin.ifEndBrick.animate = YES;
        return @[[NSNumber numberWithInteger:endcount+1]];
    }
    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
        IfLogicBeginBrick *begin = (IfLogicBeginBrick*)brick;
        NSInteger elsecount = 0;
        NSInteger endcount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:begin.ifElseBrick]) {
                    found = YES;
                } else {
                    ++elsecount;
                }
            }
            if ([checkBrick isEqual:begin.ifEndBrick]) {
                break;
            } else {
                ++endcount;
            }
            
        }
        begin.animate = YES;
        begin.ifElseBrick.animate = YES;
        begin.ifEndBrick.animate = YES;
        return @[[NSNumber numberWithInteger:elsecount+1],[NSNumber numberWithInteger:endcount+1]];
    } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
        IfLogicElseBrick *elseBrick = (IfLogicElseBrick*)brick;
        NSInteger begincount = 0;
        NSInteger endcount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:elseBrick.ifBeginBrick]) {
                    found = YES;
                } else {
                    ++begincount;
                }
            }
            if ([checkBrick isEqual:elseBrick.ifEndBrick]) {
                break;
            } else {
                ++endcount;
            }
        }
        elseBrick.animate = YES;
        elseBrick.ifBeginBrick.animate = YES;
        elseBrick.ifEndBrick.animate = YES;
        return @[[NSNumber numberWithInteger:begincount+1],[NSNumber numberWithInteger:endcount+1]];
    } else if ([brick isKindOfClass:[IfLogicEndBrick class]]) {
        IfLogicEndBrick *endBrick = (IfLogicEndBrick*)brick;
        NSInteger elsecount = 0;
        NSInteger begincount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:endBrick.ifBeginBrick]) {
                    found = YES;
                } else {
                    ++begincount;
                }
            }
            if ([checkBrick isEqual:endBrick.ifElseBrick]) {
                break;
            } else {
                ++elsecount;
            }
            
        }
        endBrick.animate = YES;
        endBrick.ifElseBrick.animate = YES;
        endBrick.ifBeginBrick.animate = YES;
        return @[[NSNumber numberWithInteger:elsecount+1],[NSNumber numberWithInteger:begincount+1]];
    } else if ([brick isKindOfClass:[IfThenLogicEndBrick class]]) {
        IfThenLogicEndBrick *endBrick = (IfThenLogicEndBrick*)brick;
        NSInteger begincount = 0;
        BOOL found = NO;
        for (Brick *checkBrick in script.brickList) {
            if (! found) {
                if ([checkBrick isEqual:endBrick.ifBeginBrick]) {
                    found = YES;
                } else {
                    ++begincount;
                }
            }
        }
        endBrick.animate = YES;
        endBrick.ifBeginBrick.animate = YES;
        return @[[NSNumber numberWithInteger:begincount+1]];
    }
    return nil;
}

#pragma mark ScriptCollectionViewController Copy

-(NSArray*)scriptCollectionCopyBrickWithIndexPath:(NSIndexPath *)indexPath andBrick:(Brick *)brick
{
    return [self scriptCollectionCopyBrickWithIndexPath:indexPath forBrick:brick andNestedIndex:0];
}

- (NSArray*)scriptCollectionCopyBrickWithIndexPath:(NSIndexPath*)indexPath forBrick:(Brick*)brick andNestedIndex:(int)nestedIndex
{
    if ([brick isLoopBrick]) {
        return [self copyLoopBrickWithIndexPath:indexPath forBrick:brick andNestedIndex:nestedIndex];
    } else if ([brick isIfLogicBrick]) {
        if([brick isKindOfClass:[IfThenLogicBeginBrick class]] || [brick isKindOfClass:[IfThenLogicEndBrick class]])
        {
            return [self copyIfThenLogicBrickWithIndexPath:indexPath forBrick:brick andNestedIndex:nestedIndex];
        } else if([brick isKindOfClass:[IfLogicBeginBrick class]] || [brick isKindOfClass:[IfLogicElseBrick class]] || [brick isKindOfClass:[IfLogicEndBrick class]]) {
            return [self copyIfLogicBrickWithIndexPath:indexPath forBrick:brick andNestedIndex:nestedIndex];
        } else {
            return @[];
        }
    } else {
        NSUInteger copiedBrickIndex = ([brick.script.brickList indexOfObject:brick] + 1);
        Brick *copiedBrick = [brick mutableCopyWithContext:[CBMutableCopyContext new]];
        [brick.script addBrick:copiedBrick atIndex:copiedBrickIndex];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(indexPath.row + 1) inSection:indexPath.section];
        return @[newIndexPath];
    }
}

- (NSArray*)copyLoopBrickWithIndexPath:(NSIndexPath*)indexPath forBrick:(Brick*)brick andNestedIndex:(int)nestedIndex
{
    LoopBeginBrick *loopBeginBrick = nil;
    LoopEndBrick *loopEndBrick = nil;
    NSUInteger loopBeginIndex = 0;
    NSUInteger loopEndIndex = 0;
    NSMutableArray *nestedBricks = [NSMutableArray new];

    if ([brick isKindOfClass:[LoopBeginBrick class]]) {
        loopBeginBrick = ((LoopBeginBrick*)brick);
        loopEndBrick = loopBeginBrick.loopEndBrick;
    } else {
        loopEndBrick = ((LoopEndBrick*)brick);
        loopBeginBrick = loopEndBrick.loopBeginBrick;
    }
    loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
    loopEndIndex = [brick.script.brickList indexOfObject:loopEndBrick];

    for (int i = (int) loopBeginIndex + 1; i < loopEndIndex; i++)
    {
        Brick *object = [brick.script.brickList objectAtIndex:i];
        [nestedBricks addObject:object];
    }
    
    LoopBeginBrick<CBConditionProtocol> *copiedLoopBeginBrick = [loopBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    LoopEndBrick *copiedLoopEndBrick = [loopEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    copiedLoopBeginBrick.loopEndBrick = copiedLoopEndBrick;
    copiedLoopEndBrick.loopBeginBrick = copiedLoopBeginBrick;
    if(nestedIndex == 0)
    {
        [brick.script addBrick:copiedLoopBeginBrick atIndex:loopBeginIndex];
    }
    else
    {
        [brick.script addBrick:copiedLoopBeginBrick atIndex:nestedIndex];
    }
    
    NSMutableArray *returnValues = [NSMutableArray new];
    NSIndexPath *loopIndexPath = [NSIndexPath indexPathForItem:( 1 + nestedIndex) inSection:indexPath.section];
    [returnValues addObject:loopIndexPath];
    NSInteger loopBeginIndexCopy = loopBeginIndex + 1;
    Brick *nestedBrick;
    for(int i = 0; i < nestedBricks.count; i++)
    {
        nestedBrick = nestedBricks[i];
        if([nestedBrick isKindOfClass:[LoopBeginBrick class]] || [nestedBrick isKindOfClass:[IfThenLogicBeginBrick class]] || [nestedBrick isKindOfClass:[IfLogicBeginBrick class]] )
        {
            NSArray* nestedLoopOrLogic = [[BrickManager sharedBrickManager] scriptCollectionCopyBrickWithIndexPath:[NSIndexPath indexPathForItem:(i + 2) inSection:indexPath.section] forBrick:nestedBrick andNestedIndex:(int)loopBeginIndex + 1 + i - nestedIndex];
            [returnValues addObjectsFromArray:nestedLoopOrLogic];
            i += nestedLoopOrLogic.count-1;
        }
        else if ([nestedBrick isKindOfClass:[IfLogicElseBrick class]] )
        {
            NSError(@"Copying wrong Brick, Should not happen!!");
        }
        else if ([nestedBrick isKindOfClass:[LoopEndBrick class]] || [nestedBrick isKindOfClass:[IfThenLogicEndBrick class]] || [nestedBrick isKindOfClass:[IfLogicEndBrick class]])
        {
            NSError(@"Copying wrong Brick, Should not happen!!");
        }
        else
        {
            if(nestedIndex == 0)
            {
                [brick.script addBrick:[nestedBrick mutableCopyWithContext:[CBMutableCopyContext new]] atIndex:loopBeginIndex + 1 + i];
            }
            else
            {
                [brick.script addBrick:[nestedBrick mutableCopyWithContext:[CBMutableCopyContext new]] atIndex:nestedIndex + 1 + i];
            }
            loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 2 + i) inSection:indexPath.section];
            [returnValues addObject:loopIndexPath];
        }
    }
    
    if(nestedIndex == 0)
    {
        [brick.script addBrick:copiedLoopEndBrick atIndex:loopBeginIndexCopy + nestedBricks.count];
    }
    else
    {
        [brick.script addBrick:copiedLoopEndBrick atIndex:nestedIndex + 1 + nestedBricks.count];
    }
    loopIndexPath = [NSIndexPath indexPathForItem:(1 + nestedIndex + nestedBricks.count) inSection:indexPath.section];
    [returnValues addObject:loopIndexPath];
    return returnValues;
}

- (NSArray*)copyIfLogicBrickWithIndexPath:(NSIndexPath*)indexPath forBrick:(Brick*)brick andNestedIndex:(int)nestedIndex
{
    IfLogicBeginBrick *ifLogicBeginBrick = nil;
    IfLogicElseBrick *ifLogicElseBrick = nil;
    IfLogicEndBrick *ifLogicEndBrick = nil;
    NSMutableArray *nestedBricks = [NSMutableArray new];
    if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
        ifLogicBeginBrick = ((IfLogicBeginBrick*)brick);
        ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
        ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
    } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
        ifLogicElseBrick = ((IfLogicElseBrick*)brick);
        ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
        ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
    } else {
        ifLogicEndBrick = ((IfLogicEndBrick*)brick);
        ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
        ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
    }
    
    NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
    NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
    
    IfLogicBeginBrick *copiedIfLogicBeginBrick = [ifLogicBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    IfLogicElseBrick *copiedIfLogicElseBrick = [ifLogicElseBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    IfLogicEndBrick *copiedIfLogicEndBrick = [ifLogicEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    copiedIfLogicBeginBrick.ifElseBrick = copiedIfLogicElseBrick;
    copiedIfLogicBeginBrick.ifEndBrick = copiedIfLogicEndBrick;
    copiedIfLogicElseBrick.ifBeginBrick = copiedIfLogicBeginBrick;
    copiedIfLogicElseBrick.ifEndBrick = copiedIfLogicEndBrick;
    copiedIfLogicEndBrick.ifBeginBrick = copiedIfLogicBeginBrick;
    copiedIfLogicEndBrick.ifElseBrick = copiedIfLogicElseBrick;
    
    for (int i = (int) ifLogicBeginIndex + 1; i < ifLogicEndIndex; i++)
    {
        Brick *object = [brick.script.brickList objectAtIndex:i];
        [nestedBricks addObject:object];
    }
    
    if(nestedIndex == 0)
    {
        [brick.script addBrick:copiedIfLogicBeginBrick atIndex:ifLogicBeginIndex];
    }
    else
    {
        [brick.script addBrick:copiedIfLogicBeginBrick atIndex:nestedIndex];
    }
    NSMutableArray *returnValues = [NSMutableArray new];
    NSIndexPath *loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 1) inSection:indexPath.section];
    [returnValues addObject:loopIndexPath];
    Brick *nestedBrick;
    
    for(int i = 0; i < nestedBricks.count; i++)
    {
        nestedBrick = nestedBricks[i];
        if([nestedBrick isKindOfClass:[LoopBeginBrick class]] || [nestedBrick isKindOfClass:[IfThenLogicBeginBrick class]] || [nestedBrick isKindOfClass:[IfLogicBeginBrick class]] )
        {
            NSArray* nestedLoopOrLogic = [[BrickManager sharedBrickManager] scriptCollectionCopyBrickWithIndexPath:[NSIndexPath indexPathForItem:(i + 2) inSection:indexPath.section] forBrick:nestedBrick andNestedIndex:(int)ifLogicBeginIndex + 1 + i - nestedIndex];
            [returnValues addObjectsFromArray:nestedLoopOrLogic];
            i += nestedLoopOrLogic.count-1;
        }
        else if ([nestedBrick isKindOfClass:[IfLogicElseBrick class]] )
        {
            if(nestedIndex == 0)
            {
                [brick.script addBrick:copiedIfLogicElseBrick atIndex:ifLogicBeginIndex + 1 + i];
            }
            else
            {
                [brick.script addBrick:copiedIfLogicElseBrick atIndex:nestedIndex + 1 + i];
            }
            loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 2 + i) inSection:indexPath.section];
            [returnValues addObject:loopIndexPath];
        }
        else if ([nestedBrick isKindOfClass:[LoopEndBrick class]] || [nestedBrick isKindOfClass:[IfThenLogicEndBrick class]] || [nestedBrick isKindOfClass:[IfLogicEndBrick class]])
        {
            NSError(@"Copying wrong Brick, Should not happen!!");
        }
        else
        {
            if(nestedIndex == 0)
            {
                [brick.script addBrick:[nestedBrick mutableCopyWithContext:[CBMutableCopyContext new]] atIndex:ifLogicBeginIndex + 1 + i];
            }
            else
            {
                [brick.script addBrick:[nestedBrick mutableCopyWithContext:[CBMutableCopyContext new]] atIndex:nestedIndex + 1 + i];
            }
            loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 2 + i) inSection:indexPath.section];
            [returnValues addObject:loopIndexPath];
        }
    }
    
    if(nestedIndex == 0)
    {
        [brick.script addBrick:copiedIfLogicEndBrick atIndex:ifLogicBeginIndex + 1 + nestedBricks.count];
    }
    else
    {
        [brick.script addBrick:copiedIfLogicEndBrick atIndex:nestedIndex + 1 + nestedBricks.count];
    }
    loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 2 + nestedBricks.count) inSection:indexPath.section];
    [returnValues addObject:loopIndexPath];
    return returnValues;
}

- (NSArray*)copyIfThenLogicBrickWithIndexPath:(NSIndexPath*)indexPath forBrick:(Brick*)brick andNestedIndex:(int)nestedIndex
{
    IfThenLogicBeginBrick *ifThenLogicBeginBrick = nil;
    IfThenLogicEndBrick *ifThenLogicEndBrick = nil;
    NSMutableArray *nestedBricks = [NSMutableArray new];
    if ([brick isKindOfClass:[IfThenLogicBeginBrick class]]) {
        ifThenLogicBeginBrick = ((IfThenLogicBeginBrick*)brick);
        ifThenLogicEndBrick = ifThenLogicBeginBrick.ifEndBrick;
    } else {
        ifThenLogicEndBrick = ((IfThenLogicEndBrick*)brick);
        ifThenLogicBeginBrick = ifThenLogicEndBrick.ifBeginBrick;
    }
    
    NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifThenLogicBeginBrick];
    NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifThenLogicEndBrick];
    
    for (int i = (int) ifLogicBeginIndex + 1; i < ifLogicEndIndex; i++)
    {
        Brick *object = [brick.script.brickList objectAtIndex:i];
        [nestedBricks addObject:object];
    }
    IfThenLogicBeginBrick *copiedIfLogicBeginBrick = [ifThenLogicBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    IfThenLogicEndBrick *copiedIfLogicEndBrick = [ifThenLogicEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
    copiedIfLogicBeginBrick.ifEndBrick = copiedIfLogicEndBrick;
    copiedIfLogicEndBrick.ifBeginBrick = copiedIfLogicBeginBrick;
    
    if(nestedIndex == 0)
    {
        [brick.script addBrick:copiedIfLogicBeginBrick atIndex:ifLogicBeginIndex];
    }
    else
    {
        [brick.script addBrick:copiedIfLogicBeginBrick atIndex:nestedIndex];
    }
    NSMutableArray *returnValues = [NSMutableArray new];
    NSIndexPath *loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 1) inSection:indexPath.section];
    [returnValues addObject:loopIndexPath];
    Brick *nestedBrick;
    
    
    for (int i = 0; i < nestedBricks.count; i++)
    {
        nestedBrick = nestedBricks[i];
        if([nestedBrick isKindOfClass:[LoopBeginBrick class]] || [nestedBrick isKindOfClass:[IfThenLogicBeginBrick class]] || [nestedBrick isKindOfClass:[IfLogicBeginBrick class]] )
        {
            NSArray* nestedLoopOrLogic = [[BrickManager sharedBrickManager] scriptCollectionCopyBrickWithIndexPath:[NSIndexPath indexPathForItem:(i + 2) inSection:indexPath.section] forBrick:nestedBrick andNestedIndex:(int)ifLogicBeginIndex + 1 + i - nestedIndex];
            [returnValues addObjectsFromArray:nestedLoopOrLogic];
            i += nestedLoopOrLogic.count -1;
        }
        else if ([nestedBrick isKindOfClass:[IfLogicElseBrick class]] )
        {
            if(nestedIndex == 0)
            {
                [brick.script addBrick:[nestedBrick mutableCopyWithContext:[CBMutableCopyContext new]] atIndex:ifLogicBeginIndex + 1 + i];
            }
            else
            {
                [brick.script addBrick:[nestedBrick mutableCopyWithContext:[CBMutableCopyContext new]] atIndex:nestedIndex + 1 + i];
            }
            loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 2 + i) inSection:indexPath.section];
            [returnValues addObject:loopIndexPath];
        }
        else if ([nestedBrick isKindOfClass:[LoopEndBrick class]] || [nestedBrick isKindOfClass:[IfThenLogicEndBrick class]] || [nestedBrick isKindOfClass:[IfLogicEndBrick class]])
        {
            NSError(@"Copying wrong Brick, Should not happen!!");
        }
        else
        {
            if(nestedIndex == 0)
            {
                [brick.script addBrick:[nestedBrick mutableCopyWithContext:[CBMutableCopyContext new]] atIndex:ifLogicBeginIndex + 1 + i];
            }
            else
            {
                [brick.script addBrick:[nestedBrick mutableCopyWithContext:[CBMutableCopyContext new]] atIndex:nestedIndex + 1 + i];
            }
            loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 2 + i) inSection:indexPath.section];
            [returnValues addObject:loopIndexPath];
        }
    }
    
    if(nestedIndex == 0)
    {
        [brick.script addBrick:copiedIfLogicEndBrick atIndex:ifLogicBeginIndex + 1 + nestedBricks.count];
    }
    else
    {
        [brick.script addBrick:copiedIfLogicEndBrick atIndex:nestedIndex + 1 + nestedBricks.count];
    }
    loopIndexPath = [NSIndexPath indexPathForItem:(nestedIndex + 2 + nestedBricks.count) inSection:indexPath.section];
    [returnValues addObject:loopIndexPath];
    return returnValues;
}

#pragma mark RemovingBrick from CollectionView

- (NSArray*)getIndexPathsForRemovingBricks:(NSIndexPath*)indexPath andBrick:(Brick*)brick
{
    if ([brick isLoopBrick]) {
        // loop brick
        LoopBeginBrick *loopBeginBrick = nil;
        LoopEndBrick *loopEndBrick = nil;
        if ([brick isKindOfClass:[LoopBeginBrick class]]) {
            loopBeginBrick = ((LoopBeginBrick*)brick);
            NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
            NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
            
            loopEndBrick = loopBeginBrick.loopEndBrick;
            NSUInteger loopEndIndex = [brick.script.brickList indexOfObject:loopEndBrick];
            NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopEndIndex + 1) inSection:indexPath.section];
            
            [loopBeginBrick removeFromScript];
            [loopEndBrick removeFromScript];
            return @[loopBeginIndexPath,loopEndIndexPath];
        } else {
            CBAssert([brick isKindOfClass:[LoopEndBrick class]]);
            loopEndBrick = ((LoopEndBrick*)brick);
            NSUInteger loopEndIndex = [brick.script.brickList indexOfObject:loopEndBrick];
            NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopEndIndex + 1) inSection:indexPath.section];
            
            loopBeginBrick = loopEndBrick.loopBeginBrick;
            NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
            NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
            
            [loopBeginBrick removeFromScript];
            [loopEndBrick removeFromScript];
            return @[loopBeginIndexPath,loopEndIndexPath];
        }
        
    } else if ([brick isIfLogicBrick]) {
        // if brick
        IfThenLogicBeginBrick *ifThenLogicBeginBrick = nil;
        IfThenLogicEndBrick *ifThenLogicEndBrick = nil;
        IfLogicBeginBrick *ifLogicBeginBrick = nil;
        IfLogicElseBrick *ifLogicElseBrick = nil;
        IfLogicEndBrick *ifLogicEndBrick = nil;
        if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
            ifLogicBeginBrick = ((IfLogicBeginBrick*)brick);
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
            NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
            NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
            
            ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            [ifLogicBeginBrick removeFromScript];
            [ifLogicElseBrick removeFromScript];
            [ifLogicEndBrick removeFromScript];
            
            return @[ifLogicBeginIndexPath,ifLogicElseIndexPath,ifLogicEndIndexPath];
            
        } else if ([brick isKindOfClass:[IfThenLogicBeginBrick class]]) {
            ifThenLogicBeginBrick = ((IfThenLogicBeginBrick*)brick);
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifThenLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            ifThenLogicEndBrick = ifThenLogicBeginBrick.ifEndBrick;
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifThenLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            [ifThenLogicBeginBrick removeFromScript];
            [ifThenLogicEndBrick removeFromScript];
            
            return @[ifLogicBeginIndexPath,ifLogicEndIndexPath];
            
        } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
            ifLogicElseBrick = ((IfLogicElseBrick*)brick);
            NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
            NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
            
            ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            [ifLogicElseBrick removeFromScript];
            [ifLogicBeginBrick removeFromScript];
            [ifLogicEndBrick removeFromScript];
            return @[ifLogicBeginIndexPath,ifLogicElseIndexPath,ifLogicEndIndexPath];
            
        } else if ([brick isKindOfClass:[IfThenLogicEndBrick class]]) {
            ifThenLogicEndBrick = ((IfThenLogicEndBrick*)brick);
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifThenLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            ifThenLogicBeginBrick = ifThenLogicEndBrick.ifBeginBrick;
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifThenLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            [ifThenLogicBeginBrick removeFromScript];
            [ifThenLogicEndBrick removeFromScript];
            return @[ifLogicBeginIndexPath,ifLogicEndIndexPath];
        } else {
            CBAssert([brick isKindOfClass:[IfLogicEndBrick class]]);
            ifLogicEndBrick = ((IfLogicEndBrick*)brick);
            NSUInteger ifLogicEndIndex = [brick.script.brickList indexOfObject:ifLogicEndBrick];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicEndIndex + 1) inSection:indexPath.section];
            
            ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            
            ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
            NSUInteger ifLogicElseIndex = [brick.script.brickList indexOfObject:ifLogicElseBrick];
            NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicElseIndex + 1) inSection:indexPath.section];
            
            [ifLogicBeginBrick removeFromScript];
            [ifLogicEndBrick removeFromScript];
            [ifLogicElseBrick removeFromScript];
            return @[ifLogicBeginIndexPath,ifLogicElseIndexPath,ifLogicEndIndexPath];
            
        }
        
    } else {
        [brick removeFromScript];
        return @[indexPath];
    }
    
}

@end
