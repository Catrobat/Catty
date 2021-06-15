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
    
    if (categoryType == kRecentlyUsedBricks) {
        NSArray *recentlyUsedBricks = [RecentlyUsedBricksManager getRecentlyUsedBricks];
        
        for(NSString* recentlyUsedBrick in recentlyUsedBricks) {
            for(id<BrickProtocol> scriptOrBrick in selectableBricks) {
                NSString *wrappedBrickType = NSStringFromClass([scriptOrBrick class]);
                if([wrappedBrickType isEqualToString:recentlyUsedBrick] && !([scriptOrBrick isDisabledForBackground] && inBackground)) {
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

- (NSArray*)scriptCollectionCopyBrickWithIndexPath:(NSIndexPath*)indexPath andBrick:(Brick<BrickProtocol>*)brick
{
    if ([brick isLoopBrick]) {
        // loop brick
        LoopBeginBrick *loopBeginBrick = nil;
        LoopEndBrick *loopEndBrick = nil;
        if ([brick isKindOfClass:[LoopBeginBrick class]]) {
            loopBeginBrick = ((LoopBeginBrick*)brick);
            loopEndBrick = loopBeginBrick.loopEndBrick;
        } else {
            CBAssert([brick isKindOfClass:[LoopEndBrick class]]);
            loopEndBrick = ((LoopEndBrick*)brick);
            loopBeginBrick = loopEndBrick.loopBeginBrick;
        }
        CBAssert((loopBeginBrick != nil) || (loopEndBrick != nil));
        NSUInteger loopBeginIndex = [brick.script.brickList indexOfObject:loopBeginBrick];
        NSUInteger loopEndIndex = (loopBeginIndex + 1);
        LoopBeginBrick<CBConditionProtocol> *copiedLoopBeginBrick = [loopBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
        LoopEndBrick *copiedLoopEndBrick = [loopEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
        copiedLoopBeginBrick.loopEndBrick = copiedLoopEndBrick;
        copiedLoopEndBrick.loopBeginBrick = copiedLoopBeginBrick;
        [brick.script addBrick:copiedLoopBeginBrick atIndex:loopBeginIndex];
        [brick.script addBrick:copiedLoopEndBrick atIndex:loopEndIndex];
        NSIndexPath *loopBeginIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 1) inSection:indexPath.section];
        NSIndexPath *loopEndIndexPath = [NSIndexPath indexPathForItem:(loopBeginIndex + 2) inSection:indexPath.section];
        return @[loopBeginIndexPath, loopEndIndexPath];
        
    } else if ([brick isIfLogicBrick]) {
        // if brick
        IfThenLogicBeginBrick *ifThenLogicBeginBrick = nil;
        IfThenLogicEndBrick *ifThenLogicEndBrick = nil;
        IfLogicBeginBrick *ifLogicBeginBrick = nil;
        IfLogicElseBrick *ifLogicElseBrick = nil;
        IfLogicEndBrick *ifLogicEndBrick = nil;
        if ([brick isKindOfClass:[IfThenLogicBeginBrick class]]) {
            ifThenLogicBeginBrick = ((IfThenLogicBeginBrick*)brick);
            ifThenLogicEndBrick = ifThenLogicBeginBrick.ifEndBrick;
        } else if ([brick isKindOfClass:[IfLogicBeginBrick class]]) {
            ifLogicBeginBrick = ((IfLogicBeginBrick*)brick);
            ifLogicElseBrick = ifLogicBeginBrick.ifElseBrick;
            ifLogicEndBrick = ifLogicBeginBrick.ifEndBrick;
        } else if ([brick isKindOfClass:[IfLogicElseBrick class]]) {
            ifLogicElseBrick = ((IfLogicElseBrick*)brick);
            ifLogicBeginBrick = ifLogicElseBrick.ifBeginBrick;
            ifLogicEndBrick = ifLogicElseBrick.ifEndBrick;
        } else if ([brick isKindOfClass:[IfThenLogicEndBrick class]]) {
            ifThenLogicEndBrick = ((IfThenLogicEndBrick*)brick);
            ifThenLogicBeginBrick = ifThenLogicEndBrick.ifBeginBrick;
        } else {
            CBAssert([brick isKindOfClass:[IfLogicEndBrick class]]);
            ifLogicEndBrick = ((IfLogicEndBrick*)brick);
            ifLogicBeginBrick = ifLogicEndBrick.ifBeginBrick;
            ifLogicElseBrick = ifLogicEndBrick.ifElseBrick;
        }
        if(ifLogicBeginBrick != nil) {
            CBAssert((ifLogicBeginBrick != nil) && (ifLogicElseBrick != nil) && (ifLogicEndBrick != nil));
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifLogicBeginBrick];
            NSUInteger ifLogicElseIndex = (ifLogicBeginIndex + 1);
            NSUInteger ifLogicEndIndex = (ifLogicElseIndex + 1);
            IfLogicBeginBrick *copiedIfLogicBeginBrick = [ifLogicBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            IfLogicElseBrick *copiedIfLogicElseBrick = [ifLogicElseBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            IfLogicEndBrick *copiedIfLogicEndBrick = [ifLogicEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            copiedIfLogicBeginBrick.ifElseBrick = copiedIfLogicElseBrick;
            copiedIfLogicBeginBrick.ifEndBrick = copiedIfLogicEndBrick;
            copiedIfLogicElseBrick.ifBeginBrick = copiedIfLogicBeginBrick;
            copiedIfLogicElseBrick.ifEndBrick = copiedIfLogicEndBrick;
            copiedIfLogicEndBrick.ifBeginBrick = copiedIfLogicBeginBrick;
            copiedIfLogicEndBrick.ifElseBrick = copiedIfLogicElseBrick;
            [brick.script addBrick:copiedIfLogicBeginBrick atIndex:ifLogicBeginIndex];
            [brick.script addBrick:copiedIfLogicElseBrick atIndex:ifLogicElseIndex];
            [brick.script addBrick:copiedIfLogicEndBrick atIndex:ifLogicEndIndex];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            NSIndexPath *ifLogicElseIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 2) inSection:indexPath.section];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 3) inSection:indexPath.section];
            return @[ifLogicBeginIndexPath, ifLogicElseIndexPath, ifLogicEndIndexPath];
        } else if(ifThenLogicBeginBrick != nil){
            CBAssert((ifThenLogicBeginBrick != nil) && (ifLogicElseBrick == nil) && (ifThenLogicEndBrick != nil));
            NSUInteger ifLogicBeginIndex = [brick.script.brickList indexOfObject:ifThenLogicBeginBrick];
            NSUInteger ifLogicEndIndex = (ifLogicBeginIndex + 1);
            IfThenLogicBeginBrick *copiedIfLogicBeginBrick = [ifThenLogicBeginBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            IfThenLogicEndBrick *copiedIfLogicEndBrick = [ifThenLogicEndBrick mutableCopyWithContext:[CBMutableCopyContext new]];
            copiedIfLogicBeginBrick.ifEndBrick = copiedIfLogicEndBrick;
            copiedIfLogicEndBrick.ifBeginBrick = copiedIfLogicBeginBrick;
            [brick.script addBrick:copiedIfLogicBeginBrick atIndex:ifLogicBeginIndex];
            [brick.script addBrick:copiedIfLogicEndBrick atIndex:ifLogicEndIndex];
            NSIndexPath *ifLogicBeginIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 1) inSection:indexPath.section];
            NSIndexPath *ifLogicEndIndexPath = [NSIndexPath indexPathForItem:(ifLogicBeginIndex + 2) inSection:indexPath.section];
            return @[ifLogicBeginIndexPath, ifLogicEndIndexPath];
        } else {
            return @[];
        }
    } else {
        // normal brick
        NSUInteger copiedBrickIndex = ([brick.script.brickList indexOfObject:brick] + 1);
        Brick *copiedBrick = [brick mutableCopyWithContext:[CBMutableCopyContext new]];
        [brick.script addBrick:copiedBrick atIndex:copiedBrickIndex];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:(indexPath.row + 1) inSection:indexPath.section];
        return @[newIndexPath];
    }
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
